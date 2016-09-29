BEGIN Try
    DROP TABLE FactBinSnapshot
END Try

BEGIN Catch
END Catch

Go

WITH LastScans
     AS (SELECT Row_number()
                  OVER(
                    Partition BY BinKey, DimDate.Date
                    ORDER BY OrderDate DESC) AS Scanseq,
                BinKey,
                OrderDate                    AS LastScannedDate,
                DimDate.Date
         FROM   FactScan
                LEFT JOIN DimDate
                       ON OrderDate <= DimDate.Date),
     ThresholdScans
     AS (SELECT DimBin.BinKey,
                DimDate.Date,
                Sum(Coalesce(Scan,0))     AS ScansInThreshold,
                Sum(Coalesce(HotScan,0))  AS HotScansInThreshold,
                Sum(Coalesce(StockOut,0)) AS StockOutsInThreshold,
                Sum(CASE
                      WHEN Cast(OrderDate AS DATE) = Cast(Dateadd(Day, -1, DimDate.Date) AS DATE) THEN StockOut
                      ELSE 0
                    END)      AS StockOutsDaily
         FROM   
		 DimBin 
		 CROSS JOIN
		 DimDate
                LEFT JOIN FactScan
                       ON Cast(DimDate.Date as date) >= Cast(OrderDate as Date) AND DATEADD(DAY, -15, DimDate.Date) <= Cast(OrderDate as Date)
					   AND DimBin.BinKey = FactScan.BinKey
         WHERE DimDate.Date >= DimBin.BinGoLiveDate
		 GROUP  BY DimBin.BinKey,
                   DimDate.Date
),
     LastTwoScans
     AS (SELECT BinKey,
                Date,
                [1] AS FirstScan,
                [2] AS SecondScan
         FROM   (SELECT BinKey,
                        Row_number()
                          OVER(
                            Partition BY BinKey, b.Date
                            ORDER BY OrderDate DESC) AS Scanseq,
                        b.Date,
                        ( HotScan + StockOut )       AS HotScan
                 FROM   FactScan a
                        INNER JOIN DimDate b
                                ON Cast(a.OrderDate AS DATE) <= Cast(b.Date AS DATE)) p
                PIVOT ( Sum(HotScan)
                      FOR ScanSeq IN ([1],
                                      [2]) ) AS pvt)
SELECT DimBin.BinKey,
       DimLocation.LocationKey,
       DimItem.ItemKey,
       DimDate.Date                                                                 AS BinSnapshotDate,
       COALESCE(LastScannedDate, DimBin.BinGoLiveDate)                              AS LastScannedDate,
       Datediff(Day, COALESCE(LastScannedDate, DimBin.BinGoLiveDate), DimDate.Date) AS DaysSinceLastScan,
       COALESCE(ScansInThreshold, 0)                                                AS ScanSinThreshold,
       COALESCE(HotScansInThreshold, 0)                                             AS HotScanSinThreshold,
       COALESCE(StockOutsInThreshold, 0)                                            AS StockOutSinThreshold,
       COALESCE(StockOutsDaily, 0)                                                  AS StockOutsDaily,
       CASE
         WHEN (( COALESCE(LastTwoScans.FirstScan, 0) = 0
                AND COALESCE(LastTwoScans.SecondScan, 0) = 0 )
				OR ThresholdScans.HotScansInThreshold < 2)
              AND Datediff(Day, LastScannedDate, DimDate.Date) BETWEEN 0 AND 90 THEN 1
         WHEN ThresholdScans.HotScansInThreshold >= 8 THEN 4
         WHEN ThresholdScans.HotScansInThreshold >= 4
              AND ThresholdScans.HotScansInThreshold < 8 THEN 3
         WHEN ThresholdScans.HotScansInThreshold >= 2
              AND ThresholdScans.HotScansInThreshold < 4 THEN 2
         WHEN Datediff(Day, COALESCE(LastScannedDate, DimBin.BinGoLiveDate), DimDate.Date) BETWEEN 90 AND 180 THEN 5
         WHEN Datediff(Day, COALESCE(LastScannedDate, DimBin.BinGoLiveDate), DimDate.Date) >= 180 THEN 6
         WHEN DimBin.BinKey NOT IN (SELECT DISTINCT BinKey
                                    FROM   FactScan
                                    WHERE  OrderDate <= DimDate.Date) THEN 7
         ELSE 0
       END                                                                          AS BinStatusKey,
       DimBinStatus.BinStatus,
       CASE
         WHEN (( COALESCE(LastTwoScans.FirstScan, 0) = 0
                AND COALESCE(LastTwoScans.SecondScan, 0) = 0 )
				OR ThresholdScans.HotScansInThreshold < 2)
              AND Datediff(Day, LastScannedDate, DimDate.Date) BETWEEN 0 AND 90 THEN 1
         WHEN ThresholdScans.HotScansInThreshold >= 8 THEN 0
         WHEN ThresholdScans.HotScansInThreshold >= 4
              AND ThresholdScans.HotScansInThreshold < 8 THEN 0
         WHEN ThresholdScans.HotScansInThreshold >= 2
              AND ThresholdScans.HotScansInThreshold < 4 THEN 0
         WHEN Datediff(Day, COALESCE(LastScannedDate, DimBin.BinGoLiveDate), DimDate.Date) BETWEEN 90 AND 180 THEN 0
         WHEN Datediff(Day, COALESCE(LastScannedDate, DimBin.BinGoLiveDate), DimDate.Date) >= 180 THEN 0
         ELSE 0
       END                                                                          AS HealthyBins,
       CASE
         WHEN (( COALESCE(LastTwoScans.FirstScan, 0) = 0
                AND COALESCE(LastTwoScans.SecondScan, 0) = 0 )
				OR ThresholdScans.HotScansInThreshold < 2)
              AND Datediff(Day, LastScannedDate, DimDate.Date) BETWEEN 0 AND 90 THEN 0
         WHEN ThresholdScans.HotScansInThreshold >= 8 THEN 0
         WHEN ThresholdScans.HotScansInThreshold >= 4
              AND ThresholdScans.HotScansInThreshold < 8 THEN 0
         WHEN ThresholdScans.HotScansInThreshold >= 2
              AND ThresholdScans.HotScansInThreshold < 4 THEN 1
         WHEN Datediff(Day, COALESCE(LastScannedDate, DimBin.BinGoLiveDate), DimDate.Date) BETWEEN 90 AND 180 THEN 0
         WHEN Datediff(Day, COALESCE(LastScannedDate, DimBin.BinGoLiveDate), DimDate.Date) >= 180 THEN 0
         ELSE 0
       END                                                                          AS HotBins,
       CASE
                  WHEN (( COALESCE(LastTwoScans.FirstScan, 0) = 0
                AND COALESCE(LastTwoScans.SecondScan, 0) = 0 )
				OR ThresholdScans.HotScansInThreshold < 2)
              AND Datediff(Day, LastScannedDate, DimDate.Date) BETWEEN 0 AND 90 THEN 0
         WHEN ThresholdScans.HotScansInThreshold >= 8 THEN 0
         WHEN ThresholdScans.HotScansInThreshold >= 4
              AND ThresholdScans.HotScansInThreshold < 8 THEN 1
         WHEN ThresholdScans.HotScansInThreshold >= 2
              AND ThresholdScans.HotScansInThreshold < 4 THEN 0
         WHEN Datediff(Day, COALESCE(LastScannedDate, DimBin.BinGoLiveDate), DimDate.Date) BETWEEN 90 AND 180 THEN 0
         WHEN Datediff(Day, COALESCE(LastScannedDate, DimBin.BinGoLiveDate), DimDate.Date) >= 180 THEN 0
         ELSE 0
       END                                                                          AS VeryHotBins,
       CASE
                  WHEN (( COALESCE(LastTwoScans.FirstScan, 0) = 0
                AND COALESCE(LastTwoScans.SecondScan, 0) = 0 )
				OR ThresholdScans.HotScansInThreshold < 2)
              AND Datediff(Day, LastScannedDate, DimDate.Date) BETWEEN 0 AND 90 THEN 0
         WHEN ThresholdScans.HotScansInThreshold >= 8 THEN 1
         WHEN ThresholdScans.HotScansInThreshold >= 4
              AND ThresholdScans.HotScansInThreshold < 8 THEN 0
         WHEN ThresholdScans.HotScansInThreshold >= 2
              AND ThresholdScans.HotScansInThreshold < 4 THEN 0
         WHEN Datediff(Day, COALESCE(LastScannedDate, DimBin.BinGoLiveDate), DimDate.Date) BETWEEN 90 AND 180 THEN 0
         WHEN Datediff(Day, COALESCE(LastScannedDate, DimBin.BinGoLiveDate), DimDate.Date) >= 180 THEN 0
         ELSE 0
       END                                                                          AS ExtremelyHotBins,
       CASE
                  WHEN (( COALESCE(LastTwoScans.FirstScan, 0) = 0
                AND COALESCE(LastTwoScans.SecondScan, 0) = 0 )
				OR ThresholdScans.HotScansInThreshold < 2)
              AND Datediff(Day, LastScannedDate, DimDate.Date) BETWEEN 0 AND 90 THEN 0
         WHEN ThresholdScans.HotScansInThreshold >= 8 THEN 0
         WHEN ThresholdScans.HotScansInThreshold >= 4
              AND ThresholdScans.HotScansInThreshold < 8 THEN 0
         WHEN ThresholdScans.HotScansInThreshold >= 2
              AND ThresholdScans.HotScansInThreshold < 4 THEN 0
         WHEN Datediff(Day, COALESCE(LastScannedDate, DimBin.BinGoLiveDate), DimDate.Date) BETWEEN 90 AND 180 THEN 1
         WHEN Datediff(Day, COALESCE(LastScannedDate, DimBin.BinGoLiveDate), DimDate.Date) >= 180 THEN 0
         ELSE 0
       END                                                                          AS SlowBins,
       CASE
        WHEN (( COALESCE(LastTwoScans.FirstScan, 0) = 0
                AND COALESCE(LastTwoScans.SecondScan, 0) = 0 )
				OR ThresholdScans.HotScansInThreshold < 2)
              AND Datediff(Day, LastScannedDate, DimDate.Date) BETWEEN 0 AND 90 THEN 0
         WHEN ThresholdScans.HotScansInThreshold >= 8 THEN 0
         WHEN ThresholdScans.HotScansInThreshold >= 4
              AND ThresholdScans.HotScansInThreshold < 8 THEN 0
         WHEN ThresholdScans.HotScansInThreshold >= 2
              AND ThresholdScans.HotScansInThreshold < 4 THEN 0
         WHEN Datediff(Day, COALESCE(LastScannedDate, DimBin.BinGoLiveDate), DimDate.Date) BETWEEN 90 AND 180 THEN 0
         WHEN Datediff(Day, COALESCE(LastScannedDate, DimBin.BinGoLiveDate), DimDate.Date) >= 180 THEN 1
         ELSE 0
       END                                                                          AS StaleBins,
       CASE
         WHEN DimBin.BinKey NOT IN (SELECT DISTINCT BinKey
                                    FROM   FactScan
                                    WHERE  OrderDate <= DimDate.Date) THEN 1
         ELSE 0
       END                                                                          AS NeverScannedBins
INTO FactBinSnapshot
FROM   dbo.DimBin
       CROSS JOIN dbo.DimDate
       LEFT JOIN LastScans
              ON DimBin.BinKey = LastScans.BinKey
                 AND DimDate.Date = LastScans.Date
                 AND LastScans.ScanSeq = 1
       LEFT JOIN ThresholdScans
              ON DimBin.BinKey = ThresholdScans.BinKey
                 AND DimDate.Date = ThresholdScans.Date
       LEFT JOIN LastTwoScans
              ON DimBin.BinKey = LastTwoScans.BinKey AND DimDate.Date = LastTwoScans.Date
       LEFT JOIN DimBinStatus
              ON BinStatusKey = CASE
                                  WHEN (( COALESCE(LastTwoScans.FirstScan, 0) = 0
                AND COALESCE(LastTwoScans.SecondScan, 0) = 0 )
				OR ThresholdScans.HotScansInThreshold < 2)
              AND Datediff(Day, LastScannedDate, DimDate.Date) BETWEEN 0 AND 90 THEN 1
                                  WHEN ThresholdScans.HotScansInThreshold >= 8 THEN 4
                                  WHEN ThresholdScans.HotScansInThreshold >= 4
                                       AND ThresholdScans.HotScansInThreshold < 8 THEN 3
                                  WHEN ThresholdScans.HotScansInThreshold >= 2
                                       AND ThresholdScans.HotScansInThreshold < 4 THEN 2
                                  WHEN Datediff(Day, COALESCE(LastScannedDate, DimBin.BinGoLiveDate), DimDate.Date) BETWEEN 90 AND 180 THEN 5
                                  WHEN Datediff(Day, COALESCE(LastScannedDate, DimBin.BinGoLiveDate), DimDate.Date) >= 180 THEN 6
                                  WHEN DimBin.BinKey NOT IN (SELECT DISTINCT BinKey
                                                             FROM   FactScan
                                                             WHERE  OrderDate <= DimDate.Date) THEN 7
                                  ELSE 0
                                END
       LEFT JOIN DimLocation
              ON DimBin.LocationID = DimLocation.LocationID
       LEFT JOIN DimItem
              ON DimBin.ItemID = DimItem.ItemID
WHERE  BinGoLiveDate <= DimDate.Date
       AND DimDate.Date >= Dateadd(Day, -90, Getdate())
       --AND DimBin.BinKey = 2
ORDER  BY 1,
          4 
