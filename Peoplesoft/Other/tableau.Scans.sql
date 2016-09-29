BEGIN TRY
DROP TABLE tableau.Scans
END TRY
BEGIN CATCH
END CATCH
GO

SELECT BinSequence,
       BinCart,
       BinRow,
       BinPosition,
       BinSize,
       BinUOM,
       BinQty,
       BinLeadTime,
       BinGoLiveDate,
       DimItem.ItemID,
       ItemDescription,
       StdUOM,
       ItemManufacturer,
       ItemManufacturerNumber,
       ItemVendor,
       ItemVendorNumber,
       DimLocation.LocationID,
       LocationName,
	   OrderTypeID,
	   OrderType,
	   CartCountNum,
	   OrderNum,
	   LineNum,
	   OrderQty,
	   OrderDate,
	   CloseDate,
	   PrevOrderDate,
	   PrevOrderCloseDate,
	   Scan,
	   HotScan,
	   StockOut
INTO tableau.Scans
FROM   FactScan
       LEFT JOIN DimBin
              ON FactScan.BinKey = DimBin.BinKey
       LEFT JOIN DimLocation
              ON FactScan.LocationKey = DimLocation.LocationKey
       LEFT JOIN DimItem
              ON FactScan.ItemKey = DimItem.ItemKey 
