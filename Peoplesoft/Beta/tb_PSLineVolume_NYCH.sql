--*********************************************************************************************
--Tableau Sproc  These load data into the datasources for Tableau
--*********************************************************************************************

if exists (select * from dbo.sysobjects where id = object_id(N'tb_LineVolume') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure tb_LineVolume
GO

--exec tb_LineVolume

CREATE PROCEDURE tb_LineVolume


AS
BEGIN
SET NOCOUNT ON

declare @Facility int = (select ConfigValue from bluebin.Config where ConfigName = 'PS_DefaultFacility')
declare @DefaultLT int = (Select max(ConfigValue) from bluebin.Config where ConfigName = 'DefaultLeadTime')
declare @POTimeAdjust int = (Select max(ConfigValue) from bluebin.Config where ConfigName = 'PS_POTimeAdjust')
;

WITH FirstScans
     AS (

		select
		LocationID,
		ItemID,
		COALESCE(DEMAND_DATE,SCHED_DTTM,NULL) as FirstScanDate
		from 
				(
				SELECT db.LocationID,
					   db.ItemID,
						Min(ct.DEMAND_DATE) AS DEMAND_DATE,
						min(id.SCHED_DTTM) as SCHED_DTTM
				 FROM   bluebin.DimBin db
				 LEFT JOIN dbo.CART_CT_INF_INV ct on db.LocationID = ct.INV_CART_ID and db.ItemID = ct.INV_ITEM_ID and ct.CART_COUNT_QTY > 0 AND ct.PROCESS_INSTANCE > 0
				 LEFT JOIN IN_DEMAND id on db.LocationID = id.LOCATION and db.ItemID = id.INV_ITEM_ID
				 GROUP  BY 
				 db.LocationID,
				  db.ItemID
				  ) a 
				   
				   ),
--**************************
Orders
     AS (
				select
                PO_LN.INV_ITEM_ID                         AS ItemID,
                PO_LN_DST.LOCATION                        AS LocationID,
                PO_LN.PO_ID                               AS OrderNum,
                PO_LN.LINE_NBR                            AS LineNum,
                RECEIPT_DTTM                              AS CloseDate,
                QTY_PO                                    AS OrderQty,
                PO_LN.UNIT_OF_MEASURE                     AS OrderUOM,
                DATEADD(hour,@POTimeAdjust,PO_HDR.PO_DT) as PO_DT,
				PO_LN_DST.ACCOUNT
         FROM   dbo.PO_LINE_DISTRIB PO_LN_DST
                INNER JOIN dbo.PO_LINE PO_LN
                        ON PO_LN_DST.PO_ID = PO_LN.PO_ID
                           AND PO_LN_DST.LINE_NBR = PO_LN.LINE_NBR
                INNER JOIN dbo.PO_HDR
                        ON PO_LN.PO_ID = PO_HDR.PO_ID
							AND PO_LN.BUSINESS_UNIT = PO_HDR.BUSINESS_UNIT
                LEFT JOIN
					(select PO_ID,LINE_NBR,max(RECEIPT_DTTM) as RECEIPT_DTTM from dbo.RECV_LN_SHIP group by PO_ID,LINE_NBR) SHIP
						ON PO_LN.PO_ID = SHIP.PO_ID
                          AND PO_LN.LINE_NBR = SHIP.LINE_NBR
				--LEFT JOIN dbo.RECV_LN_SHIP SHIP
    --                   ON PO_LN.PO_ID = SHIP.PO_ID
    --                      AND PO_LN.LINE_NBR = SHIP.LINE_NBR
                LEFT JOIN FirstScans
                       ON RIGHT(('000000000000000000' + PO_LN.INV_ITEM_ID),18) = RIGHT(('000000000000000000' + FirstScans.ItemID),18)
                          AND PO_LN_DST.LOCATION = FirstScans.LocationID
         WHERE   ISNULL(PO_LN.CANCEL_STATUS,'') NOT IN ( 'X', 'D' )

				) 
				,

Lines AS (
SELECT 
	   a.ItemID,
       a.LocationID,
       a.OrderNum,
       a.LineNum,
       a.PO_DT                AS OrderDate,
       a.CloseDate,
       a.OrderQty,
       a.OrderUOM,
	   a.ACCOUNT
FROM   Orders a


UNION ALL
SELECT 
       INV_ITEM_ID as ItemID,
       LOCATION as LocationID,
       Picks.ORDER_NO as OrderNum,
       Picks.ORDER_INT_LINE_NO as LineNum,
       COALESCE(Picks.SCHED_DTTM,Picks.DEMAND_DATE) as OrderDate,
       Picks.PICK_CONFIRM_DTTM as CloseDate,
       Cast(Picks.QTY_PICKED AS INT) AS OrderQty, 
	UNIT_OF_MEASURE as OrderUOM,
	Picks.ACCOUNT

FROM   dbo.IN_DEMAND  Picks

		LEFT JOIN FirstScans
		ON Picks.INV_ITEM_ID = FirstScans.ItemID AND Picks.LOCATION = FirstScans.LocationID
WHERE   (CANCEL_DTTM IS NULL  or CANCEL_DTTM < '1900-01-02')
	   AND DEMAND_DATE >= ISNULL(FirstScanDate,'1900-01-02')
	   )


SELECT 
df.FacilityID AS COMPANY,
df.FacilityName AS FacilityName,
l.OrderDate AS Date,
case when dl.BlueBinFlag = 1 then 'BlueBin' else 'Non BlueBin' end AS LineType,
ISNULL(l.ACCOUNT,'None') AS AcctUnit,
COALESCE(gl.DESCR,l.ACCOUNT,'None') AS AcctUnitName,
l.LocationID AS Location,
dl.LocationName as LocationName,
1               AS LineCount,
'' as NAME
from Lines l
inner join bluebin.DimLocation dl on  l.LocationID = dl.LocationID
inner join bluebin.DimFacility df on rtrim(dl.LocationFacility) = rtrim(df.FacilityID)
left join GL_ACCOUNT_TBL gl on l.ACCOUNT = gl.ACCOUNT


END
GO
grant exec on tb_LineVolume to public
GO
