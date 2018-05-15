
/*************************************************

			FactScan

*************************************************/
--Edited 20180209 GB

IF EXISTS ( SELECT  *
            FROM    sys.objects
            WHERE   object_id = OBJECT_ID(N'etl_FactScan')
                    AND type IN ( N'P', N'PC' ) ) 

DROP PROCEDURE  etl_FactScan
GO

CREATE PROCEDURE etl_FactScan
--exec etl_FactScan
AS

/*****************************		DROP FactScan		*******************************/

BEGIN Try
    DROP TABLE bluebin.FactScan
END Try

BEGIN Catch
END Catch

--select * from PO_LINE_DISTRIB where LOCATION like '%BB%'
--select * from PO_LINE where PO_ID in (select PO_ID from PO_LINE_DISTRIB where LOCATION like '%BB%')
--select * from PO_HDR where PO_ID in (select PO_ID from PO_LINE_DISTRIB where LOCATION like '%BB%')


--**************************
declare @DefaultLT int = (Select max(ConfigValue) from bluebin.Config where ConfigName = 'DefaultLeadTime')
declare @POTimeAdjust int = (Select max(ConfigValue) from bluebin.Config where ConfigName = 'PS_POTimeAdjust')
;
WITH FirstScans
     AS (
/* Original Query	 
	 SELECT INV_CART_ID      AS LocationID,
                INV_ITEM_ID      AS ItemID,
                Min(DEMAND_DATE) AS FirstScanDate
         FROM   dbo.CART_CT_INF_INV
         WHERE  CART_COUNT_QTY > 0
                AND PROCESS_INSTANCE > 0
         GROUP  BY INV_CART_ID,
                   INV_ITEM_ID
				   */
		select
		LocationID,
		ItemID,
		COALESCE(DEMAND_DATE,SCHED_DTTM,LOC_DATE,BIN_DATE,NULL) as FirstScanDate
		from 
				(
				SELECT db.LocationID,
					   db.ItemID,
					   lt.LOC_DATE,
						Min(ct.DEMAND_DATE) AS DEMAND_DATE,
						min(id.SCHED_DTTM) as SCHED_DTTM,
						min(db.BinGoLiveDate) as BIN_DATE
				 FROM   bluebin.DimBin db
				 LEFT JOIN dbo.CART_CT_INF_INV ct on db.LocationID = ct.INV_CART_ID and db.ItemID = ct.INV_ITEM_ID and ct.CART_COUNT_QTY > 0 AND ct.PROCESS_INSTANCE > 0
				 LEFT JOIN IN_DEMAND id on db.LocationID = id.LOCATION and db.ItemID = id.INV_ITEM_ID
				 LEFT JOIN (Select INV_CART_ID,min(DEMAND_DATE) as LOC_DATE from dbo.CART_CT_INF_INV where CART_COUNT_QTY > 0 AND PROCESS_INSTANCE > 0 group by INV_CART_ID) lt on db.LocationID = lt.INV_CART_ID 
				 GROUP  BY 
				 db.LocationID,
				 db.ItemID,
				 lt.LOC_DATE
				  ) a 
				   
				   )
				   
				   ,

--**************************
Orders
     AS (
	 SELECT Row_number()
                  OVER(
                    PARTITION BY Bins.ItemID, PO_LN_DST.LOCATION, PO_HDR.PO_DT
                    ORDER BY PO_LN.PO_ID, PO_LN.LINE_NBR) AS DailySeq,
                Bins.BinKey,
				--Bins.BinGoLiveDate,
                Bins.ItemID									AS ItemID, --Original PO_LN.INV_ITEM_ID
                PO_LN_DST.LOCATION                        AS LocationID,
                PO_LN.PO_ID                               AS OrderNum,
                PO_LN.LINE_NBR                            AS LineNum,
                SHIP.RECEIPT_DTTM                         AS CloseDate,
                QTY_PO                                    AS OrderQty,
                PO_LN.UNIT_OF_MEASURE                     AS OrderUOM,
                DATEADD(hour,@POTimeAdjust,PO_HDR.PO_DT) as PO_DT
				--PO_HDR.PO_DT
         FROM   dbo.PO_LINE_DISTRIB PO_LN_DST
                INNER JOIN dbo.PO_LINE PO_LN
                        ON PO_LN_DST.PO_ID = PO_LN.PO_ID
                           AND PO_LN_DST.LINE_NBR = PO_LN.LINE_NBR
                INNER JOIN dbo.PO_HDR
                        ON PO_LN.PO_ID = PO_HDR.PO_ID
							AND PO_LN.BUSINESS_UNIT = PO_HDR.BUSINESS_UNIT
                INNER JOIN bluebin.DimBin Bins
                        ON RIGHT(('000000000000000000' + PO_LN.INV_ITEM_ID),18) = RIGHT(('000000000000000000' + Bins.ItemID),18) 
                           AND Bins.LocationID = PO_LN_DST.LOCATION
                LEFT JOIN
					(select PO_ID,LINE_NBR,max(RECEIPT_DTTM) as RECEIPT_DTTM from dbo.RECV_LN_SHIP group by PO_ID,LINE_NBR) SHIP
						ON PO_LN.PO_ID = SHIP.PO_ID
                          AND PO_LN.LINE_NBR = SHIP.LINE_NBR
				--LEFT JOIN dbo.RECV_LN_SHIP SHIP
    --                   ON PO_LN.PO_ID = SHIP.PO_IDselect * from RECV_LN_SHIP 
    --                      AND PO_LN.LINE_NBR = SHIP.LINE_NBR
                LEFT JOIN FirstScans
                       ON RIGHT(('000000000000000000' + PO_LN.INV_ITEM_ID),18) = RIGHT(('000000000000000000' + FirstScans.ItemID),18)
                          AND PO_LN_DST.LOCATION = FirstScans.LocationID
         WHERE  (LEFT(PO_LN_DST.LOCATION, 2) COLLATE DATABASE_DEFAULT IN (SELECT [ConfigValue] FROM   [bluebin].[Config] WHERE  [ConfigName] = 'REQ_LOCATION' AND Active = 1) 
				or PO_LN_DST.LOCATION COLLATE DATABASE_DEFAULT in (Select REQ_LOCATION from bluebin.ALT_REQ_LOCATION))
                AND ISNULL(PO_LN.CANCEL_STATUS,'') NOT IN ( 'X', 'D', 'PX' )
				--AND PO_LN_DST.LOCATION = '16401PED02' and PO_LN.INV_ITEM_ID = '100177' and PO_LN.PO_ID = '0000008230' 
				--and DATEADD(hour,@POTimeAdjust,PO_HDR.PO_DT) > getdate() -5
                --AND PO_LN_DST.BUSINESS_UNIT_GL = 209
		GROUP BY 
				Bins.BinKey,
				PO_LN_DST.LOCATION,
				Bins.ItemID, --Original PO_LN.INV_ITEM_ID
                PO_LN.PO_ID,
                PO_LN.LINE_NBR,
                SHIP.RECEIPT_DTTM,
				QTY_PO,
                PO_LN.UNIT_OF_MEASURE,
                PO_HDR.PO_DT
				)
				
				
				,



--**************************
CartCounts
     AS (SELECT Row_number()
                  OVER(
                    PARTITION BY INV_CART_ID, INV_ITEM_ID, DEMAND_DATE
                    ORDER BY LAST_DTTM_UPDATE) AS DailySeq,
                INV_CART_ID                    AS LocationID,
                INV_ITEM_ID					   AS ItemID,
                DEMAND_DATE                    AS PO_DT,
                LAST_DTTM_UPDATE               AS SCAN_DATE
				--CART_COUNT_QTY
         FROM   dbo.CART_CT_INF_INV
         WHERE  --CART_COUNT_QTY <> 0 AND
                --AND CART_REPLEN_OPT = '02'
				(LEFT(INV_CART_ID, 2) COLLATE DATABASE_DEFAULT IN (SELECT [ConfigValue] FROM   [bluebin].[Config] WHERE  [ConfigName] = 'REQ_LOCATION' AND Active = 1) 
				or INV_CART_ID COLLATE DATABASE_DEFAULT in (Select REQ_LOCATION from bluebin.ALT_REQ_LOCATION))),
--**************************
tmpLines AS (
SELECT a.BinKey,
       --a.BinGoLiveDate,
	   a.ItemID,
       a.LocationID,
       a.OrderNum,
       a.LineNum,
       COALESCE(b.SCAN_DATE,a.PO_DT)                 AS OrderDate,
       a.CloseDate,
       a.OrderQty,
       a.OrderUOM,
	   'PO' as OrderType,
		'No' as Cancelled
FROM   Orders a
       LEFT JOIN CartCounts b
               ON a.LocationID = b.LocationID
                  AND a.ItemID = b.ItemID
                  AND a.PO_DT = b.PO_DT
                  AND a.DailySeq = b.DailySeq 

UNION ALL
SELECT Bins.BinKey,
--Bins.BinGoLiveDate,
       INV_ITEM_ID as ItemID,
       LOCATION as LocationID,
       Picks.ORDER_NO as OrderNum,
       Picks.ORDER_INT_LINE_NO as LineNum,
       Picks.SCHED_DTTM as OrderDate,
       Picks.PICK_CONFIRM_DTTM as CloseDate,
       Cast(Picks.QTY_REQUESTED AS INT) AS OrderQty,
	   UNIT_OF_MEASURE as OrderUOM,
	   CASE
         WHEN Picks.ORDER_NO LIKE 'MSR%' THEN 'MSR'
         ELSE 'Pick' end as OrderType,
		case when IN_FULFILL_STATE = '70' and QTY_PICKED = '0' or IN_FULFILL_STATE = '90' then 'Yes' else 'No' end as Cancelled

FROM   dbo.IN_DEMAND Picks
       INNER JOIN bluebin.DimBin Bins
               ON Picks.LOCATION = Bins.LocationID
                  AND Picks.INV_ITEM_ID = Bins.ItemID
		LEFT JOIN FirstScans
		ON Picks.INV_ITEM_ID = FirstScans.ItemID AND Picks.LOCATION = FirstScans.LocationID
WHERE  (LEFT(LOCATION, 2) COLLATE DATABASE_DEFAULT IN (SELECT [ConfigValue] FROM   [bluebin].[Config] WHERE  [ConfigName] = 'REQ_LOCATION' AND Active = 1) 
		or LOCATION COLLATE DATABASE_DEFAULT in (Select REQ_LOCATION from bluebin.ALT_REQ_LOCATION))
       AND (CANCEL_DTTM IS NULL  or CANCEL_DTTM < '1900-01-02')
	   AND DEMAND_DATE >= FirstScanDate --ISNULL(FirstScanDate,Bins.BinGoLiveDate)

	   )
	   
	   ,
--**************************	   
tmpOrders 
	AS (
	SELECT Row_number()
         OVER(
           Partition BY BinKey
           ORDER BY OrderDate) AS OrderSeq,
		   *
       --*,
       --CASE
       --  WHEN OrderNum LIKE 'MSR%' THEN 'MSR'
       --  ELSE 'PO'
       --END                     AS OrderType

FROM   tmpLines
where Cancelled = 'No'
),

--**************************
Scans
     AS (
  SELECT Row_number()
                  OVER(
                    Partition BY o.BinKey
                    ORDER BY o.OrderDate DESC) AS Scanseq,
					Row_number()
                  OVER(
                    Partition BY o.BinKey
                    ORDER BY o.OrderDate ASC) AS ScanHistseq,
                o.BinKey,
				--o.BinGoLiveDate,
                o.LocationID,
                o.ItemID,
                '' as OrderTypeID,
                o.OrderType,
                '' as CartCountNum,
                o.OrderNum,
                o.LineNum,
				o.OrderUOM,
                o.OrderQty,
                o.OrderDate,
                o.CloseDate
        FROM   
               tmpOrders o
			    
				)--select * from Scans where BinKey = '825' order by OrderDate


				
SELECT a.Scanseq,
		a.ScanHistseq,
	   a.BinKey,
       c.LocationKey,
       d.ItemKey,
	   db.BinGoLiveDate,
       --COALESCE(a.OrderTypeID, '-') as OrderTypeID,  
       --COALESCE(a.CartCountNum, 0) as CartCountNum --Old PS field,
       a.OrderNum,
       a.LineNum,
	   case when a.OrderType = 'MSR' or a.OrderType = 'Pick' then 'I'
			else 'N' end as ItemType,
	   a.OrderUOM,
       Cast(a.OrderQty AS INT) AS OrderQty,
       a.OrderDate,
       case when a.CloseDate < '1900-01-01' then NULL else a.CloseDate end as OrderCloseDate,
       b.OrderDate             AS PrevOrderDate,
       case when b.CloseDate < '1900-01-01' then NULL else b.CloseDate end AS PrevOrderCloseDate,
	   1 as Scan,
       CASE
         WHEN Datediff(Day, b.OrderDate, a.OrderDate) < COALESCE(db.BinLeadTime,@DefaultLT,3) THEN 1
         ELSE 0
       END                     AS HotScan,
       CASE
         WHEN a.OrderDate < COALESCE(b.CloseDate, Getdate())
              AND a.ScanHistseq > (select ConfigValue + 1 from bluebin.Config where ConfigName = 'ScanThreshold') THEN 1 --When looking for stockouts you have to take the scanseq 2 after the ignored one
         ELSE 0
       END                     AS StockOut

into bluebin.FactScan
FROM   Scans a
       INNER JOIN bluebin.DimBin db on a.BinKey = db.BinKey
	   LEFT JOIN Scans b
              ON a.BinKey = b.BinKey
                 AND a.Scanseq = b.Scanseq - 1
       LEFT JOIN bluebin.DimLocation c
              ON a.LocationID = c.LocationID
       LEFT JOIN bluebin.DimItem d
              ON a.ItemID = d.ItemID
	   
WHERE  a.OrderDate >= db.BinGoLiveDate and a.OrderUOM <> '0' and a.OrderQty <> '0'--and a.OrderDate > getdate() -360--and d.ItemKey = '18710' and 
--and a.OrderNum = '0000383593'
Order by BinKey,ScanHistseq asc



GO

UPDATE etl.JobSteps
SET LastModifiedDate = GETDATE()
WHERE StepName = 'FactScan'

GO