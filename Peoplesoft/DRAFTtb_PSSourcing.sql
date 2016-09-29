
/***********************************************************

			Sourcing

***********************************************************/

IF EXISTS ( SELECT  *
            FROM    sys.objects
            WHERE   object_id = OBJECT_ID(N'tb_Sourcing')
                    AND type IN ( N'P', N'PC' ) ) 

DROP PROCEDURE  tb_Sourcing
GO

CREATE PROCEDURE	tb_Sourcing
--exec tb_Sourcing  select count(*) from tableau.Sourcing where PODate >= (select ConfigValue from bluebin.Config where ConfigName = 'PO_DATE')
AS

/********************************		DROP Sourcing		**********************************/

BEGIN TRY
    DROP TABLE tableau.Sourcing
END TRY

BEGIN CATCH
END CATCH

/**********************************		CREATE Temp Tables		***************************/

-- #tmpPOLines
declare @Facility int
   select @Facility = ConfigValue from bluebin.Config where ConfigName = 'PS_DefaultFacility'
  
SELECT Row_number()
                  OVER(
                    PARTITION BY PO_LN.INV_ITEM_ID, PO_LN_DST.LOCATION, PO_HDR.PO_DT
                    ORDER BY PO_LN.PO_ID, PO_LN.LINE_NBR) AS DailySeq,
                Bins.BinKey,
				--Bins.BinGoLiveDate,
                PO_LN.INV_ITEM_ID                         AS ItemID,
                PO_LN_DST.LOCATION                        AS LocationID,
                PO_LN.PO_ID                               AS OrderNum,
                PO_LN.LINE_NBR                            AS LineNum,
                RECEIPT_DTTM                              AS CloseDate,
                QTY_PO                                    AS OrderQty,
                PO_LN.UNIT_OF_MEASURE                     AS OrderUOM,
                PO_HDR.PO_DT
         FROM   dbo.PO_LINE_DISTRIB PO_LN_DST
                INNER JOIN dbo.PO_LINE PO_LN
                        ON PO_LN_DST.PO_ID = PO_LN.PO_ID
                           AND PO_LN_DST.LINE_NBR = PO_LN.LINE_NBR
                INNER JOIN dbo.PO_HDR
                        ON PO_LN.PO_ID = PO_HDR.PO_ID
                INNER JOIN bluebin.DimBin Bins
                        ON PO_LN.INV_ITEM_ID = Bins.ItemID
                           AND Bins.LocationID = PO_LN_DST.LOCATION
                LEFT JOIN dbo.RECV_LN_SHIP SHIP
                       ON PO_LN.PO_ID = SHIP.PO_ID
                          AND PO_LN.LINE_NBR = SHIP.LINE_NBR
                LEFT JOIN FirstScans
                       ON PO_LN.INV_ITEM_ID = FirstScans.ItemID
                          AND PO_LN_DST.LOCATION = FirstScans.LocationID
         WHERE  (LEFT(PO_LN_DST.LOCATION, 2) COLLATE DATABASE_DEFAULT IN (SELECT [ConfigValue] FROM   [bluebin].[Config] WHERE  [ConfigName] = 'REQ_LOCATION' AND Active = 1) 
				or PO_LN_DST.LOCATION COLLATE DATABASE_DEFAULT in (Select REQ_LOCATION from bluebin.ALT_REQ_LOCATION))
                AND PO_LN.CANCEL_STATUS NOT IN ( 'X', 'D' )


SELECT case when @Facility is not null or @Facility <> '' then @Facility else ''end	as COMPANY,
       PO_LN_DST.PO_ID as PO_NUMBER,
       PO_LN.RELEASE_NBR as PO_RELEASE,
       PO_HDR.PO_REF as PO_CODE,
       PO_LN.LINE_NBR,
       PO_LN.INV_ITEM_ID as ITEM,
       '' as ITEM_TYPE,
       '' PO_DESCRIPTION,
       PO_LN_DST.QTY_PO as QUANTITY,
       a.REC_QTY,
       a.AGREEMENT_REF,
       a.ENT_UNIT_CST,
       a.ENT_BUY_UOM,
       a.EBUY_UOM_MULT,
       b.PO_DATE,
       a.EARLY_DL_DATE,
       a.LATE_DL_DATE,
       a.REC_ACT_DATE,
       a.CLOSE_DATE,
       a.LOCATION,
       a.BUYER_CODE,
       a.VENDOR,
       d.OPER_COMPANY,
	   d.REQ_LOCATION,
       a.VEN_ITEM,
       a.CLOSED_FL,
       a.CXL_QTY,
       c.INVOICE_AMT
INTO   #tmpPOLines
         FROM   dbo.PO_LINE_DISTRIB PO_LN_DST
                INNER JOIN dbo.PO_LINE PO_LN
                        ON PO_LN_DST.PO_ID = PO_LN.PO_ID
                           AND PO_LN_DST.LINE_NBR = PO_LN.LINE_NBR
                INNER JOIN dbo.PO_HDR
                        ON PO_LN.PO_ID = PO_HDR.PO_ID
                INNER JOIN bluebin.DimBin Bins
                        ON PO_LN.INV_ITEM_ID = Bins.ItemID
                           AND Bins.LocationID = PO_LN_DST.LOCATION
                LEFT JOIN dbo.RECV_LN_SHIP SHIP
                       ON PO_LN.PO_ID = SHIP.PO_ID
                          AND PO_LN.LINE_NBR = SHIP.LINE_NBR
WHERE  b.PO_DATE >= (select ConfigValue from bluebin.Config where ConfigName = 'PO_DATE') 
		--AND b.PO_RELEASE = 0
       AND a.CXL_QTY = 0
	   
	   --and a.PO_NUMBER like '%380479%'


--#tmpPOStatus
SELECT Row_number()
         OVER(
           ORDER BY a.PO_NUMBER, a.LINE_NBR) AS POKey,
       COMPANY                           AS Company,
       a.PO_NUMBER                         AS PONumber,
       a.LINE_NBR                          AS POLineNumber,
       PO_RELEASE                        AS PORelease,
       PO_CODE                           AS POCode,
       ITEM                              AS ItemNumber,
	   a.VENDOR                            AS VendorCode,
	   --d.VENDOR_VNAME					AS VendorName,
       a.BUYER_CODE                        AS Buyer,
	   --c.NAME							AS BuyerName,
       LOCATION                          AS ShipLocation,
       --ACCT_UNIT                         AS AcctUnit,
       --ACCT_UNIT_NAME                    AS AcctUnitName,
       PO_DESCRIPTION                    AS PODescr,
       QUANTITY                          AS QtyOrdered,
       REC_QTY                           AS QtyReceived,
       AGREEMENT_REF                     AS AgrmtRef,
       ENT_UNIT_CST                      AS UnitCost,
       ENT_BUY_UOM                       AS BuyUOM,
       EBUY_UOM_MULT                     AS BuyUOMMult,
	   ENT_UNIT_CST/EBUY_UOM_MULT		 AS IndividualCost,
       PO_DATE                           AS PODate,
       EARLY_DL_DATE                     AS ExpectedDeliveryDate,
       LATE_DL_DATE                      AS LateDeliveryDate,
       REC_ACT_DATE                      AS ReceivedDate,
       CLOSE_DATE                        AS CloseDate,
       REQ_LOCATION                      AS PurchaseLocation,
       OPER_COMPANY                      AS PurchaseFacility,
	   VEN_ITEM                          AS VendorItemNbr,
       CLOSED_FL                         AS ClosedFlag,
       CXL_QTY                           AS QtyCancelled,
       QUANTITY * ENT_UNIT_CST           AS POAmt,
       INVOICE_AMT                       AS InvoiceAmt,
       ITEM_TYPE                         AS POItemType,
       CASE
         WHEN ITEM_TYPE = 'S' THEN 0
         ELSE
           CASE
             WHEN REC_QTY = 0 THEN 0
             ELSE INVOICE_AMT - ( REC_QTY * ENT_UNIT_CST )
           END
       END                               AS PPV,
       1                                 AS POLine
INTO #tmpPOStatus
FROM   #tmpPOLines a

		--LEFT JOIN (select distinct BUYER_CODE,NAME from BUYER) c
		--ON a.BUYER_CODE = c.BUYER_CODE
		--LEFT JOIN APVENMAST d ON a.VENDOR = d.VENDOR


--#tmpPOs

SELECT *,
CASE WHEN ClosedFlag = 'Y' THEN 'Closed' ELSE
	CASE WHEN QtyReceived + QtyCancelled = QtyOrdered THEN 'Closed' ELSE 'Open' END
	END 																as POStatus,
CASE WHEN POItemType = 'S' THEN 'N/A' ELSE
	CASE WHEN Dateadd(day, 3, ExpectedDeliveryDate) <= GETDATE() AND (QtyReceived+QtyCancelled < QtyOrdered) THEN 'Late' ELSE
		CASE WHEN Dateadd(day, 3, ExpectedDeliveryDate) > GETDATE() THEN 'In-Progress' ELSE
			CASE WHEN ReceivedDate <= Dateadd(day, 3, ExpectedDeliveryDate) AND (QtyReceived + QtyCancelled) = QtyOrdered THEN 'On-Time' ELSE 'Late' END
		END	
	
	END

END as PODeliveryStatus
INTO #tmpPOs
FROM #tmpPOStatus


/*************************		CREATE Sourcing		****************************/

SELECT a.*,
       CASE
         WHEN a.PODeliveryStatus = 'In-Progress' THEN 1
         ELSE 0
       END AS InProgress,
       CASE
         WHEN a.PODeliveryStatus = 'On-Time' THEN 1
         ELSE 0
       END AS OnTime,
       CASE
         WHEN a.PODeliveryStatus = 'Late' THEN 1
         ELSE 0
       END AS Late,
	   case when dl.BlueBinFlag = 1 then 'Yes' else 'No' end as BlueBinFlag,
	   df.FacilityName

--INTO   tableau.Sourcing 
FROM   #tmpPOs a
LEFT JOIN bluebin.DimLocation dl on ltrim(rtrim(a.PurchaseLocation)) = ltrim(rtrim(dl.LocationID)) and ltrim(rtrim(a.PurchaseFacility)) = ltrim(rtrim(dl.LocationFacility))
LEFT JOIN bluebin.DimFacility df on ltrim(rtrim(a.PurchaseFacility)) = ltrim(rtrim(df.FacilityID))
/***********************		DROP Temp Tables	**************************/

DROP TABLE #tmpPOLines
DROP TABLE #tmpMMDIST
DROP TABLE #tmpPOStatus
DROP TABLE #tmpPOs

GO

UPDATE etl.JobSteps
SET LastModifiedDate = GETDATE()
WHERE StepName = 'Sourcing'

GO
grant exec on tb_Sourcing to public
GO




