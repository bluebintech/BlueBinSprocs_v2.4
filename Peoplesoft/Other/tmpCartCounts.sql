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
	   AND PROCESS_INSTANCE > 0
ORDER  BY 2,1
