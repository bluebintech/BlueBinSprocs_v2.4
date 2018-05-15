--*********************************************************************************************
--Tableau Sproc  These load data into the datasources for Tableau
--*********************************************************************************************


IF EXISTS ( SELECT  *
            FROM    sys.objects
            WHERE   object_id = OBJECT_ID(N'tb_OrderVolume')
                    AND type IN ( N'P', N'PC' ) ) 

DROP PROCEDURE  tb_OrderVolume
GO

CREATE PROCEDURE	tb_OrderVolume
--exec tb_OrderVolume  
AS

SET NOCOUNT on
declare @Facility int = (select ConfigValue from bluebin.Config where ConfigName = 'PS_DefaultFacility')
declare @FacilityName varchar(30) = (select PSFacilityName from bluebin.DimFacility where FacilityID = @Facility)
  

select 
k.OrderDate as CREATION_DATE,
df.FacilityID as COMPANY,
df.FacilityName,
k.LocationID as REQ_LOCATION,
k.OrderNum as REQ_NUMBER,
k.LineNum as Lines,
'BlueBin' as NAME,
dl.BlueBinFlag
from tableau.Kanban k
inner join bluebin.DimLocation dl on  k.FacilityID = dl.LocationFacility and k.LocationID = dl.LocationID 
inner join bluebin.DimFacility df on rtrim(dl.LocationFacility) = rtrim(df.FacilityID)
--left join REQUESTER r on rh.REQUESTER = r.REQUESTER and rq.COMPANY = r.COMPANY
where k.OrderDate > getdate()-15 and Scan > 0



GO
grant exec on tb_OrderVolume to public
GO



--*********************************************************************************************
--Tableau Sproc  These load data into the datasources for Tableau
--*********************************************************************************************

if exists (select * from dbo.sysobjects where id = object_id(N'tb_StatCalls') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure tb_StatCalls
GO


--exec tb_StatCalls
CREATE PROCEDURE tb_StatCalls
AS
BEGIN
SET NOCOUNT ON

declare @Facility int = (select ConfigValue from bluebin.Config where ConfigName = 'PS_DefaultFacility')
declare @FacilityName varchar(30) = (select PSFacilityName from bluebin.DimFacility where FacilityID = @Facility)

   --update bluebin.Config set ConfigValue = '' where ConfigName = 'PS_DefaultFacility'
   
   --update bluebin.Config set ConfigValue = NULL where ConfigName = 'PS_DefaultFacility'

SELECT 
COALESCE(df.FacilityID,@Facility) as FROM_TO_CMPY,
--case when @Facility is not null or @Facility <> '' then COALESCE(@Facility,BUSINESS_UNIT) else BUSINESS_UNIT end as FROM_TO_CMPY,
COALESCE(df.PSFacilityName,@FacilityName) as FacilityName,
lt.LOCATION as LocationID,
lt.DESCR as LocationName,
case when ISNULL(dl.BlueBinFlag,0) = 1 then 'Yes' else 'No' end as BlueBinFlag,
DEMAND_DATE       AS [Date],
COUNT(*) as StatCalls,
case when BUSINESS_UNIT <> SOURCE_BUS_UNIT then SOURCE_BUS_UNIT else BUSINESS_UNIT end as Department,
case when ORDER_NO LIKE 'MSR%' then 'Yes' else 'No' end as WHSource

FROM   IN_DEMAND
       LEFT JOIN LOCATION_TBL lt on rtrim(IN_DEMAND.LOCATION) = rtrim(lt.LOCATION)
	   LEFT JOIN bluebin.DimLocation dl ON lt.LOCATION = dl.LocationID
	   LEFT JOIN bluebin.DimFacility df on IN_DEMAND.BUSINESS_UNIT= df.FacilityName
	   

WHERE  PICK_BATCH_ID = 0
       AND (BUSINESS_UNIT in (Select ConfigValue from bluebin.Config where ConfigName = 'PS_BUSINESSUNITSTAT') or SOURCE_BUS_UNIT in (Select ConfigValue from bluebin.Config where ConfigName = 'PS_BUSINESSUNIT'))
	   AND (IN_FULFILL_STATE in (select ConfigValue from bluebin.Config where ConfigName = 'PS_InFulfillState') or IN_FULFILL_STATE is null)


GROUP BY
--DimLocation.LocationID,
--DimLocation.LocationName,
BUSINESS_UNIT,
df.FacilityID,
SOURCE_BUS_UNIT,
df.PSFacilityName,
lt.LOCATION,
lt.DESCR,
dl.BlueBinFlag,
DEMAND_DATE,
ORDER_NO
Order by DEMAND_DATE



END
GO
grant exec on tb_StatCalls to public
GO



--*********************************************************************************************
--Tableau Sproc  These load data into the datasources for Tableau
--*********************************************************************************************
--Updated GB 20180307 Altered Facility pulling based on multiple facilities

if exists (select * from dbo.sysobjects where id = object_id(N'tb_StatCallsLocation') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure tb_StatCallsLocation
GO

--exec tb_StatCallsLocation
CREATE PROCEDURE tb_StatCallsLocation
AS
BEGIN
SET NOCOUNT ON

declare @Facility int = (select ConfigValue from bluebin.Config where ConfigName = 'PS_DefaultFacility')
declare @FacilityName varchar(30) = (select PSFacilityName from bluebin.DimFacility where FacilityID = @Facility)

SELECT 
--case when @Facility is not null or @Facility <> '' then @Facility else ''end as FROM_TO_CMPY,
--case when @Facility is not null or @Facility <> '' then (select FacilityName from bluebin.DimFacility where FacilityID = @Facility) else ''end as FacilityName,
COALESCE(df.FacilityID,@Facility) as FROM_TO_CMPY,
COALESCE(df.PSFacilityName,@FacilityName) as FacilityName,
lt.LOCATION as LocationID,
lt.DESCR as LocationName,
ISNULL(dl.BlueBinFlag,0) as BlueBinFlag,
DEMAND_DATE       AS [Date],
COUNT(*) as StatCalls,
'' as Department,
'No' as WHSource

FROM   dbo.IN_DEMAND
       INNER JOIN dbo.LOCATION_TBL lt on IN_DEMAND.LOCATION = lt.LOCATION
	   LEFT JOIN bluebin.DimLocation dl ON lt.LOCATION = dl.LocationID
	   LEFT JOIN bluebin.DimFacility df on IN_DEMAND.BUSINESS_UNIT= df.FacilityName

WHERE  PICK_BATCH_ID = 0
       --AND BUSINESS_UNIT in (Select ConfigValue from bluebin.Config where ConfigName = 'PS_BUSINESSUNIT')
	   AND (BUSINESS_UNIT in (Select ConfigValue from bluebin.Config where ConfigName = 'PS_BUSINESSUNITSTAT') or SOURCE_BUS_UNIT in (Select ConfigValue from bluebin.Config where ConfigName = 'PS_BUSINESSUNIT'))
	   AND (IN_FULFILL_STATE in (select ConfigValue from bluebin.Config where ConfigName = 'PS_InFulfillState') or IN_FULFILL_STATE is null)
GROUP BY
--DimLocation.LocationID,
--DimLocation.LocationName,
df.FacilityID,
df.PSFacilityName,
lt.LOCATION,
lt.DESCR,
dl.BlueBinFlag,
DEMAND_DATE
Order by DEMAND_DATE




END
GO
grant exec on tb_StatCallsLocation to public
GO


--*********************************************************************************************
--Tableau Sproc  These load data into the datasources for Tableau
--*********************************************************************************************
--Updated GB 20180307 Altered Facility pulling based on multiple facilities

if exists (select * from dbo.sysobjects where id = object_id(N'tb_StatCallsDetail') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure tb_StatCallsDetail
GO


--exec tb_StatCallsDetail
CREATE PROCEDURE [dbo].[tb_StatCallsDetail]
AS
BEGIN
SET NOCOUNT ON

declare @Facility int = (select ConfigValue from bluebin.Config where ConfigName = 'PS_DefaultFacility')
declare @FacilityName varchar(30) = (select PSFacilityName from bluebin.DimFacility where FacilityID = @Facility)


SELECT
--case when @Facility is not null or @Facility <> '' then @Facility else ''end as FROM_TO_CMPY,
--case when @Facility is not null or @Facility <> '' then (select FacilityName from bluebin.DimFacility where FacilityID = @Facility) else ''end as FacilityName,
COALESCE(df.FacilityID,@Facility) as FROM_TO_CMPY,
COALESCE(df.PSFacilityName,@FacilityName) as FacilityName,
lt.LOCATION as LocationID,
lt.DESCR as LocationName,
INV_ITEM_ID as ItemID,
ORDER_NO as OrderNo,
DEMAND_DATE  AS [Date],
ORDER_INT_LINE_NO as LINE_NBR,
SUM((QTY_REQUESTED*-1)) as QUANTITY,
--QTY_REQUESTED as QUANTITY,
    'N/A' as Department,
case when ISNULL(dl.BlueBinFlag,0) = 1 then 'Yes' else 'No' end as BlueBinFlag,
case	when ISNULL(dl.BlueBinFlag,0) = 0 
		then case	when INV_ITEM_ID is null or INV_ITEM_ID = '' 
					then 'Not Managed Special' 
					else 'Not Managed Standard' end
		else 'Managed' end as Category,
0 as Cost,	--Need
case when ORDER_NO LIKE 'MSR%' then 'Yes' else 'No' end as WHSource


FROM   IN_DEMAND
       INNER JOIN LOCATION_TBL lt on IN_DEMAND.LOCATION = lt.LOCATION
	   LEFT JOIN bluebin.DimLocation dl ON lt.LOCATION = dl.LocationID
	   LEFT JOIN bluebin.DimFacility df on IN_DEMAND.BUSINESS_UNIT= df.FacilityName

WHERE  PICK_BATCH_ID = 0
       --AND BUSINESS_UNIT in (Select ConfigValue from bluebin.Config where ConfigName = 'PS_BUSINESSUNIT')
	   AND (BUSINESS_UNIT in (Select ConfigValue from bluebin.Config where ConfigName = 'PS_BUSINESSUNITSTAT') or SOURCE_BUS_UNIT in (Select ConfigValue from bluebin.Config where ConfigName = 'PS_BUSINESSUNIT'))
	   AND (IN_FULFILL_STATE in (select ConfigValue from bluebin.Config where ConfigName = 'PS_InFulfillState') or IN_FULFILL_STATE is null)
	   and DEMAND_DATE > getdate() -90
		--AND dl.BlueBinFlag = 1
Group by
df.FacilityID,
df.PSFacilityName,
lt.LOCATION,
lt.DESCR,
INV_ITEM_ID,
ORDER_NO,
DEMAND_DATE,
ORDER_INT_LINE_NO,
ISNULL(dl.BlueBinFlag,0)
Order by DEMAND_DATE,ORDER_NO,ORDER_INT_LINE_NO


END

GO
grant exec on tb_StatCallsDetail to public
GO

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
declare @FacilityName varchar(30) = (select PSFacilityName from bluebin.DimFacility where FacilityID = @Facility)
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
COALESCE(df.FacilityID,@Facility) AS COMPANY,
COALESCE(df.FacilityName,@FacilityName) AS FacilityName,
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

exec tb_LineVolume

END
GO
grant exec on tb_LineVolume to public
GO




--*********************************************************************************************
--Tableau Sproc  These load data into the datasources for Tableau
--*********************************************************************************************

if exists (select * from dbo.sysobjects where id = object_id(N'tb_ROILineVolume') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure tb_ROILineVolume
GO

--exec tb_ROILineVolume

CREATE PROCEDURE tb_ROILineVolume


AS
BEGIN
SET NOCOUNT ON

declare @Facility int = (select ConfigValue from bluebin.Config where ConfigName = 'PS_DefaultFacility')
declare @FacilityName varchar(30) = (select PSFacilityName from bluebin.DimFacility where FacilityID = @Facility)
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
         WHERE   PO_LN.CANCEL_STATUS NOT IN ( 'X', 'D' )

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
       Picks.SCHED_DTTM as OrderDate,
       Picks.PICK_CONFIRM_DTTM as CloseDate,
       Cast(Picks.QTY_PICKED AS INT) AS OrderQty, 
	UNIT_OF_MEASURE as OrderUOM,
	Picks.ACCOUNT

FROM   dbo.IN_DEMAND Picks

		LEFT JOIN FirstScans
		ON Picks.INV_ITEM_ID = FirstScans.ItemID AND Picks.LOCATION = FirstScans.LocationID
WHERE   (CANCEL_DTTM IS NULL  or CANCEL_DTTM < '1900-01-02')
	   AND DEMAND_DATE >= ISNULL(FirstScanDate,'1900-01-02')
	   )
   


select 
COALESCE(df.FacilityID,@Facility) AS COMPANY,
COALESCE(df.FacilityName,@FacilityName) AS FacilityName,
l.OrderDate as [Date],
'BlueBin' AS LineType,
l.LocationID AS Location,
dl.LocationName as LocationName,

case when hdbj.OldLocationID = 'NEW' then hdbj.NewLocationID + '(N)'
else hdbj.OldLocationID + '(O) & ' +  hdbj.NewLocationID + '(N)' 
end as LocationLinking,
1 AS LineCount
from Lines l

inner join bluebin.DimLocation dl on  l.LocationID = dl.LocationID
inner join bluebin.DimFacility df on rtrim(dl.LocationFacility) = rtrim(df.FacilityID)
inner join bluebin.HistoricalDimBinJoin hdbj on l.LocationID = hdbj.NewLocationID

UNION ALL

select 
COALESCE(df.FacilityID,@Facility) AS COMPANY,
COALESCE(df.FacilityName,@FacilityName) AS FacilityName,
l.OrderDate as [Date],
'BlueBin' AS LineType,
l.LocationID AS Location,
dl.LocationName as LocationName,

case when hdbj.OldLocationID = 'NEW' then hdbj.NewLocationID + '(N)'
else hdbj.OldLocationID + '(O) & ' +  hdbj.NewLocationID + '(N)' 
end as LocationLinking,
1 AS LineCount
from Lines l
inner join bluebin.DimLocation dl on  l.LocationID = dl.LocationID
inner join bluebin.DimFacility df on rtrim(dl.LocationFacility) = rtrim(df.FacilityID)
inner join bluebin.HistoricalDimBinJoin hdbj on l.LocationID = hdbj.OldLocationID



END
GO
grant exec on tb_ROILineVolume to public
GO
