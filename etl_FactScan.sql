
/*************************************************

			FactScan

*************************************************/

IF EXISTS ( SELECT  *
            FROM    sys.objects
            WHERE   object_id = OBJECT_ID(N'etl_FactScan')
                    AND type IN ( N'P', N'PC' ) ) 

DROP PROCEDURE  etl_FactScan
GO

CREATE PROCEDURE etl_FactScan

AS

/*****************************		DROP FactScan		*******************************/

BEGIN Try
    DROP TABLE bluebin.FactScan
END Try

BEGIN Catch
END Catch

--/********************************		CREATE Temp Tables			******************************/

SELECT COMPANY,
       CASE 
			WHEN LEN(DOCUMENT) = 10 and LEFT(DOCUMENT,6) = '000000' THEN RIGHT(DOCUMENT,4)
			WHEN LEN(DOCUMENT) = 10 and LEFT(DOCUMENT,5) = '00000' THEN RIGHT(DOCUMENT,5)
			WHEN LEN(DOCUMENT) = 10 and LEFT(DOCUMENT,4) = '0000' THEN RIGHT(DOCUMENT,6)
			WHEN LEN(DOCUMENT) = 10 and LEFT(DOCUMENT,3) = '000' THEN RIGHT(DOCUMENT,7)
		ELSE DOCUMENT 
		END AS DOCUMENT,
       LINE_NBR,
	   SUM((QUANTITY*-1)) as QUANTITY,
       MAX((Cast(CONVERT(VARCHAR, TRANS_DATE, 101) + ' '
            + LEFT(RIGHT('00000' + CONVERT(VARCHAR, ACTUAL_TIME), 4), 2)
            + ':'
            + Substring(RIGHT('00000' + CONVERT(VARCHAR, ACTUAL_TIME), 4), 3, 2) AS DATETIME))) AS TRANS_DATE
INTO #ICTRANS
FROM   ICTRANS a
       INNER JOIN bluebin.DimLocation b
               ON a.FROM_TO_LOC = b.LocationID 
WHERE b.BlueBinFlag = 1 and DOCUMENT not like '%[A-Z]%' and DOCUMENT not like '%/%' and try_convert(bigint,DOCUMENT) < 2147483647  
--and DOCUMENT like '%270943%'
group by 
COMPANY,
       CASE 
			WHEN LEN(DOCUMENT) = 10 and LEFT(DOCUMENT,6) = '000000' THEN RIGHT(DOCUMENT,4)
			WHEN LEN(DOCUMENT) = 10 and LEFT(DOCUMENT,5) = '00000' THEN RIGHT(DOCUMENT,5)
			WHEN LEN(DOCUMENT) = 10 and LEFT(DOCUMENT,4) = '0000' THEN RIGHT(DOCUMENT,6)
			WHEN LEN(DOCUMENT) = 10 and LEFT(DOCUMENT,3) = '000' THEN RIGHT(DOCUMENT,7)
		ELSE DOCUMENT 
		END,
       LINE_NBR
--select * from ICTRANS where DOCUMENT like '%270943%'

SELECT COMPANY,
	   CASE 
			WHEN LEN(REQ_NUMBER) = 10 and LEFT(REQ_NUMBER,6) = '000000' THEN RIGHT(REQ_NUMBER,4)
			WHEN LEN(REQ_NUMBER) = 10 and LEFT(REQ_NUMBER,5) = '00000' THEN RIGHT(REQ_NUMBER,5)
			WHEN LEN(REQ_NUMBER) = 10 and LEFT(REQ_NUMBER,4) = '0000' THEN RIGHT(REQ_NUMBER,6)
			WHEN LEN(REQ_NUMBER) = 10 and LEFT(REQ_NUMBER,3) = '000' THEN RIGHT(REQ_NUMBER,7)
		ELSE REQ_NUMBER 
		END AS REQ_NUMBER,
       LINE_NBR,
       ITEM,
       REQ_LOCATION,
       ENTERED_UOM,
       QUANTITY,
       ITEM_TYPE,
       CREATION_TIME,
	   CLOSED_FL,
       Cast(CONVERT(VARCHAR, CREATION_DATE, 101) + ' '
            + LEFT(RIGHT('00000' + CONVERT(VARCHAR, CREATION_TIME), 8), 2)
            + ':'
            + Substring(RIGHT('00000' + CONVERT(VARCHAR, CREATION_TIME), 8), 3, 2)
            + ':'
            + Substring(RIGHT('00000' + CONVERT(VARCHAR, CREATION_TIME), 8), 5, 2) AS DATETIME) AS CREATION_DATE
INTO #REQLINE
FROM   REQLINE
WHERE  STATUS = 9
       AND KILL_QUANTITY = 0 
--and REQ_NUMBER like '%603585%'

SELECT 
a.COMPANY,
		CASE
			WHEN LEN(a.SOURCE_DOC_N) = 10 and LEFT(a.SOURCE_DOC_N,6) = '000000' THEN RIGHT(a.SOURCE_DOC_N,4)
			WHEN LEN(a.SOURCE_DOC_N) = 10 and LEFT(a.SOURCE_DOC_N,5) = '00000' THEN RIGHT(a.SOURCE_DOC_N,5)
			WHEN LEN(a.SOURCE_DOC_N) = 10 and LEFT(a.SOURCE_DOC_N,4) = '0000' THEN RIGHT(a.SOURCE_DOC_N,6)
			WHEN LEN(a.SOURCE_DOC_N) = 10 and LEFT(a.SOURCE_DOC_N,3) = '000' THEN RIGHT(a.SOURCE_DOC_N,7)	
		ELSE a.SOURCE_DOC_N 
		END AS REQ_NUMBER,
       a.SRC_LINE_NBR                                                                         AS LINE_NBR,
       MIN(Cast(CONVERT(VARCHAR, b.REC_DATE, 101) + ' '
			+ LEFT(RIGHT('00000' + CONVERT(VARCHAR, case when b.UPDATE_TIME is null then '00000000' else b.UPDATE_TIME end), 8), 2)
            + ':'
            + Substring(RIGHT('00000' + CONVERT(VARCHAR, case when b.UPDATE_TIME is null then '00000000' else b.UPDATE_TIME end), 8), 3, 2)
            + ':'
            + Substring(RIGHT('00000' + CONVERT(VARCHAR, case when b.UPDATE_TIME is null then '00000000' else b.UPDATE_TIME end), 8), 5, 2) AS DATETIME)) AS REC_DATE

INTO #POLINE
FROM   POLINESRC a
       LEFT JOIN PORECLINE b
               ON a.PO_NUMBER = b.PO_NUMBER
                  AND a.LINE_NBR = b.PO_LINE_NBR
					AND a.COMPANY = b.COMPANY 


GROUP BY
	a.COMPANY,
	a.SOURCE_DOC_N,
	a.SRC_LINE_NBR



Select
b.COMPANY,
CASE
			WHEN LEN(a.SOURCE_DOC_N) = 10 and LEFT(a.SOURCE_DOC_N,6) = '000000' THEN RIGHT(a.SOURCE_DOC_N,4)
			WHEN LEN(a.SOURCE_DOC_N) = 10 and LEFT(a.SOURCE_DOC_N,5) = '00000' THEN RIGHT(a.SOURCE_DOC_N,5)
			WHEN LEN(a.SOURCE_DOC_N) = 10 and LEFT(a.SOURCE_DOC_N,4) = '0000' THEN RIGHT(a.SOURCE_DOC_N,6)
			WHEN LEN(a.SOURCE_DOC_N) = 10 and LEFT(a.SOURCE_DOC_N,3) = '000' THEN RIGHT(a.SOURCE_DOC_N,7)	
		ELSE a.SOURCE_DOC_N 
		END AS REQ_NUMBER,
        a.SRC_LINE_NBR                                                                         AS LINE_NBR, 
		CLOSE_DATE   as CancelDate
INTO #CancelledLines
FROM POLINE b
INNER JOIN POLINESRC a on b.COMPANY = a.COMPANY and b.PO_NUMBER = a.PO_NUMBER AND b.LINE_NBR = a.LINE_NBR
WHERE b.CXL_QTY = b.QUANTITY and b.CLOSED_FL = 'Y' --and a.SOURCE_DOC_N like '%270943%'




SELECT 
Row_number()
         OVER(
           Partition BY b.BinKey
           ORDER BY a.CREATION_DATE DESC) AS Scanseq,
       Row_number()
         OVER(
           Partition BY b.BinKey
           ORDER BY a.CREATION_DATE ASC) AS ScanHistseq,
       a.COMPANY					AS OrderFacility,
	   b.BinKey,
	   b.BinLeadTime,
       b.LocationID,
       b.ItemID,
       b.BinGoLiveDate,
       a.ITEM_TYPE                   AS ItemType,
       a.REQ_NUMBER                  AS OrderNum,
       a.LINE_NBR                    AS LineNum,
       a.ENTERED_UOM                 AS OrderUOM,
       a.QUANTITY                    AS OrderQty,
       a.CREATION_DATE               AS OrderDate,
       CASE
         WHEN a.ITEM_TYPE = 'I' and e.QUANTITY >= a.QUANTITY OR a.ITEM_TYPE = 'I' and a.CLOSED_FL = 'Y' --Additional logic to add if checking for Quantity on the ICTrans.  Not currently doing so.*/
			THEN e.TRANS_DATE
         WHEN a.ITEM_TYPE = 'N' 
			THEN c.REC_DATE 
         ELSE NULL
       END                           AS OrderCloseDate,
	   case 
	   when a.CLOSED_FL = 'Y' and ((c.REQ_NUMBER is null and a.ITEM_TYPE = 'N') or (e.DOCUMENT is null and e.TRANS_DATE is null and a.ITEM_TYPE = 'I')) then a.CREATION_DATE
	   else d.CancelDate end as OrderCancelDate
INTO   #tmpScan  
FROM   #REQLINE a
       INNER JOIN bluebin.DimBin b
               ON a.ITEM = b.ItemID
                  AND a.REQ_LOCATION = b.LocationID
				  AND a.COMPANY = b.BinFacility
       LEFT JOIN #POLINE c 
			ON a.REQ_NUMBER = c.REQ_NUMBER 
			AND a.LINE_NBR = c.LINE_NBR
			--AND a.COMPANY = c.COMPANY		--Remove case if Multiple Companies
	   --LEFT JOIN  (select COMPANY,DOCUMENT,LINE_NBR,max(TRANS_DATE) as TRANS_DATE from #ICTRANS group by COMPANY,DOCUMENT,LINE_NBR) e --Different join logic if you remove the group in the #ICTRANS table
	   LEFT JOIN #ICTRANS e
               ON a.REQ_NUMBER = e.DOCUMENT
               AND a.LINE_NBR = e.LINE_NBR
			--AND a.COMPANY = e.COMPANY		--Remove case if Multiple Companies
		LEFT JOIN #CancelledLines d 
			ON a.REQ_NUMBER = d.REQ_NUMBER 
			AND a.LINE_NBR = d.LINE_NBR
			--and a.COMPANY = d.COMPANY		--Remove case if Multiple Companies


/***********************************		CREATE FactScan		****************************************/
declare @DefaultLT int = (Select max(ConfigValue) from bluebin.Config where ConfigName = 'DefaultLeadTime')

SELECT a.Scanseq,
       a.ScanHistseq,
       a.BinKey,
       c.LocationKey,
       d.ItemKey,
       a.BinGoLiveDate,
       a.OrderNum,
       a.LineNum,
       a.ItemType,
       a.OrderUOM,
       Cast(a.OrderQty AS INT) AS OrderQty,
       a.OrderDate,
       case when (a.OrderCancelDate is not null and a.ItemType <> 'I') or (a.OrderCancelDate is not null and a.ItemType = 'I') then a.OrderCancelDate else a.OrderCloseDate end as OrderCloseDate,
       b.OrderDate             AS PrevOrderDate,
       case when b.OrderCancelDate is not null  and a.ItemType <> 'I' then b.OrderCancelDate else b.OrderCloseDate end AS PrevOrderCloseDate,
       1                       AS Scan,
       CASE
         WHEN Datediff(Day, b.OrderDate, a.OrderDate) < COALESCE(a.BinLeadTime,@DefaultLT,3) THEN 1
         ELSE 0
       END                     AS HotScan,
       CASE
         WHEN a.OrderDate < COALESCE(b.OrderCloseDate, b.OrderCancelDate, Getdate())
              AND a.ScanHistseq > (select ConfigValue + 1 from bluebin.Config where ConfigName = 'ScanThreshold') THEN 1 --When looking for stockouts you have to take the scanseq 2 after the ignored one
         ELSE 0
       END                     AS StockOut
INTO   bluebin.FactScan
FROM   #tmpScan a
       LEFT JOIN #tmpScan b
              ON a.BinKey = b.BinKey
                 AND a.Scanseq = b.Scanseq - 1
       LEFT JOIN bluebin.DimLocation c
              ON a.LocationID = c.LocationID	
			  AND a.OrderFacility = c.LocationFacility		
       LEFT JOIN bluebin.DimItem d
              ON a.ItemID = d.ItemID 
--where a.OrderNum like '%606841%'
order by a.BinKey,a.OrderDate
/*****************************************		DROP Temp Tables		*******************************/

DROP TABLE #REQLINE
DROP TABLE #ICTRANS
DROP TABLE #POLINE
DROP TABLE #tmpScan
DROP TABLE #CancelledLines



GO

UPDATE etl.JobSteps
SET LastModifiedDate = GETDATE()
WHERE StepName = 'FactScan'
