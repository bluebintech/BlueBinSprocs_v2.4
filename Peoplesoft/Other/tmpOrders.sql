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
