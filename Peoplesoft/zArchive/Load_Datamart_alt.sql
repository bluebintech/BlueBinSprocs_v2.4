

BEGIN TRY
DROP TABLE tmpCartCounts
END TRY
BEGIN CATCH END CATCH
SELECT 
ROW_NUMBER()OVER(PARTITION BY BinKey, CART_CT.CART_REPLEN_OPT ORDER BY CART_CT.CART_REPLEN_OPT, CASE
                     WHEN Datediff(HOUR, CART_CT.DEMAND_DATE, CART_CT.LAST_DTTM_UPDATE) < 24 THEN CART_CT.LAST_DTTM_UPDATE
                     ELSE DEMAND_DATE
                   END) as OrderSeq,
Bins.BinKey,
       CART.LOCATION as LocationID,
       CART_CT.INV_ITEM_ID as ItemID,
       OrderDate = CASE
                     WHEN Datediff(HOUR, CART_CT.DEMAND_DATE, CART_CT.LAST_DTTM_UPDATE) < 24 THEN CART_CT.LAST_DTTM_UPDATE
                     ELSE DEMAND_DATE
                   END,
       CART_CT.CART_COUNT_QTY as OrderQty,
       CART_CT.CART_COUNT_ID as CartCountNum,
       CART_CT.CART_COUNT_STATUS as CartCountStatus,
       CART_CT.CART_REPLEN_OPT as OrderTypeID,
       OrderType = CASE
                     WHEN CART_CT.CART_REPLEN_OPT = '01' THEN 'MSR'
                     WHEN CART_CT.CART_REPLEN_OPT = '02' THEN 'PO'
                     WHEN CART_CT.CART_REPLEN_OPT = '03' THEN 'RQ'
                     WHEN CART_CT.CART_REPLEN_OPT = '04' THEN 'NR'
                     ELSE NULL
                   END
INTO tmpCartCounts
FROM   PS.CART_CT_INF_INV CART_CT
       INNER JOIN PS.CART_ATTRIB_INV CART
              ON CART_CT.INV_CART_ID = CART.INV_CART_ID
       INNER JOIN PS.LOCATION_TBL LOCATION
              ON CART.LOCATION = LOCATION.LOCATION
       INNER JOIN DimBin Bins
              ON CART.LOCATION = Bins.LocationID
                 AND CART_CT.INV_ITEM_ID = Bins.ItemID
WHERE  CART.LOCATION LIKE 'B%'
       AND CART_CT.CART_COUNT_QTY <> 0
ORDER  BY 2,1

GO

BEGIN TRY
DROP TABLE tmpPickLines
END TRY
BEGIN CATCH END CATCH
SELECT Bins.BinKey,
       INV_ITEM_ID as ItemID,
       LOCATION as LocationID,
       Picks.ORDER_NO as OrderNum,
       Picks.ORDER_INT_LINE_NO as LineNum,
       Picks.DEMAND_DATE as OrderDate,
       Picks.PICK_CONFIRM_DTTM as CloseDate,
       Cast(Picks.QTY_PICKED AS INT) AS OrderQty,
	   UNIT_OF_MEASURE as OrderUOM
INTO tmpPickLines
FROM   ps.IN_DEMAND Picks
       INNER JOIN DimBin Bins
               ON Picks.LOCATION = Bins.LocationID
                  AND Picks.INV_ITEM_ID = Bins.ItemID
WHERE  LOCATION LIKE 'B%'
       AND CANCEL_DTTM IS NULL
       AND PICK_BATCH_ID <> 0
       AND IN_FULFILL_STATE = 70
ORDER  BY BinKey,
          Picks.DEMAND_DATE 


		  GO
		  
BEGIN TRY
DROP TABLE tmpPOLines
END TRY
BEGIN CATCH
END CATCH
SELECT Bins.BinKey,
       PO_LN.INV_ITEM_ID   AS ItemID,
       LOCATION            AS LocationID,
       PO_LN.PO_ID         AS OrderNum,
       PO_LN.LINE_NBR      AS LineNum,
       PO_DT               AS OrderDate,
       RECEIPT_DTTM        AS CloseDate,
	   QTY_PO              AS OrderQty,
	   PO_LN.UNIT_OF_MEASURE as OrderUOM
INTO tmpPOLines
FROM   PS.PO_LINE_DISTRIB PO_LN_DST
       INNER JOIN PS.PO_LINE PO_LN
               ON PO_LN_DST.PO_ID = PO_LN.PO_ID
                  AND PO_LN_DST.LINE_NBR = PO_LN.LINE_NBR
       INNER JOIN PS.PO_HDR
               ON PO_LN.PO_ID = PO_HDR.PO_ID
       INNER JOIN DimBin Bins
               ON PO_LN.INV_ITEM_ID = Bins.ItemID
                  AND Bins.LocationID = PO_LN_DST.LOCATION
       LEFT JOIN PS.RECV_LN_SHIP SHIP
              ON PO_LN.PO_ID = SHIP.PO_ID
                 AND PO_LN.LINE_NBR = SHIP.LINE_NBR
WHERE  LOCATION LIKE 'B%'
ORDER  BY Bins.BinKey 

GO

BEGIN TRY
DROP TABLE tmpOrders
END TRY
BEGIN CATCH
END CATCH
GO
WITH AllOrders
     AS (SELECT *,
                'PO'                    AS OrderType
         FROM   tmpPOLines
         UNION ALL
         SELECT *,
                'MSR'                   AS OrderType
         FROM   tmpPickLines)
SELECT 
Row_number()
                  OVER(
                    Partition BY BinKey, OrderType
                    ORDER BY OrderType, OrderDate) AS OrderSeq,
*
INTO tmpOrders
FROM   AllOrders 

GO

BEGIN Try
    DROP TABLE FactScan
END Try

BEGIN Catch
END Catch

Go

WITH Scans
     AS (SELECT Row_number()
                  OVER(
                    Partition BY c.BinKey
                    ORDER BY c.OrderDate DESC) AS Scanseq,
					Row_number()
                  OVER(
                    Partition BY c.BinKey
                    ORDER BY c.OrderDate ASC) AS ScanHistseq,
                c.BinKey,
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
         FROM   tmpCartCounts c
                LEFT JOIN tmpOrders o
                       ON c.BinKey = o.BinKey
                          AND c.OrderSeq = o.OrderSeq
                          AND c.OrderType = o.OrderType
				WHERE OrderNum IS NOT NULL)
SELECT a.Scanseq,
	   a.BinKey,
       c.LocationKey,
       d.ItemKey,
       a.OrderTypeID,
       a.OrderType,
       a.CartCountNum,
       a.OrderNum,
       a.LineNum,
	   a.OrderUOM,
       Cast(a.OrderQty AS INT) AS OrderQty,
       a.OrderDate,
       a.CloseDate,
       b.OrderDate             AS PrevOrderDate,
       b.CloseDate             AS PrevOrderCloseDate,
	   1 as Scan,
       CASE
         WHEN Datediff(Day, b.OrderDate, a.OrderDate) < 3 THEN 1
         ELSE 0
       END                     AS HotScan,
       CASE
         WHEN a.OrderDate < COALESCE(b.CloseDate, GETDATE())
              AND a.ScanHistSeq > 2 THEN 1
         ELSE 0
       END                     AS StockOut
INTO FactScan
FROM   Scans a
       LEFT JOIN Scans b
              ON a.BinKey = b.BinKey
                 AND a.Scanseq = b.Scanseq - 1
       LEFT JOIN DimLocation c
              ON a.LocationID = c.LocationID
       LEFT JOIN DimItem d
              ON a.ItemID = d.ItemID
WHERE  a.OrderDate >= c.GoLiveDate 

GO
