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
	   UNIT_OF_MEASURE as OrderUOM,
	   CASE WHEN Picks.CANCEL_DTTM IS NULL THEN 'Cancelled' ELSE 'Active' END as CancelStatus
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
