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


--*********************************************************************************************
--Tableau Sproc  These load data into the datasources for Tableau
--*********************************************************************************************
--Updated GB 20180307  Updated the INV_ITEM_ID pull to r and changd Facility Pull for multiple

IF EXISTS ( SELECT  *
            FROM    sys.objects
            WHERE   object_id = OBJECT_ID(N'tb_BinSequence')
                    AND type IN ( N'P', N'PC' ) ) 

--exec tb_BinSequence
DROP PROCEDURE  tb_BinSequence
GO

CREATE PROCEDURE tb_BinSequence

AS

BEGIN

;

/*
select * from REQ_LINE_SHIP where REQ_ID = '0000089501' order by LINE_NBR
select * from PO_LINE_DISTRIB where REQ_ID like '%89501%' order by LINE_NBR
select * from REQ_LN_DISTRIB where REQ_ID like '%89501%' order by LINE_NBR
*/
SET NOCOUNT ON


;

declare @Facility int = (select ConfigValue from bluebin.Config where ConfigName = 'PS_DefaultFacility')
declare @FacilityName varchar(30) = (select PSFacilityName from bluebin.DimFacility where FacilityID = @Facility)
;
WITH A as
(
select 
Row_number()
         OVER(
           Partition BY db.BinKey
           ORDER BY p.CREATION_DATE ASC,p.REQ_NUMBER,p.LINE_NBR) AS Scanseq,
		   --ORDER BY p.REC_ACT_DATE ASC,p.PO_NUMBER,p.LINE_NBR) AS Scanseq,
p.COMPANY as FacilityID,
df.FacilityName,
p.REQ_LOCATION as LocationID,
dl.LocationName,
p.ITEM as ItemID,
di.ItemDescription,
db.BinSequence,
db.BinKey,
p.CREATION_DATE as OrderDate,
p.REQ_NUMBER as OrderNum,
--p.REC_ACT_DATE as OrderDate,
--p.PO_NUMBER as OrderNum,
p.LINE_NBR as OrderLineNum,
p.QUANTITY as OrderQty,
p.CUSTOM_C1_C as OrderSequence

from 
(select COALESCE(df.FacilityID,@Facility) as COMPANY, 
		r.INV_ITEM_ID as ITEM,
		rs.REQ_DT AS CREATION_DATE,
		rs.REQ_ID as REQ_NUMBER,
		rs.LINE_NBR,
		'' as QUANTITY,
		rs.CUSTOM_C1_C,
		po.LOCATION as REQ_LOCATION 
		from REQ_LINE_SHIP rs
		inner join REQ_LN_DISTRIB po on right(('0000000000' + po.REQ_ID),10) = rs.REQ_ID and po.LINE_NBR = rs.LINE_NBR and po.BUSINESS_UNIT = rs.BUSINESS_UNIT
		left join REQ_LINE r on right(('0000000000' + r.REQ_ID),10) = rs.REQ_ID and r.LINE_NBR = rs.LINE_NBR and r.BUSINESS_UNIT = rs.BUSINESS_UNIT
		left join bluebin.DimFacility df on rs.BUSINESS_UNIT = df.FacilityName 
			where CUSTOM_C1_C in ('A','B')) p
			
--(select p.COMPANY, p.ITEM,p.REC_ACT_DATE,p.PO_NUMBER,p.LINE_NBR,p.QUANTITY,p.PO_USER_FLD_4,posrc.REQ_LOCATION 
--		from POLINE p 
--			inner join POLINESRC posrc on p.PO_NUMBER = posrc.PO_NUMBER and p.LINE_NBR = posrc.LINE_NBR 
--			where p.PO_USER_FLD_4 in ('A','B')) p
inner join bluebin.DimBin db on p.COMPANY = db.BinFacility and p.REQ_LOCATION = db.LocationID and p.ITEM = db.ItemID
inner join bluebin.DimFacility df on db.BinFacility = df.FacilityID 
inner join bluebin.DimLocation dl on db.LocationID = dl.LocationID
inner join bluebin.DimItem di on db.ItemID = di.ItemID

where CUSTOM_C1_C in ('A','B') --and QUANTITY <> CXL_QTY
and p.CREATION_DATE > getdate() -90
--and p.REC_ACT_DATE > getdate() -90
group by
p.COMPANY,
df.FacilityName,
p.REQ_LOCATION ,
dl.LocationName,
p.ITEM,
di.ItemDescription,
db.BinSequence,
db.BinKey,
p.CREATION_DATE,
p.REQ_NUMBER,

p.LINE_NBR,
p.QUANTITY,
p.CUSTOM_C1_C
)

select 
IDENTITY (INT, 1, 1) AS RecID, 
A.*,
CASE WHEN A.Scanseq = '1' THEN 'N/A' ELSE
	CASE WHEN A.OrderSequence = b.OrderSequence THEN 'No' ELSE 'Yes' END END AS InSequence,

CASE 
   WHEN A.Scanseq = '1' THEN 0  -- 'N/A' 
ELSE
	CASE 
	   WHEN A.OrderSequence = b.OrderSequence THEN 1  -- 'No' 
	ELSE 0  -- 'Yes' 
	END 
END AS OutOfSequenceValue,
0 AS OutofSequenceCount,

CASE
   WHEN A.BinSequence LIKE '%CD' THEN 'Card'
   ELSE 'Bin'
END AS BinOrCard 

into #temp01

from A
left join A b on A.BinKey = b.BinKey and A.Scanseq = b.Scanseq+1
-- order by 
-- A.BinKey,A.Scanseq

ALTER TABLE #temp01
ADD OutofSequenceRecentDate DATETIME

UPDATE
   t1
SET
   OutofSequenceCount = t2.OutofSequenceCount
FROM
   #temp01 t1
      INNER JOIN 
         (SELECT ItemID, OrderDate, SUM(OutofSequenceValue) AS 'OutofSequenceCount' 
		  FROM #temp01 
		  GROUP BY ItemID, OrderDate
		 ) AS t2
ON 
   t1.ItemID = t2.ItemID AND
   t1.OrderDate = t2.OrderDate 
WHERE
   t1.RecID IN 
(SELECT
   c.RecID
 FROM
    (SELECT ItemID, OrderDate, MAX(RecID) AS 'RecID' 
	 FROM #temp01 
	 WHERE OutOfSequenceValue = 1
	 GROUP BY ItemID, OrderDate
    ) AS c
)

UPDATE
   t1
SET
   OutofSequenceRecentDate = t2.OrderDate
FROM
   #temp01 t1
      INNER JOIN (SELECT ItemID, LocationID, MAX(OrderDate) AS 'OrderDate' 
	              FROM #temp01 
				  WHERE OutOfSequenceValue = 1
				  GROUP BY ItemID, LocationID
				 ) AS t2
         ON
            t1.ItemID = t2.ItemID AND
            t1.LocationID = t2.LocationID 
WHERE
   t1.RecID IN 
(SELECT
   c.RecID
 FROM
    (SELECT ItemID, LocationID, MAX(RecID) AS 'RecID' 
	 FROM #temp01 
	 WHERE OutOfSequenceValue = 1
	 GROUP BY ItemID, LocationID
    ) AS c
)

   

SELECT *  FROM #temp01 
-- where itemid = 1640 and OrderDate = '5/23/17'
-- order by itemid, OrderDate

--where itemid = '5014552' 
-- order by itemid, LocationID
ORDER BY BinKey, Scanseq

DROP TABLE #temp01

END

GO

grant exec on tb_BinSequence to public
GO



/*************************************************

			FactScan

*************************************************/
--Edited 20180209 GB
--Edited GB 20180307.  Updated PO_ID to account for leading zeroes with NYCH

IF EXISTS ( SELECT  *
            FROM    sys.objects
            WHERE   object_id = OBJECT_ID(N'etl_FactScan')
                    AND type IN ( N'P', N'PC' ) ) 

DROP PROCEDURE  etl_FactScan
GO

CREATE PROCEDURE etl_FactScan
--exec etl_FactScan
AS

/*****************************		DROP FactScan		*******************************/

BEGIN Try
    DROP TABLE bluebin.FactScan
END Try

BEGIN Catch
END Catch

--select * from PO_LINE_DISTRIB where LOCATION like '%BB%'
--select * from PO_LINE where PO_ID in (select PO_ID from PO_LINE_DISTRIB where LOCATION like '%BB%')
--select * from PO_HDR where PO_ID in (select PO_ID from PO_LINE_DISTRIB where LOCATION like '%BB%')


--**************************
declare @DefaultLT int = (Select max(ConfigValue) from bluebin.Config where ConfigName = 'DefaultLeadTime')
declare @POTimeAdjust int = (Select max(ConfigValue) from bluebin.Config where ConfigName = 'PS_POTimeAdjust')
;
WITH FirstScans
     AS (
/* Original Query	 
	 SELECT INV_CART_ID      AS LocationID,
                INV_ITEM_ID      AS ItemID,
                Min(DEMAND_DATE) AS FirstScanDate
         FROM   dbo.CART_CT_INF_INV
         WHERE  CART_COUNT_QTY > 0
                AND PROCESS_INSTANCE > 0
         GROUP  BY INV_CART_ID,
                   INV_ITEM_ID
				   */
		select
		LocationID,
		ItemID,
		COALESCE(DEMAND_DATE,SCHED_DTTM,LOC_DATE,BIN_DATE,NULL) as FirstScanDate
		from 
				(
				SELECT db.LocationID,
					   db.ItemID,
					   lt.LOC_DATE,
						Min(ct.DEMAND_DATE) AS DEMAND_DATE,
						min(id.SCHED_DTTM) as SCHED_DTTM,
						min(db.BinGoLiveDate) as BIN_DATE
				 FROM   bluebin.DimBin db
				 LEFT JOIN dbo.CART_CT_INF_INV ct on db.LocationID = ct.INV_CART_ID and db.ItemID = ct.INV_ITEM_ID and ct.CART_COUNT_QTY > 0 AND ct.PROCESS_INSTANCE > 0
				 LEFT JOIN IN_DEMAND id on db.LocationID = id.LOCATION and db.ItemID = id.INV_ITEM_ID
				 LEFT JOIN (Select INV_CART_ID,min(DEMAND_DATE) as LOC_DATE from dbo.CART_CT_INF_INV where CART_COUNT_QTY > 0 AND PROCESS_INSTANCE > 0 group by INV_CART_ID) lt on db.LocationID = lt.INV_CART_ID 
				 GROUP  BY 
				 db.LocationID,
				 db.ItemID,
				 lt.LOC_DATE
				  ) a 
				   
				   )
				   
				   ,

--**************************
Orders
     AS (
	 SELECT Row_number()
                  OVER(
                    PARTITION BY Bins.ItemID, PO_LN_DST.LOCATION, PO_HDR.PO_DT
                    ORDER BY PO_LN.PO_ID, PO_LN.LINE_NBR) AS DailySeq,
                Bins.BinKey,
				--Bins.BinGoLiveDate,
                Bins.ItemID									AS ItemID, --Original PO_LN.INV_ITEM_ID
                PO_LN_DST.LOCATION                        AS LocationID,
                PO_LN.PO_ID                               AS OrderNum,
                PO_LN.LINE_NBR                            AS LineNum,
                SHIP.RECEIPT_DTTM                         AS CloseDate,
                QTY_PO                                    AS OrderQty,
                PO_LN.UNIT_OF_MEASURE                     AS OrderUOM,
                DATEADD(hour,@POTimeAdjust,PO_HDR.PO_DT) as PO_DT
				--PO_HDR.PO_DT
         FROM   dbo.PO_LINE_DISTRIB PO_LN_DST
                INNER JOIN dbo.PO_LINE PO_LN
                        ON PO_LN_DST.PO_ID = PO_LN.PO_ID
                           AND PO_LN_DST.LINE_NBR = PO_LN.LINE_NBR
                INNER JOIN dbo.PO_HDR
                        ON PO_LN.PO_ID = PO_HDR.PO_ID
							AND PO_LN.BUSINESS_UNIT = PO_HDR.BUSINESS_UNIT
                INNER JOIN bluebin.DimBin Bins
                        ON RIGHT(('000000000000000000' + PO_LN.INV_ITEM_ID),18) = RIGHT(('000000000000000000' + Bins.ItemID),18) 
                           AND Bins.LocationID = PO_LN_DST.LOCATION
                LEFT JOIN
					(select PO_ID,LINE_NBR,max(RECEIPT_DTTM) as RECEIPT_DTTM from dbo.RECV_LN_SHIP group by PO_ID,LINE_NBR) SHIP
						ON PO_LN.PO_ID = SHIP.PO_ID
                          AND PO_LN.LINE_NBR = SHIP.LINE_NBR
				--LEFT JOIN dbo.RECV_LN_SHIP SHIP
    --                   ON PO_LN.PO_ID = SHIP.PO_IDselect * from RECV_LN_SHIP 
    --                      AND PO_LN.LINE_NBR = SHIP.LINE_NBR
                LEFT JOIN FirstScans
                       ON RIGHT(('000000000000000000' + PO_LN.INV_ITEM_ID),18) = RIGHT(('000000000000000000' + FirstScans.ItemID),18)
                          AND PO_LN_DST.LOCATION = FirstScans.LocationID
         WHERE  (LEFT(PO_LN_DST.LOCATION, 2) COLLATE DATABASE_DEFAULT IN (SELECT [ConfigValue] FROM   [bluebin].[Config] WHERE  [ConfigName] = 'REQ_LOCATION' AND Active = 1) 
				or PO_LN_DST.LOCATION COLLATE DATABASE_DEFAULT in (Select REQ_LOCATION from bluebin.ALT_REQ_LOCATION))
                AND ISNULL(PO_LN.CANCEL_STATUS,'') NOT IN ( 'X', 'D', 'PX' )
				--AND PO_LN_DST.LOCATION = '16401PED02' and PO_LN.INV_ITEM_ID = '100177' and PO_LN.PO_ID = '0000008230' 
				--and DATEADD(hour,@POTimeAdjust,PO_HDR.PO_DT) > getdate() -5
                --AND PO_LN_DST.BUSINESS_UNIT_GL = 209
		GROUP BY 
				Bins.BinKey,
				PO_LN_DST.LOCATION,
				Bins.ItemID, --Original PO_LN.INV_ITEM_ID
                PO_LN.PO_ID,
                PO_LN.LINE_NBR,
                SHIP.RECEIPT_DTTM,
				QTY_PO,
                PO_LN.UNIT_OF_MEASURE,
                PO_HDR.PO_DT
				)
				
				
				,



--**************************
CartCounts
     AS (SELECT Row_number()
                  OVER(
                    PARTITION BY INV_CART_ID, INV_ITEM_ID, DEMAND_DATE
                    ORDER BY LAST_DTTM_UPDATE) AS DailySeq,
                INV_CART_ID                    AS LocationID,
                INV_ITEM_ID					   AS ItemID,
                DEMAND_DATE                    AS PO_DT,
                LAST_DTTM_UPDATE               AS SCAN_DATE
				--CART_COUNT_QTY
         FROM   dbo.CART_CT_INF_INV
         WHERE  --CART_COUNT_QTY <> 0 AND
                --AND CART_REPLEN_OPT = '02'
				(LEFT(INV_CART_ID, 2) COLLATE DATABASE_DEFAULT IN (SELECT [ConfigValue] FROM   [bluebin].[Config] WHERE  [ConfigName] = 'REQ_LOCATION' AND Active = 1) 
				or INV_CART_ID COLLATE DATABASE_DEFAULT in (Select REQ_LOCATION from bluebin.ALT_REQ_LOCATION))),
--**************************
tmpLines AS (
SELECT a.BinKey,
       --a.BinGoLiveDate,
	   a.ItemID,
       a.LocationID,
       a.OrderNum,
       a.LineNum,
       COALESCE(b.SCAN_DATE,a.PO_DT)                 AS OrderDate,
       a.CloseDate,
       a.OrderQty,
       a.OrderUOM,
	   'PO' as OrderType,
		'No' as Cancelled
FROM   Orders a
       LEFT JOIN CartCounts b
               ON a.LocationID = b.LocationID
                  AND a.ItemID = b.ItemID
                  AND a.PO_DT = b.PO_DT
                  AND a.DailySeq = b.DailySeq 

UNION ALL
SELECT Bins.BinKey,
--Bins.BinGoLiveDate,
       INV_ITEM_ID as ItemID,
       LOCATION as LocationID,
       Picks.ORDER_NO as OrderNum,
       Picks.ORDER_INT_LINE_NO as LineNum,
       Picks.SCHED_DTTM as OrderDate,
       Picks.PICK_CONFIRM_DTTM as CloseDate,
       Cast(Picks.QTY_REQUESTED AS INT) AS OrderQty,
	   UNIT_OF_MEASURE as OrderUOM,
	   CASE
         WHEN Picks.ORDER_NO LIKE 'MSR%' THEN 'MSR'
         ELSE 'Pick' end as OrderType,
		case when IN_FULFILL_STATE = '70' and QTY_PICKED = '0' or IN_FULFILL_STATE = '90' then 'Yes' else 'No' end as Cancelled

FROM   dbo.IN_DEMAND Picks
       INNER JOIN bluebin.DimBin Bins
               ON Picks.LOCATION = Bins.LocationID
                  AND Picks.INV_ITEM_ID = Bins.ItemID
		LEFT JOIN FirstScans
		ON Picks.INV_ITEM_ID = FirstScans.ItemID AND Picks.LOCATION = FirstScans.LocationID
WHERE  (LEFT(LOCATION, 2) COLLATE DATABASE_DEFAULT IN (SELECT [ConfigValue] FROM   [bluebin].[Config] WHERE  [ConfigName] = 'REQ_LOCATION' AND Active = 1) 
		or LOCATION COLLATE DATABASE_DEFAULT in (Select REQ_LOCATION from bluebin.ALT_REQ_LOCATION))
       AND (CANCEL_DTTM IS NULL  or CANCEL_DTTM < '1900-01-02')
	   AND DEMAND_DATE >= FirstScanDate --ISNULL(FirstScanDate,Bins.BinGoLiveDate)

	   )
	   
	   ,
--**************************	   
tmpOrders 
	AS (
	SELECT Row_number()
         OVER(
           Partition BY BinKey
           ORDER BY OrderDate) AS OrderSeq,
		   *
       --*,
       --CASE
       --  WHEN OrderNum LIKE 'MSR%' THEN 'MSR'
       --  ELSE 'PO'
       --END                     AS OrderType

FROM   tmpLines
where Cancelled = 'No'
),

--**************************
Scans
     AS (
  SELECT Row_number()
                  OVER(
                    Partition BY o.BinKey
                    ORDER BY o.OrderDate DESC) AS Scanseq,
					Row_number()
                  OVER(
                    Partition BY o.BinKey
                    ORDER BY o.OrderDate ASC) AS ScanHistseq,
                o.BinKey,
				--o.BinGoLiveDate,
                o.LocationID,
                o.ItemID,
                '' as OrderTypeID,
                o.OrderType,
                '' as CartCountNum,
                o.OrderNum,
                o.LineNum,
				o.OrderUOM,
                o.OrderQty,
                o.OrderDate,
                o.CloseDate
        FROM   
               tmpOrders o
			    
				)--select * from Scans where BinKey = '825' order by OrderDate


				
SELECT a.Scanseq,
		a.ScanHistseq,
	   a.BinKey,
       c.LocationKey,
       d.ItemKey,
	   db.BinGoLiveDate,
       --COALESCE(a.OrderTypeID, '-') as OrderTypeID,  
       --COALESCE(a.CartCountNum, 0) as CartCountNum --Old PS field,
       a.OrderNum,
       a.LineNum,
	   case when a.OrderType = 'MSR' or a.OrderType = 'Pick' then 'I'
			else 'N' end as ItemType,
	   a.OrderUOM,
       Cast(a.OrderQty AS INT) AS OrderQty,
       a.OrderDate,
       case when a.CloseDate < '1900-01-01' then NULL else a.CloseDate end as OrderCloseDate,
       b.OrderDate             AS PrevOrderDate,
       case when b.CloseDate < '1900-01-01' then NULL else b.CloseDate end AS PrevOrderCloseDate,
	   1 as Scan,
       CASE
         WHEN Datediff(Day, b.OrderDate, a.OrderDate) < COALESCE(db.BinLeadTime,@DefaultLT,3) THEN 1
         ELSE 0
       END                     AS HotScan,
       CASE
         WHEN a.OrderDate < COALESCE(b.CloseDate, Getdate())
              AND a.ScanHistseq > (select ConfigValue + 1 from bluebin.Config where ConfigName = 'ScanThreshold') THEN 1 --When looking for stockouts you have to take the scanseq 2 after the ignored one
         ELSE 0
       END                     AS StockOut

into bluebin.FactScan
FROM   Scans a
       INNER JOIN bluebin.DimBin db on a.BinKey = db.BinKey
	   LEFT JOIN Scans b
              ON a.BinKey = b.BinKey
                 AND a.Scanseq = b.Scanseq - 1
       LEFT JOIN bluebin.DimLocation c
              ON a.LocationID = c.LocationID
       LEFT JOIN bluebin.DimItem d
              ON a.ItemID = d.ItemID
	   
WHERE  a.OrderDate >= db.BinGoLiveDate and a.OrderUOM <> '0' and a.OrderQty <> '0'--and a.OrderDate > getdate() -360--and d.ItemKey = '18710' and 
--and a.OrderNum = '0000383593'
Order by BinKey,ScanHistseq asc


GO

UPDATE etl.JobSteps
SET LastModifiedDate = GETDATE()
WHERE StepName = 'FactScan'

GO

/*********************************************************************

		FactIssue

*********************************************************************/

IF EXISTS ( SELECT  *
            FROM    sys.objects
            WHERE   object_id = OBJECT_ID(N'etl_FactIssue')
                    AND type IN ( N'P', N'PC' ) ) 

DROP PROCEDURE  etl_FactIssue
GO

CREATE PROCEDURE etl_FactIssue

AS

/****************************		DROP FactIssue ***********************************/
 BEGIN TRY
 DROP TABLE bluebin.FactIssue
 END TRY
 BEGIN CATCH
 END CATCH

 /*******************************	CREATE FactIssue	*********************************/
 

declare @Facility int = (select ConfigValue from bluebin.Config where ConfigName = 'PS_DefaultFacility')
declare @FacilityName varchar(30) = (select PSFacilityName from bluebin.DimFacility where FacilityID = @Facility)

  
  SELECT 

	   COALESCE(df2.FacilityID,@Facility) as FacilityKey,
		--case when @Facility is not null or @Facility <> '' then @Facility else '' end as FacilityKey,
	   Picks.BUSINESS_UNIT AS LocationID,
       b.LocationKey AS LocationKey,

       c.LocationKey AS ShipLocationKey,
       COALESCE(df.FacilityID,@Facility) as ShipFacilityKey,
	   --case when @Facility is not null or @Facility <> '' then @Facility else '' end as ShipFacilityKey,
       ISNULL(c.BlueBinFlag,0) as BlueBinFlag,
	   d.ItemKey AS ItemKey,
       '' AS  SourceSystem,
       Picks.ORDER_NO AS ReqNumber,
       Picks.ORDER_INT_LINE_NO AS ReqLineNumber,
       Picks.DEMAND_DATE AS IssueDate,
       Picks.UNIT_OF_MEASURE AS UOM,
       '' AS UOMMult,
       Picks.QTY_PICKED AS  IssueQty,
       case when PICK_BATCH_ID = 0 then 1 else 0 end AS StatCall,
       1  AS IssueCount
INTO bluebin.FactIssue
FROM   dbo.IN_DEMAND Picks
	   LEFT JOIN bluebin.DimLocation b ON Picks.BUSINESS_UNIT = b.LocationID AND @Facility = b.LocationFacility
       LEFT JOIN bluebin.DimLocation c ON Picks.LOCATION = c.LocationID 
       LEFT JOIN bluebin.DimItem d ON Picks.INV_ITEM_ID = d.ItemID
	   left join bluebin.DimFacility df on Picks.SOURCE_BUS_UNIT = df.FacilityName
	   left join bluebin.DimFacility df2 on Picks.BUSINESS_UNIT = df2.FacilityName
		
		
			   
WHERE  
CANCEL_DTTM IS NULL or CANCEL_DTTM < '1900-01-02'
order by 9,10
	
GO




UPDATE etl.JobSteps
SET LastModifiedDate = GETDATE()
WHERE StepName = 'FactIssue'

GO

Use Trinity_PS
delete from  JRNL_LN where JOURNAL_DATE > getdate() -20
delete from JRNL_HEADER
delete from GL_ACCOUNT_TBL
delete from DEPT_TBL
delete from BUS_UNIT_TBL_FS

truncate table JRNL_LN
truncate table JRNL_HEADER
truncate table GL_ACCOUNT_TBL
truncate table DEPT_TBL
truncate table BUS_UNIT_TBL_FS