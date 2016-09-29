BEGIN Try
    DROP TABLE DimItem
END Try

BEGIN Catch
END Catch

SELECT Row_number()
         OVER(
           ORDER BY a.INV_ITEM_ID) AS ItemKey,
       a.INV_ITEM_ID               AS ItemId,
       DESCR                       AS ItemDescription,
       UNIT_MEASURE_STD            AS stDuom,
       b.MFG_ID                    AS ItemManufacturer,
       b.MFG_ITM_ID                AS ItemManufacturerNumber,
       d.NAME1                     AS ItemVendor,
       c.ITM_ID_VNDR               AS ItemVendorNumber
INTO   DimItem
FROM   ps.MASTER_ITEM_TBL a
       LEFT JOIN ps.ITEM_MFG b
              ON a.INV_ITEM_ID = b.INV_ITEM_ID
                 AND b.PREFERRED_MFG = 'Y'
       LEFT JOIN ps.ITM_VENDOR c
              ON a.INV_ITEM_ID = c.INV_ITEM_ID
                 AND c.ITM_VNDR_PRIORITY = 1
       LEFT JOIN ps.VENDOR d
              ON c.VENDOR_ID = d.VENDOR_ID 
