
/*************************************************

			FactScan

*************************************************/

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

--/********************************		CREATE Temp Tables			******************************/
--select * from #CartCounts where ItemID = '0305078' and LocationID = '99059BB10C'
--select * from #PickLines where ItemID like '0305078' and LocationID = '99059BB10C'
--select * from #POLines where ItemID like '0305078' and LocationID = '99059BB10C'
--select * from #Orders  where ItemID = '0305078' and LocationID = '99059BB10C'
SELECT 
ROW_NUMBER()OVER(PARTITION BY BinKey, CART_CT.CART_REPLEN_OPT ORDER BY CART_CT.CART_REPLEN_OPT, CASE
                     WHEN Datediff(HOUR, CART_CT.DEMAND_DATE, CART_CT.LAST_DTTM_UPDATE) < 24 THEN CART_CT.LAST_DTTM_UPDATE
                     ELSE DEMAND_DATE
                   END) as OrderSeq,
	  Bins.BinKey,
       Bins.BinGoLiveDate,
	   CART.LOCATION as LocationID,
       CART_CT.INV_ITEM_ID as ItemID,
       CASE
                     WHEN Datediff(HOUR, CART_CT.DEMAND_DATE, CART_CT.LAST_DTTM_UPDATE) < 24 THEN CART_CT.LAST_DTTM_UPDATE
                     ELSE DEMAND_DATE
                   END as OrderDate,
       CART_CT.CART_COUNT_QTY as OrderQty,
       CART_CT.CART_COUNT_ID as CartCountNum,
       CART_CT.CART_COUNT_STATUS as CartCountStatus,
       CART_CT.CART_REPLEN_OPT as OrderTypeID,
       CASE
                     WHEN CART_CT.CART_REPLEN_OPT = '01' THEN 'MSR'
                     WHEN CART_CT.CART_REPLEN_OPT = '02' THEN 'PO'
                     WHEN CART_CT.CART_REPLEN_OPT = '03' THEN 'RQ'
                     WHEN CART_CT.CART_REPLEN_OPT = '04' THEN 'NR'
                     ELSE NULL
                   END as OrderType
INTO #CartCounts
FROM   dbo.CART_CT_INF_INV CART_CT
       INNER JOIN dbo.CART_ATTRIB_INV CART
              ON CART_CT.INV_CART_ID COLLATE DATABASE_DEFAULT = CART.INV_CART_ID COLLATE DATABASE_DEFAULT
       INNER JOIN dbo.LOCATION_TBL LOCATION
              ON CART.LOCATION COLLATE DATABASE_DEFAULT = LOCATION.LOCATION COLLATE DATABASE_DEFAULT
       INNER JOIN bluebin.DimBin Bins
              ON CART.LOCATION COLLATE DATABASE_DEFAULT = Bins.LocationID  COLLATE DATABASE_DEFAULT
                 AND CART_CT.INV_ITEM_ID COLLATE DATABASE_DEFAULT = Bins.ItemID  COLLATE DATABASE_DEFAULT
WHERE  (LEFT(CART.LOCATION COLLATE DATABASE_DEFAULT, 2) IN (SELECT [ConfigValue] FROM   [bluebin].[Config] WHERE  [ConfigName] = 'REQ_LOCATION' AND Active = 1) 
		or CART.LOCATION COLLATE DATABASE_DEFAULT in (Select REQ_LOCATION from bluebin.ALT_REQ_LOCATION))
       AND CART_CT.CART_COUNT_QTY  <> 0
	   --and CART_CT.INV_ITEM_ID = '1056308'
ORDER  BY 2,1



--#PickLines
SELECT Bins.BinKey,
       INV_ITEM_ID as ItemID,
       LOCATION as LocationID,
       Picks.ORDER_NO as OrderNum,
       REQ_ID,
	   Picks.ORDER_INT_LINE_NO as LineNum,
       Picks.DEMAND_DATE as OrderDate,
       Picks.PICK_CONFIRM_DTTM as CloseDate,
       Cast(Picks.QTY_PICKED AS INT) AS OrderQty,
	   UNIT_OF_MEASURE as OrderUOM
INTO #PickLines
FROM   dbo.IN_DEMAND Picks
       INNER JOIN bluebin.DimBin Bins
               ON Picks.LOCATION COLLATE DATABASE_DEFAULT = Bins.LocationID
                  AND Picks.INV_ITEM_ID COLLATE DATABASE_DEFAULT = Bins.ItemID
WHERE  (LEFT(LOCATION, 2) IN (SELECT [ConfigValue] FROM   [bluebin].[Config] WHERE  [ConfigName] = 'REQ_LOCATION' AND Active = 1) 
		or LOCATION in (Select REQ_LOCATION from bluebin.ALT_REQ_LOCATION))
       AND (CANCEL_DTTM IS NULL or CANCEL_DTTM < '1900-01-01')
       AND PICK_BATCH_ID <> 0
	   AND QTY_PICKED > 0
       AND (IN_FULFILL_STATE in (select ConfigValue from bluebin.Config where ConfigName = 'PS_InFulfillState') or IN_FULFILL_STATE is null)
	   --and ORDER_NO like '%651384%'
ORDER  BY BinKey,
          Picks.DEMAND_DATE
		  
	  
--#POLines
SELECT Bins.BinKey,
       case when LEN(rtrim(PO_LN.INV_ITEM_ID)) = 6 then '0'+PO_LN.INV_ITEM_ID else PO_LN.INV_ITEM_ID end AS ItemID,
       LOCATION            AS LocationID,
       PO_LN.PO_ID         AS OrderNum,
       REQ_ID,
	   PO_LN.LINE_NBR      AS LineNum,
       PO_DT               AS OrderDate,
       RECEIPT_DTTM        AS CloseDate,
	   QTY_PO              AS OrderQty,
	   PO_LN.UNIT_OF_MEASURE as OrderUOM
INTO #POLines
FROM   dbo.PO_LINE_DISTRIB PO_LN_DST
       INNER JOIN dbo.PO_LINE PO_LN
               ON PO_LN_DST.PO_ID COLLATE DATABASE_DEFAULT = PO_LN.PO_ID
                  AND PO_LN_DST.LINE_NBR = PO_LN.LINE_NBR
       INNER JOIN dbo.PO_HDR
               ON PO_LN.PO_ID COLLATE DATABASE_DEFAULT = PO_HDR.PO_ID
       INNER JOIN bluebin.DimBin Bins
               --ON case when LEN(rtrim(PO_LN.INV_ITEM_ID)) = 6 then '0'+PO_LN.INV_ITEM_ID else PO_LN.INV_ITEM_ID end COLLATE DATABASE_DEFAULT = case when LEN(rtrim(Bins.ItemID)) = 6 then '0'+Bins.ItemID else Bins.ItemID end
               ON PO_LN.INV_ITEM_ID = Bins.ItemID 
                  AND Bins.LocationID = PO_LN_DST.LOCATION COLLATE DATABASE_DEFAULT
       LEFT JOIN dbo.RECV_LN_SHIP SHIP
              ON PO_LN.PO_ID COLLATE DATABASE_DEFAULT = SHIP.PO_ID COLLATE DATABASE_DEFAULT
                 AND PO_LN.LINE_NBR = SHIP.LINE_NBR
WHERE  (LEFT(LOCATION COLLATE DATABASE_DEFAULT, 2) IN (SELECT [ConfigValue] FROM   [bluebin].[Config] WHERE  [ConfigName] = 'REQ_LOCATION' AND Active = 1) 
		or LOCATION COLLATE DATABASE_DEFAULT in (Select REQ_LOCATION from bluebin.ALT_REQ_LOCATION))
		and PO_LN.CANCEL_STATUS NOT IN ( 'X', 'D' )
		--and PO_LN_DST.REQ_ID like '%651384%'
ORDER  BY Bins.BinKey 




Select
a.BinKey,
a.ItemID,
a.LocationID,
case when po.OrderNum is null then 
	case when pl.OrderNum is null then
		'NULL' else pl.OrderNum end
else po.OrderNum end as OrderNum,
a.REQ_ID,
a.LineNum,
a.OrderDate,
case when a.CloseDate is null then
	case when po.CloseDate is null then
		case when pl.CloseDate is null then null
		else pl.CloseDate end
	else po.CloseDate end
else a.CloseDate end as CloseDate,
a.OrderQty,
a.OrderUOM
INTO #RQLines
From (
		SELECT Bins.BinKey,
			   case when LEN(rtrim(REQ_LN.INV_ITEM_ID)) = 6 then '0'+REQ_LN.INV_ITEM_ID else REQ_LN.INV_ITEM_ID end AS ItemID,
			   REQ_LN_DST.LOCATION            AS LocationID,
			   ''					AS OrderNum,
			   REQ_LN.REQ_ID,
			   REQ_LN.LINE_NBR      AS LineNum,
			   REQ_HDR.ENTERED_DT   AS OrderDate,
			   DELIVERED_DT        AS CloseDate,
			   REQ_LN.QTY_REQ      AS OrderQty,
			   REQ_LN.UNIT_OF_MEASURE as OrderUOM

		FROM   dbo.REQ_LN_DISTRIB REQ_LN_DST
			   INNER JOIN dbo.REQ_LINE REQ_LN
					   ON REQ_LN_DST.REQ_ID COLLATE DATABASE_DEFAULT = REQ_LN.REQ_ID
						  AND REQ_LN_DST.LINE_NBR = REQ_LN.LINE_NBR
			   INNER JOIN dbo.REQ_HDR
					   ON REQ_LN.REQ_ID COLLATE DATABASE_DEFAULT = REQ_HDR.REQ_ID
			   INNER JOIN bluebin.DimBin Bins
					   ON case when LEN(rtrim(REQ_LN.INV_ITEM_ID)) = 6 then '0'+REQ_LN.INV_ITEM_ID else REQ_LN.INV_ITEM_ID end COLLATE DATABASE_DEFAULT = case when LEN(rtrim(Bins.ItemID)) = 6 then '0'+Bins.ItemID else Bins.ItemID end
						  AND Bins.LocationID = REQ_LN_DST.LOCATION COLLATE DATABASE_DEFAULT
			   LEFT JOIN dbo.RECV_LN_DISTRIB SHIP
					  ON REQ_LN.REQ_ID COLLATE DATABASE_DEFAULT = SHIP.REQ_ID COLLATE DATABASE_DEFAULT
						 AND REQ_LN.LINE_NBR = SHIP.LINE_NBR
 
		WHERE  (LEFT(REQ_LN_DST.LOCATION COLLATE DATABASE_DEFAULT, 2) IN (SELECT [ConfigValue] FROM   [bluebin].[Config] WHERE  [ConfigName] = 'REQ_LOCATION' AND Active = 1) 
				or REQ_LN_DST.LOCATION COLLATE DATABASE_DEFAULT in (Select REQ_LOCATION from bluebin.ALT_REQ_LOCATION))
				--and REQ_LN_DST.REQ_ID like '%651384%'
		) a
		LEFT JOIN #PickLines pl on a.REQ_ID COLLATE DATABASE_DEFAULT = pl.REQ_ID COLLATE DATABASE_DEFAULT 
			and pl.LineNum = a.LineNum
				and pl.ItemID COLLATE DATABASE_DEFAULT = a.ItemID COLLATE DATABASE_DEFAULT 
					and pl.LocationID COLLATE DATABASE_DEFAULT = a.LocationID COLLATE DATABASE_DEFAULT
		LEFT JOIN #POLines po on a.REQ_ID COLLATE DATABASE_DEFAULT = po.REQ_ID COLLATE DATABASE_DEFAULT
			and po.LineNum = a.LineNum
				and po.ItemID COLLATE DATABASE_DEFAULT = a.ItemID COLLATE DATABASE_DEFAULT 
					and po.LocationID COLLATE DATABASE_DEFAULT = a.LocationID COLLATE DATABASE_DEFAULT
ORDER  BY a.BinKey




--#Orders
SELECT 
Row_number()
                  OVER(
                    Partition BY BinKey, OrderType
                    ORDER BY OrderType, OrderDate) AS OrderSeq,
*
INTO #Orders
FROM   
(SELECT 
BinKey,
ItemID COLLATE DATABASE_DEFAULT as ItemID,
LocationID COLLATE DATABASE_DEFAULT as LocationID,
OrderNum COLLATE DATABASE_DEFAULT as OrderNum,
REQ_ID COLLATE DATABASE_DEFAULT as REQ_ID,
LineNum,
OrderDate,
CloseDate,
OrderQty,
OrderUOM COLLATE DATABASE_DEFAULT as OrderUOM,
'PO'                    AS OrderType
         FROM   #POLines
UNION ALL
         
SELECT 
BinKey,
ItemID COLLATE DATABASE_DEFAULT as ItemID,
LocationID COLLATE DATABASE_DEFAULT as LocationID,
OrderNum COLLATE DATABASE_DEFAULT as OrderNum,
REQ_ID COLLATE DATABASE_DEFAULT as REQ_ID,
LineNum,
OrderDate,
CloseDate,
OrderQty,
OrderUOM COLLATE DATABASE_DEFAULT as OrderUOM,
       'MSR'                   AS OrderType
         FROM   #PickLines
		 
UNION ALL
         
SELECT 
BinKey,
ItemID COLLATE DATABASE_DEFAULT as ItemID,
LocationID COLLATE DATABASE_DEFAULT as LocationID,
OrderNum COLLATE DATABASE_DEFAULT as OrderNum,
REQ_ID COLLATE DATABASE_DEFAULT as REQ_ID,
LineNum,
OrderDate,
CloseDate,
OrderQty,
OrderUOM COLLATE DATABASE_DEFAULT as OrderUOM,
       'RQ'                   AS OrderType
         FROM   #RQLines) a 



--#TmpScan
SELECT Row_number()
                  OVER(
                    Partition BY c.BinKey
                    ORDER BY c.OrderDate DESC) AS Scanseq,
					Row_number()
                  OVER(
                    Partition BY c.BinKey
                    ORDER BY c.OrderDate ASC) AS ScanHistseq,
                c.BinKey,
                c.BinGoLiveDate,
				db.BinLeadTime,
				c.LocationID,
                c.ItemID,
                c.OrderTypeID,
                c.OrderType,
                c.CartCountNum,
                o.OrderNum,
                o.LineNum,
				o.OrderUOM,
                o.OrderQty,
                c.OrderDate,
                o.CloseDate
         into #tmpScans
		 FROM   #CartCounts c
                INNER JOIN bluebin.DimBin db on c.BinKey = db.BinKey
				LEFT JOIN #Orders o
                       ON c.BinKey = o.BinKey
                          AND c.OrderSeq= o.OrderSeq
                          AND c.OrderType = o.OrderType
				WHERE OrderNum IS NOT NULL


/***********************************		CREATE FactScan		****************************************/
declare @DefaultLT int = (Select max(ConfigValue) from bluebin.Config where ConfigName = 'DefaultLeadTime')

SELECT 
a.Scanseq,
a.ScanHistseq,
	   a.BinKey,
       c.LocationKey,
       d.ItemKey,
       a.BinGoLiveDate,
	   a.OrderNum,
       a.LineNum,
	   --a.OrderTypeID,
       a.OrderType as ItemType,
	   a.OrderUOM,
	   --a.CartCountNum,
       Cast(a.OrderQty AS INT) AS OrderQty,
       a.OrderDate,
       a.CloseDate as OrderCloseDate,
       b.OrderDate             AS PrevOrderDate,
       b.CloseDate             AS PrevOrderCloseDate,
	   1 as Scan,
       CASE
         WHEN Datediff(Day, b.OrderDate, a.OrderDate) < COALESCE(a.BinLeadTime,@DefaultLT,3) THEN 1
         ELSE 0
       END                     AS HotScan,
       CASE
         WHEN a.OrderDate < COALESCE(b.CloseDate, Getdate())
              AND a.ScanHistseq > (select ConfigValue + 1 from bluebin.Config where ConfigName = 'ScanThreshold') THEN 1 --When looking for stockouts you have to take the scanseq 2 after the ignored one
         ELSE 0
       END                     AS StockOut

--INTO bluebin.FactScan
FROM   #tmpScans a
       LEFT JOIN #tmpScans b
              ON a.BinKey = b.BinKey
                 AND a.Scanseq = b.Scanseq - 1
       LEFT JOIN bluebin.DimLocation c
              ON a.LocationID = c.LocationID
       LEFT JOIN bluebin.DimItem d
              ON a.ItemID = d.ItemID


/*****************************************		DROP Temp Tables		*******************************/

DROP TABLE #PickLines
DROP TABLE #POLines
DROP TABLE #RQLines
DROP TABLE #CartCounts
DROP TABLE #Orders
DROP TABLE #tmpScans



GO

UPDATE etl.JobSteps
SET LastModifiedDate = GETDATE()
WHERE StepName = 'FactScan'
