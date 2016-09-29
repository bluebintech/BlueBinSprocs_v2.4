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
--INTO   DimBin
FROM   dbo.CART_TEMPL_INV Bins
       LEFT JOIN dbo.CART_ATTRIB_INV Carts
              ON Bins.INV_CART_ID = Carts.INV_CART_ID
       LEFT JOIN dbo.LOCATION_TBL Locations
              ON Carts.LOCATION = Locations.LOCATION
WHERE  Carts.LOCATION LIKE 'B%' 

GO

BEGIN TRY
DROP TABLE DimBinStatus
END TRY

BEGIN CATCH
END CATCH
GO

CREATE TABLE [dbo].[DimBinStatus](
	[BinStatusKey] [int] NULL,
	[BinStatus] [varchar](50) NULL
) ON [PRIMARY]

GO



INSERT INTO dbo.DimBinStatus (	BinStatusKey,	BinStatus	) VALUES( 1, 'Healthy')
INSERT INTO dbo.DimBinStatus (	BinStatusKey,	BinStatus	) VALUES( 2, 'Hot')
INSERT INTO dbo.DimBinStatus (	BinStatusKey,	BinStatus	) VALUES( 3, 'Very Hot' )
INSERT INTO dbo.DimBinStatus (	BinStatusKey,	BinStatus	) VALUES( 4, 'Extremely Hot' )
INSERT INTO dbo.DimBinStatus (	BinStatusKey,	BinStatus	) VALUES( 5, 'Slow' )
INSERT INTO dbo.DimBinStatus (	BinStatusKey,	BinStatus	) VALUES( 6, 'Stale')
INSERT INTO dbo.DimBinStatus (	BinStatusKey,	BinStatus	) VALUES( 7, 'Never Scanned')

GO



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
FROM   dbo.MASTER_ITEM_TBL a
       LEFT JOIN dbo.ITEM_MFG b
              ON a.INV_ITEM_ID = b.INV_ITEM_ID
                 AND b.PREFERRED_MFG = 'Y'
       LEFT JOIN dbo.ITM_VENDOR c
              ON a.INV_ITEM_ID = c.INV_ITEM_ID
                 AND c.ITM_VNDR_PRIORITY = 1
       LEFT JOIN dbo.VENDOR d
              ON c.VENDOR_ID = d.VENDOR_ID 
GO

BEGIN TRY
DROP TABLE DimLocation
END TRY
BEGIN CATCH
END CATCH
SELECT Row_number()
         OVER(
           ORDER BY a.EFFDT) AS LocationKey,
       a.LOCATION            AS LocationId,
       UPPER(DESCR)               AS LocationName,
       a.EFFDT               AS GoLiveDate
	   INTO DimLocation
FROM   dbo.LOCATION_TBL a INNER JOIN
(SELECT LOCATION, MIN(EFFDT) AS EFFDT FROM dbo.LOCATION_TBL GROUP BY LOCATION) b ON a.LOCATION = b.LOCATION AND a.EFFDT = b.EFFDT
WHERE  a.EFF_STATUS = 'A'

GO

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
FROM   dbo.CART_CT_INF_INV CART_CT
       INNER JOIN dbo.CART_ATTRIB_INV CART
              ON CART_CT.INV_CART_ID = CART.INV_CART_ID
       INNER JOIN dbo.LOCATION_TBL LOCATION
              ON CART.LOCATION = LOCATION.LOCATION
       INNER JOIN DimBin Bins
              ON CART.LOCATION = Bins.LocationID
                 AND CART_CT.INV_ITEM_ID = Bins.ItemID
WHERE  CART.LOCATION LIKE 'B%'
       AND CART_CT.CART_COUNT_QTY <> 0
ORDER  BY 2,1

GO

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
	   UNIT_OF_MEASURE as OrderUOM
INTO tmpPickLines
FROM   dbo.IN_DEMAND Picks
       INNER JOIN DimBin Bins
               ON Picks.LOCATION = Bins.LocationID
                  AND Picks.INV_ITEM_ID = Bins.ItemID
WHERE  LOCATION LIKE 'B%'
       AND CANCEL_DTTM IS NULL
       AND PICK_BATCH_ID <> 0
       AND IN_FULFILL_STATE = 70
ORDER  BY BinKey,
          Picks.DEMAND_DATE 


		  GO
		  
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
	   PO_LN.UNIT_OF_MEASURE as OrderUOM
INTO tmpPOLines
FROM   dbo.PO_LINE_DISTRIB PO_LN_DST
       INNER JOIN dbo.PO_LINE PO_LN
               ON PO_LN_DST.PO_ID = PO_LN.PO_ID
                  AND PO_LN_DST.LINE_NBR = PO_LN.LINE_NBR
       INNER JOIN dbo.PO_HDR
               ON PO_LN.PO_ID = PO_HDR.PO_ID
       INNER JOIN DimBin Bins
               ON PO_LN.INV_ITEM_ID = Bins.ItemID
                  AND Bins.LocationID = PO_LN_DST.LOCATION
       LEFT JOIN dbo.RECV_LN_SHIP SHIP
              ON PO_LN.PO_ID = SHIP.PO_ID
                 AND PO_LN.LINE_NBR = SHIP.LINE_NBR
WHERE  LOCATION LIKE 'B%'
ORDER  BY Bins.BinKey 

GO

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

GO

BEGIN Try
    DROP TABLE FactScan
END Try

BEGIN Catch
END Catch

Go

WITH Scans
     AS (SELECT Row_number()
                  OVER(
                    Partition BY c.BinKey
                    ORDER BY c.OrderDate DESC) AS Scanseq,
					Row_number()
                  OVER(
                    Partition BY c.BinKey
                    ORDER BY c.OrderDate ASC) AS ScanHistseq,
                c.BinKey,
                c.LocationID,
                c.ItemID,
                c.OrderTypeID,
                c.OrderType,
                c.CartCountNum,
                o.OrderNum,
                o.LineNum,
				o.OrderUOM,
                o.OrderQty,
                c.OrderDate,
                o.CloseDate
         FROM   tmpCartCounts c
                LEFT JOIN tmpOrders o
                       ON c.BinKey = o.BinKey
                          AND c.OrderSeq = o.OrderSeq
                          AND c.OrderType = o.OrderType
				WHERE OrderNum IS NOT NULL)
SELECT a.Scanseq,
	   a.BinKey,
       c.LocationKey,
       d.ItemKey,
       a.OrderTypeID,
       a.OrderType,
       a.CartCountNum,
       a.OrderNum,
       a.LineNum,
	   a.OrderUOM,
       Cast(a.OrderQty AS INT) AS OrderQty,
       a.OrderDate,
       a.CloseDate,
       b.OrderDate             AS PrevOrderDate,
       b.CloseDate             AS PrevOrderCloseDate,
	   1 as Scan,
       CASE
         WHEN Datediff(Day, b.OrderDate, a.OrderDate) < 3 THEN 1
         ELSE 0
       END                     AS HotScan,
       CASE
         WHEN a.OrderDate < COALESCE(b.CloseDate, GETDATE())
              AND a.ScanHistSeq > 2 THEN 1
         ELSE 0
       END                     AS StockOut
INTO FactScan
FROM   Scans a
       LEFT JOIN Scans b
              ON a.BinKey = b.BinKey
                 AND a.Scanseq = b.Scanseq - 1
       LEFT JOIN DimLocation c
              ON a.LocationID = c.LocationID
       LEFT JOIN DimItem d
              ON a.ItemID = d.ItemID
WHERE  a.OrderDate >= c.GoLiveDate 

GO

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

		  GO
		  
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


