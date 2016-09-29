BEGIN Try
    DROP TABLE Tableau.Bins
END Try

BEGIN Catch
END Catch

Go

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
       BinSnapshotDate,
       LastScannedDate,
       DaysSinceLastScan,
       ScansInThreshold,
       HotScansInThreshold,
       StockOutsInThreshold,
       BinStatusKey,
       BinStatus,
       HealthyBins,
       HotBins,
       VeryHotBins,
       ExtremelyHotBins,
       SlowBins,
       StaleBins,
       NeverScannedBins,
       1 AS TotalBins
INTO tableau.Bins
FROM   FactBinSnapshot
       LEFT JOIN DimBin
              ON FactBinSnapshot.BinKey = DimBin.BinKey
       LEFT JOIN DimLocation
              ON FactBinSnapshot.LocationKey = DimLocation.LocationKey
       LEFT JOIN DimItem
              ON FactBinSnapshot.ItemKey = DimItem.ItemKey 
