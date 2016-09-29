BEGIN TRY
DROP TABLE tableau.SCMDashboard
END TRY
BEGIN CATCH
END CATCH

SELECT 
DimBin.BinKey,
DimBin.CartId,
DimBin.ItemId,
DimBin.LocationId,
DimBin.BinSequence,
DimBin.BinCart,
DimBin.BinRow,
DimBin.BinPosition,
DimBin.BinSize,
DimBin.Binuom,
DimBin.Binqty,
DimBin.BinLeadTime,
DimBin.BinGoLiveDate,
DimDate.Date,
DimDate.FullDateUK,
DimDate.FullDateUSA,
DimDate.DayOfMonth,
DimDate.DaySuffix,
DimDate.DayName,
DimDate.DayOfWeekUSA,
DimDate.DayOfWeekUK,
DimDate.DayOfWeekInMonth,
DimDate.DayOfWeekInYear,
DimDate.DayOfQuarter,
DimDate.DayOfYear,
DimDate.WeekOfMonth,
DimDate.WeekOfQuarter,
DimDate.WeekOfYear,
DimDate.Month,
DimDate.MonthName,
DimDate.MonthOfQuarter,
DimDate.Quarter,
DimDate.QuarterName,
DimDate.Year,
DimDate.YearName,
DimDate.MonthYear,
DimDate.MMYYYY,
DimDate.FirstDayOfMonth,
DimDate.LastDayOfMonth,
DimDate.FirstDayOfQuarter,
DimDate.LastDayOfQuarter,
DimDate.FirstDayOfYear,
DimDate.LastDayOfYear,
DimDate.IsHolidayUSA,
DimDate.IsWeekday,
DimDate.HolidayUSA,
DimDate.IsHolidayUK,
DimDate.HolidayUK,
FactScan.Scanseq,
FactScan.OrderTypeID,
FactScan.OrderType,
FactScan.CartCountNum,
FactScan.OrderNum,
FactScan.LineNum,
FactScan.OrderUOM,
FactScan.OrderQty,
FactScan.OrderDate,
FactScan.CloseDate,
FactScan.PrevOrderDate,
FactScan.PrevOrderCloseDate,
FactScan.Scan,
FactScan.HotScan,
FactScan.StockOut,
FactBinSnapshot.BinSnapshotDate,
FactBinSnapshot.LastScannedDate,
FactBinSnapshot.DaysSinceLastScan,
FactBinSnapshot.ScanSinThreshold,
FactBinSnapshot.HotScanSinThreshold,
FactBinSnapshot.StockOutSinThreshold,
FactBinSnapshot.StockOutsDaily,
FactBinSnapshot.BinStatus,
FactBinSnapshot.HealthyBins,
FactBinSnapshot.HotBins,
FactBinSnapshot.VeryHotBins,
FactBinSnapshot.ExtremelyHotBins,
FactBinSnapshot.SlowBins,
FactBinSnapshot.StaleBins,
FactBinSnapshot.NeverScannedBins,
DimItem.ItemDescription,
DimItem.StdUOM,
DimItem.ItemManufacturer,
DimItem.ItemManufacturerNumber,
DimItem.ItemVendor,
DimItem.ItemVendorNumber,
DimLocation.LocationName,
1 as TotalBins
INTO tableau.SCMDashboard
FROM   DimBin
       CROSS JOIN DimDate
       LEFT JOIN FactScan
              ON Cast(OrderDate AS DATE) = Cast(Date AS DATE)
                 AND DimBin.BinKey = FactScan.BinKey
       LEFT JOIN FactBinSnapshot
              ON Date = BinSnapshotDate
                 AND DimBin.BinKey = FactBinSnapshot.BinKey
       LEFT JOIN DimItem
              ON DimBin.ItemId = DimItem.ItemId
       LEFT JOIN DimLocation
              ON DimBin.LocationId = DimLocation.LocationId
WHERE  Date >= BinGoLiveDate

ORDER  BY Date 
