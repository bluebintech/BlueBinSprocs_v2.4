BEGIN TRY
DROP TABLE DimBin
END TRY
BEGIN CATCH
END CATCH

/**********************************************************
FIELDS REQUIRED:
					BinKey
					BinItemKey
					BinLocationKey
					BinSequence
					BinCart
					BinRow
					BinPosition
					BinSize
					BinUOM
					BinQty
					BinLeadTime
					BinAddedDate
**********************************************************/
SELECT Row_number()
         OVER(
           ORDER BY Bins.INV_CART_ID, Bins.INV_ITEM_ID) AS BinKey,
       Bins.INV_CART_ID                                 AS CartId,
       Bins.INV_ITEM_ID                                 AS ItemId,
       Locations.LOCATION                               AS LocationId,
       Bins.COMPARTMENT                                 AS BinSequence,
       LEFT(Bins.COMPARTMENT, 1)                        AS BinCart,
       Substring(Bins.COMPARTMENT, 2, 1)                AS BinRow,
       Substring(Bins.COMPARTMENT, 3, 2)                AS BinPosition,
       RIGHT(Bins.COMPARTMENT, 3)                       AS BinSize,
       Bins.UNIT_OF_MEASURE                             AS Binuom,
       Cast(Bins.QTY_OPTIMAL AS INT)                    AS Binqty,
       3                                                AS BinLeadTime,
	   Locations.EFFDT									AS BinGoLiveDate
INTO   DimBin
FROM   ps.CART_TEMPL_INV Bins
       LEFT JOIN ps.CART_ATTRIB_INV Carts
              ON Bins.INV_CART_ID = Carts.INV_CART_ID
       LEFT JOIN ps.LOCATION_TBL Locations
              ON Carts.LOCATION = Locations.LOCATION
WHERE  Carts.LOCATION LIKE 'B%' 
