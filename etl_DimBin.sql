/***********************************************************

			DimBin

***********************************************************/
--Updated GB 20170423 Added logic on the costing to match with WH report, and Company to Bin Added Date (Trinity)

IF EXISTS ( SELECT  *
            FROM    sys.objects
            WHERE   object_id = OBJECT_ID(N'etl_DimBin')
                    AND type IN ( N'P', N'PC' ) ) 

DROP PROCEDURE  etl_DimBin
GO

CREATE PROCEDURE etl_DimBin

AS

--exec etl_DimBin select * from bluebin.DimBin
/***************************		DROP DimBin		********************************/
BEGIN TRY
    DROP TABLE bluebin.DimBin
END TRY

BEGIN CATCH
END CATCH


--/***************************		CREATE Temp Tables		*************************/

/* Old Bin Added Dates
SELECT REQ_LOCATION,
       Min(CREATION_DATE) AS BinAddedDate
INTO   #BinAddDates
FROM   REQLINE a INNER JOIN bluebin.DimLocation b ON a.REQ_LOCATION = b.LocationID
WHERE  b.BlueBinFlag = 1
GROUP  BY REQ_LOCATION
*/

--**New Bin Added Dates
select 
il.COMPANY,
il.LOCATION as REQ_LOCATION,
il.ITEM,
--item.BinAddedDate,
--il.ADDED_DATE,
--loc.LocAddedDate,
--case when il.ADDED_DATE > loc.LocAddedDate then COALESCE(item.BinAddedDate,il.ADDED_DATE) else COALESCE(loc.LocAddedDate,il.ADDED_DATE) end as BinAddedDate
case 
	when item.BinAddedDate is null 
	then case
			when il.ADDED_DATE > loc.LocAddedDate 
			then il.ADDED_DATE 
			else COALESCE(loc.LocAddedDate,il.ADDED_DATE) end
	else case 
			when il.ADDED_DATE > item.BinAddedDate 
			then item.BinAddedDate 
			else case
				when il.ADDED_DATE > loc.LocAddedDate 
				then il.ADDED_DATE 
				else COALESCE(loc.LocAddedDate,il.ADDED_DATE) end end 
	end as BinAddedDate
INTO   #BinAddDates
from ITEMLOC il
	INNER JOIN 
	(SELECT REQ_LOCATION,
		   Min(CREATION_DATE) AS LocAddedDate
	FROM   REQLINE a INNER JOIN bluebin.DimLocation b ON a.REQ_LOCATION = b.LocationID
	WHERE  b.BlueBinFlag = 1
	GROUP  BY REQ_LOCATION) loc on il.LOCATION = loc.REQ_LOCATION 
	LEFT JOIN 
	(SELECT REQ_LOCATION,ITEM,
		   Min(CREATION_DATE) AS BinAddedDate
	FROM   REQLINE a INNER JOIN bluebin.DimLocation b ON a.REQ_LOCATION = b.LocationID
	WHERE  b.BlueBinFlag = 1
	GROUP  BY REQ_LOCATION,ITEM) item on il.LOCATION = item.REQ_LOCATION and il.ITEM = item.ITEM
--WHERE il.ITEM in ('239839') and il.LOCATION = 'KBICU' 


SELECT Row_number()
         OVER(
           Partition BY ITEM, ENTERED_UOM
           ORDER BY CREATION_DATE DESC) AS Itemreqseq,
       ITEM,
       ENTERED_UOM,
       case when UNIT_COST = 0 then NULL else UNIT_COST end as UNIT_COST
INTO   #ItemReqs
FROM   REQLINE a INNER JOIN bluebin.DimLocation b ON ltrim(rtrim(a.REQ_LOCATION)) = ltrim(rtrim(b.LocationID))
WHERE  b.BlueBinFlag = 1 

SELECT Row_number()
         OVER(
           Partition BY ITEM, ENT_BUY_UOM
           ORDER BY PO_NUMBER DESC) AS ItemOrderSeq,
       ITEM,
       ENT_BUY_UOM,
       case when ENT_UNIT_CST = 0 then NULL else ENT_UNIT_CST end as ENT_UNIT_CST
INTO   #ItemOrders
FROM   POLINE
WHERE  ITEM_TYPE IN ( 'I', 'N' )
       AND ITEM IN (SELECT DISTINCT ITEM
                    FROM   ITEMLOC a INNER JOIN bluebin.DimLocation b ON ltrim(rtrim(a.LOCATION)) = ltrim(rtrim(b.LocationID))
WHERE  b.BlueBinFlag = 1)

select ITEM,
sum(ENT_UNIT_CST)/max(ItemOrderSeq) as ENT_UNIT_CST 
into #ItemOrders2
from 
(
SELECT Row_number()
         OVER(
           Partition BY ITEM--, ENT_BUY_UOM
           ORDER BY PO_NUMBER DESC) AS ItemOrderSeq,
       ITEM,
	   ENT_UNIT_CST/EBUY_UOM_MULT as ENT_UNIT_CST
FROM   POLINE
WHERE  ITEM_TYPE IN ( 'I', 'N' ) and LOCATION in (Select ConfigValue from bluebin.Config where ConfigName = 'LOCATION')
--and ITEM = '00107'
) a
group by a.ITEM

SELECT distinct 
	a.COMPANY,a.ITEM,
       a.GL_CATEGORY,
       max(b.ISS_ACCOUNT) as ISS_ACCOUNT--,a.LOCATION
INTO   #ItemAccounts
FROM   ITEMLOC a 
		LEFT JOIN ICCATEGORY b
              ON a.GL_CATEGORY = b.GL_CATEGORY
                 AND a.LOCATION = b.LOCATION
WHERE  
a.LOCATION in (select ConfigValue from bluebin.Config where ConfigName = 'LOCATION') 
and a.ACTIVE_STATUS = 'A' 
group by a.COMPANY,a.GL_CATEGORY,a.ITEM
--order by a.ITEM
       --

	   




SELECT distinct 
i.COMPANY,i.ITEM,
case when c.LAST_ISS_COST = 0 then NULL else c.LAST_ISS_COST end as LAST_ISS_COST
INTO   #ItemStore
FROM   ITEMLOC i
left join (select ITEMLOC.COMPANY,ITEMLOC.ITEM,max(ITEMLOC.LAST_ISS_COST) as LAST_ISS_COST from ITEMLOC
				inner join (select COMPANY,ITEM,max(LAST_ISSUE_DT) as t from ITEMLOC group by COMPANY,ITEM) cost on ITEMLOC.COMPANY = cost.COMPANY and ITEMLOC.ITEM = cost.ITEM and ITEMLOC.LAST_ISSUE_DT = cost.t
				group by ITEMLOC.COMPANY,ITEMLOC.ITEM ) c on i.COMPANY = c.COMPANY and i.ITEM = c.ITEM
WHERE  i.LOCATION in (select ConfigValue from bluebin.Config where ConfigName = 'LOCATION')  and i.ACTIVE_STATUS = 'A'  
--and i.ITEM = '03728'
--order by i.ITEM  select * from ITEMLOC where ITEM = '03728'

SELECT distinct ITEM,CONSIGNMENT_FL 
INTO #Consignment
FROM ITEMMAST
WHERE  ITEM in (select ITEM from ITEMLOC where LOCATION in (select ConfigValue from bluebin.Config where ConfigName = 'LOCATION')) 
order by ITEM


/***********************************		CREATE	DimBin		***********************************/

SELECT Row_number()
             OVER(
               ORDER BY ITEMLOC.LOCATION, ITEMLOC.ITEM)                                               AS BinKey,
			   ITEMLOC.COMPANY																			AS BinFacility,
           ITEMLOC.ITEM                                                                               AS ItemID,
           ITEMLOC.LOCATION                                                                           AS LocationID,
           PREFER_BIN                                                                                 AS BinSequence,
		   		   	CASE WHEN ISNUMERIC(left(PREFER_BIN,1))=1 then LEFT(PREFER_BIN,2) 
				else CASE WHEN PREFER_BIN LIKE '[A-Z][A-Z]%' THEN LEFT(PREFER_BIN, 2) ELSE LEFT(PREFER_BIN, 1) END END as BinCart,
			CASE WHEN ISNUMERIC(left(PREFER_BIN,1))=1 then SUBSTRING(PREFER_BIN, 3, 1) 
				else CASE WHEN PREFER_BIN LIKE '[A-Z][A-Z]%' THEN SUBSTRING(PREFER_BIN, 3, 1) ELSE SUBSTRING(PREFER_BIN, 2,1) END END as BinRow,
			CASE WHEN ISNUMERIC(left(PREFER_BIN,1))=1 then SUBSTRING(PREFER_BIN, 4, 2)
				else CASE WHEN PREFER_BIN LIKE '[A-Z][A-Z]%' THEN SUBSTRING (PREFER_BIN,4,2) ELSE SUBSTRING(PREFER_BIN, 3,2) END END as BinPosition,	
			CASE
				WHEN PREFER_BIN LIKE 'CARD%' THEN 'WALL'
					ELSE 
						CASE WHEN ISNUMERIC(left(PREFER_BIN,1))=1 then RIGHT(PREFER_BIN,2) 
							else CASE WHEN PREFER_BIN LIKE '[A-Z][A-Z]%' THEN RIGHT(PREFER_BIN, 2) ELSE RIGHT(PREFER_BIN, 3) END END
           END                                                                                        AS BinSize,
           UOM                                                                                        AS BinUOM,
           REORDER_POINT                                                                              AS BinQty,
           CASE
             WHEN LEADTIME_DAYS = 0 or LEADTIME_DAYS is null THEN (Select max(ConfigValue) from bluebin.Config where ConfigName = 'DefaultLeadTime')
             ELSE LEADTIME_DAYS
           END                                                                                        AS BinLeadTime,
           #BinAddDates.BinAddedDate                                                                  AS BinGoLiveDate,
           COALESCE(COALESCE(#ItemReqs.UNIT_COST, #ItemOrders.ENT_UNIT_CST), #ItemStore.LAST_ISS_COST, #ItemOrders2.ENT_UNIT_CST,0) AS BinCurrentCost,
           CASE
			 WHEN UPPER(ltrim(rtrim(ITEMLOC.USER_FIELD1))) in (Select ConfigValue from bluebin.Config where ConfigName = 'ConsignmentFlag') OR #Consignment.CONSIGNMENT_FL = 'Y'  THEN 'Y'
             ELSE 'N'
           END                                                                                        AS BinConsignmentFlag,
           #ItemAccounts.ISS_ACCOUNT                                                                  AS BinGLAccount,
		   'Awaiting Updated Status'																							AS BinCurrentStatus
    INTO   bluebin.DimBin
    FROM   ITEMLOC  
           INNER JOIN bluebin.DimLocation
                   ON ltrim(rtrim(ITEMLOC.LOCATION)) = ltrim(rtrim(DimLocation.LocationID))
				   AND ITEMLOC.COMPANY = DimLocation.LocationFacility			   
           INNER JOIN #BinAddDates
                   ON ltrim(rtrim(ITEMLOC.COMPANY)) = ltrim(rtrim(#BinAddDates.COMPANY)) and ltrim(rtrim(ITEMLOC.LOCATION)) = ltrim(rtrim(#BinAddDates.REQ_LOCATION)) and ltrim(rtrim(ITEMLOC.ITEM)) = ltrim(rtrim(#BinAddDates.ITEM))
           LEFT JOIN #ItemReqs
                  ON ITEMLOC.ITEM = #ItemReqs.ITEM
                     AND ITEMLOC.UOM = #ItemReqs.ENTERED_UOM
                     AND #ItemReqs.Itemreqseq = 1
           LEFT JOIN #ItemOrders
                  ON ITEMLOC.ITEM = #ItemOrders.ITEM
                     AND ITEMLOC.UOM = #ItemOrders.ENT_BUY_UOM
                     AND #ItemOrders.ItemOrderSeq = 1
			LEFT JOIN #ItemOrders2
                  ON ITEMLOC.ITEM = #ItemOrders2.ITEM
           LEFT JOIN #ItemAccounts
                  ON ITEMLOC.COMPANY = #ItemAccounts.COMPANY and ITEMLOC.ITEM = #ItemAccounts.ITEM
           LEFT JOIN #ItemStore
                  ON ITEMLOC.COMPANY = #ItemStore.COMPANY and ITEMLOC.ITEM = #ItemStore.ITEM
		   LEFT JOIN #Consignment
                  ON ITEMLOC.ITEM = #Consignment.ITEM
	WHERE DimLocation.BlueBinFlag = 1 --and ITEMLOC.ITEM  = '102351' 
	order by LocationID,ItemID
	
/*****************************************		DROP Temp Tables	**************************************/

DROP TABLE #BinAddDates
DROP TABLE #ItemReqs
DROP TABLE #ItemOrders
DROP TABLE #ItemOrders2
DROP TABLE #ItemAccounts
DROP TABLE #ItemStore
DROP TABLE #Consignment



GO



UPDATE etl.JobSteps
SET LastModifiedDate = GETDATE()
WHERE StepName = 'DimBin'
