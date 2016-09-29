--BEGIN Try
--    DROP TABLE FactScan
--END Try

--BEGIN Catch
--END Catch

--Go

WITH Scans
     AS (
	 SELECT Row_number()
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
						  AND CAST(c.OrderDate as DATE) = CAST(o.OrderDate as DATE)
						  
				WHERE OrderNum IS NOT NULL --
				)
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
--INTO FactScan
FROM   Scans a
       LEFT JOIN Scans b
              ON a.BinKey = b.BinKey
                 AND a.Scanseq = b.Scanseq - 1
       LEFT JOIN DimLocation c
              ON a.LocationID = c.LocationID
       LEFT JOIN DimItem d
              ON a.ItemID = d.ItemID
WHERE  a.OrderDate >= c.GoLiveDate AND d.ItemID = 1001477 AND c.LocationId = 'B025071533'
