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
	   PO_LN.UNIT_OF_MEASURE as OrderUOM,
	   CASE WHEN PO_LN.CANCEL_STATUS = 'A' THEN 'Active' ELSE 'Cancelled' END as CancelStatus
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
