
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
--exec tb_Sourcing  
AS

/********************************		DROP Sourcing		**********************************/

BEGIN TRY
    DROP TABLE tableau.Sourcing
END TRY

BEGIN CATCH
END CATCH

/**********************************		CREATE Temp Tables		***************************/
/*
select distinct BUSINESS_UNIT from PO_HDR
select top 100* from PO_HDR
select top 100* from PO_LINE
select top 1000* from PO_LINE_DISTRIB
select top 100* from RECV_LN_SHIP --where INV_ITEM_ID = '206460'
select top 100* from MASTER_ITEM_TBL
select top 100* from BRAND_NAMES_INV
select top 1000* from MANUFACTURER order by 3
select * from insert select * into Stanford_LPCH.tableau.Sourcing from OSUMC.tableau.Sourcing
select top 1000* from OSUMC.tableau.Sourcing

*/
-- #tmpPOLines
declare @Facility int
   select @Facility = ConfigValue from bluebin.Config where ConfigName = 'PS_DefaultFacility'
declare @POTimeAdjust int = (Select max(ConfigValue) from bluebin.Config where ConfigName = 'PS_POTimeAdjust')
  
SELECT Row_number()
                  OVER(
                    ORDER BY PO_LN.PO_ID, PO_LN.LINE_NBR) AS POKey,
                @Facility as Company,
				PO_LN.PO_ID as PONumber,
				--PO_LN.PO_ID as PONumber,
				PO_LN.LINE_NBR AS LineNum,
				0 as PORelease,							--NEED
				PO_LN.PO_ID AS POCode,
                PO_LN.INV_ITEM_ID  AS ItemNumber,
                PO_HDR.VENDOR_ID as VendorCode,
				'' as VendorName,						--NEED
				PO_HDR.BUYER_ID as Buyer,
				PO_HDR.BUYER_ID as BuyerName,			--NEED
				'' as ShipLocation,						--NEED
				PO_LN_DST.ACCOUNT as AcctUnit,			
				'' as AcctUnitName,						--NEED
				MIT.DESCR as PODescr,
				PO_LN_DST.QTY_PO as QtyOrdered,
				0 as QtyReceived,						--NEED
				PO_LN.CNTRCT_ID as AgrmtRef,
				0 as UnitCost,							--NEED
				PO_LN.UNIT_OF_MEASURE as BuyUOM,
				'' as BuyUOMMult,						--NEED
				0 as IndividualCost,					--NEED
				DATEADD(hour,@POTimeAdjust,PO_HDR.PO_DT) as PODate,
				--PO_HDR.PO_DT as PODate,
				'' as ExpectedDeliveryDate,				--NEED
				'' as LateDeliveryDate,					--NEED
				SHIP.RECEIPT_DTTM as ReceivedDate,
				'' as CloseDate,						--NEED
				PO_LN_DST.LOCATION AS PurchaseLocation,
                @Facility as PurchaseFacility,
				'' as VendorItemNbr,					--NEED
				'' as ClosedFlag,						--NEED
				'' as QtyCancelled,						--NEED
				'' as POAmt,							--NEED
				'' as InvoiceAmt,						--NEED
				'' as POItemType,						--NEED
				'' as PPV,								--NEED
				'1' as POLine,						
				PO_HDR.PO_STATUS as POStatus,			
				PO_HDR.PO_STATUS as PODeliveryStatus,	
				'' as InProgress,						--NEED
				'' as OnTime,							--NEED
				'' as Late,								--NEED
				dl.BlueBinFlag,							--NEED
				(select FacilityName from bluebin.DimFacility where FacilityID = @Facility) as FacilityName,
				dl.LocationName



         into tableau.Sourcing     
         FROM   dbo.PO_LINE_DISTRIB PO_LN_DST
                INNER JOIN dbo.PO_LINE PO_LN
                        ON PO_LN_DST.PO_ID = PO_LN.PO_ID
                           AND PO_LN_DST.LINE_NBR = PO_LN.LINE_NBR
                INNER JOIN dbo.PO_HDR
                        ON PO_LN.PO_ID = PO_HDR.PO_ID
                LEFT JOIN
					(select PO_ID,LINE_NBR,max(RECEIPT_DTTM) as RECEIPT_DTTM from dbo.RECV_LN_SHIP group by PO_ID,LINE_NBR) SHIP
						ON PO_LN.PO_ID = SHIP.PO_ID
                          AND PO_LN.LINE_NBR = SHIP.LINE_NBR
				INNER JOIN MASTER_ITEM_TBL MIT on PO_LN.INV_ITEM_ID = MIT.INV_ITEM_ID
				LEFT JOIN bluebin.DimLocation dl on PO_LN_DST.LOCATION = dl.LocationID
		 WHERE  PO_HDR.PO_DT >= (select ConfigValue from bluebin.Config where ConfigName = 'PO_DATE') 
                AND ISNULL(PO_LN.CANCEL_STATUS,'') NOT IN ( 'X', 'D' )

/*
       CASE
         WHEN ITEM_TYPE = 'S' THEN 0
         ELSE
           CASE
             WHEN REC_QTY = 0 THEN 0
             ELSE INVOICE_AMT - ( REC_QTY * ENT_UNIT_CST )
           END
       END                               AS PPV,



CASE WHEN ClosedFlag = 'Y' THEN 'Closed' ELSE
	CASE WHEN QtyReceived + QtyCancelled = QtyOrdered THEN 'Closed' ELSE 'Open' END
	END 																as POStatus,
CASE WHEN POItemType = 'S' THEN 'N/A' ELSE
	CASE WHEN Dateadd(day, 3, ExpectedDeliveryDate) <= GETDATE() AND (QtyReceived+QtyCancelled < QtyOrdered) THEN 'Late' ELSE
		CASE WHEN Dateadd(day, 3, ExpectedDeliveryDate) > GETDATE() THEN 'In-Progress' ELSE
			CASE WHEN ReceivedDate <= Dateadd(day, 3, ExpectedDeliveryDate) AND (QtyReceived + QtyCancelled) = QtyOrdered THEN 'On-Time' ELSE 'Late' END
		END	
	
	END



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

*/

GO

UPDATE etl.JobSteps
SET LastModifiedDate = GETDATE()
WHERE StepName = 'Sourcing'

GO
grant exec on tb_Sourcing to public
GO




