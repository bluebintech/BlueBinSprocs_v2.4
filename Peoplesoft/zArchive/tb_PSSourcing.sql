
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
select top 100* from PURCH_ITEM_ATTR
select top 100* from PURCH_ITEM_BU
select top 1000* from MANUFACTURER order by 3
select * from insert select * into Stanford_LPCH.tableau.Sourcing from OSUMC.tableau.Sourcing
select top 1000* from OSUMC.tableau.Sourcing
select * from tableau.Sourcing where PONumber = '0000404739'
select * from etl.JobSteps
update etl.JobSteps set ActiveFlag = 1 where StepName in ('Sourcing')

*/
-- #tmpPOLines
declare @Facility int
   select @Facility = ConfigValue from bluebin.Config where ConfigName = 'PS_DefaultFacility'
declare @POTimeAdjust int = (Select max(ConfigValue) from bluebin.Config where ConfigName = 'PS_POTimeAdjust')
  
;
With A as (
SELECT Row_number()
                  OVER(
                    ORDER BY PO_LN.PO_ID, PO_LN.LINE_NBR) AS POKey,
                @Facility as Company,
				PO_LN.PO_ID as PONumber,
				--PO_LN.PO_ID as PONumber,
				PO_LN.LINE_NBR AS POLineNumber,
				0 as PORelease,							--NEED
				PO_LN.PO_ID AS POCode,
                PO_LN.INV_ITEM_ID  AS ItemNumber,
                PO_HDR.VENDOR_ID as VendorCode,
				ISNULL(v.VENDOR_NAME_SHORT,'N/A') as VendorName,					
				PO_HDR.BUYER_ID as Buyer,
				PO_HDR.BUYER_ID as BuyerName,			
				PO_LN_DST.BUSINESS_UNIT as ShipLocation,					
				PO_LN_DST.ACCOUNT as AcctUnit,			
				gl.DESCR as AcctUnitName,						
				PO_LN.DESCR254_MIXED as PODesc, -- Original   MIT.DESCR as PODescr,
				PO_LN_DST.QTY_PO as QtyOrdered,
				case
					when ISNULL(PO_LN.CANCEL_STATUS,'') IN ( 'X', 'D', 'PX') OR SHIP.RECEIPT_DTTM is NULL then 0 else PO_LN_DST.QTY_PO end as QtyReceived, --May need to add , 'C', 'PX'		
				PO_LN.CNTRCT_ID as AgrmtRef,
				case when PO_LN_DST.QTY_PO = 0 then 0 else PO_LN_DST.MERCHANDISE_AMT/PO_LN_DST.QTY_PO end as UnitCost,							
				PO_LN.UNIT_OF_MEASURE as BuyUOM,
				1 as BuyUOMMult,						--NEED
				case when PO_LN_DST.QTY_PO = 0 then 0 else PO_LN_DST.MERCHANDISE_AMT/PO_LN_DST.QTY_PO end as IndividualCost,					
				DATEADD(hour,@POTimeAdjust,PO_HDR.PO_DT) as PODate,
				--PO_HDR.PO_DT as PODate,
				(DATEADD(day,((@POTimeAdjust/24)+convert(int,(Select max(ConfigValue) from bluebin.Config where ConfigName = 'DefaultLeadTime') )),PO_HDR.PO_DT)) as ExpectedDeliveryDate,				--NEED
				'' as LateDeliveryDate,					
				SHIP.RECEIPT_DTTM as ReceivedDate,
				SHIP.RECEIPT_DTTM as CloseDate,			
				PO_LN_DST.LOCATION AS PurchaseLocation,
                @Facility as PurchaseFacility,
				'' as ClosedFlag,						--NEED
				case
					when ISNULL(PO_LN.CANCEL_STATUS,'') IN ( 'X', 'D' , 'PX') then PO_LN_DST.QTY_PO else 0 end as QtyCancelled,	--May need to add , 'C', 'PX'					
				PO_LN_DST.MERCHANDISE_AMT as POAmt,							
				PO_LN_DST.MERCHANDISE_AMT as InvoiceAmt,						
				Case 
					When PO_LN.QTY_TYPE = 'S' and PO_LN.PRICE_DT_TYPE = 'D' then 'X'
					When PO_LN.QTY_TYPE = 'L' and PO_LN.PRICE_DT_TYPE = 'P' then 'N'  
					else 'I' end as POItemType,						--NEED
				0 as PPV,								
				1 as POLine		
  
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
				--LEFT JOIN MASTER_ITEM_TBL MIT on PO_LN.INV_ITEM_ID = MIT.INV_ITEM_ID
				LEFT JOIN 
					(select g.ACCOUNT,g.ACCOUNT_TYPE,g.DESCR from GL_ACCOUNT_TBL g
					inner join (select ACCOUNT,max(EFFDT) as EFFDT from GL_ACCOUNT_TBL where EFF_STATUS = 'A' group by ACCOUNT) a on g.ACCOUNT = a.ACCOUNT and g.EFFDT = a.EFFDT
					) gl ON PO_LN_DST.ACCOUNT = gl.ACCOUNT 
				LEFT JOIN VENDOR v on PO_HDR.VENDOR_ID = v.VENDOR_ID
				LEFT JOIN bluebin.DimLocation dl on PO_LN_DST.LOCATION = dl.LocationID
				--LEFT JOIN (select INV_ITEM_ID,max(LAST_PO_PRICE_PAID) as Price from PURCH_ITEM_ATTR group by INV_ITEM_ID) pia on PO_LN.INV_ITEM_ID = pia.INV_ITEM_ID
				
				--select * from GL_ACCOUNT_TBL where ACCOUNT = '732900'
				

		 WHERE  PO_HDR.PO_DT >= (select ConfigValue from bluebin.Config where ConfigName = 'PO_DATE') 
                AND ISNULL(PO_LN.CANCEL_STATUS,'') NOT IN ( 'X', 'D' )

)
,
B as (
SELECT A.*,
CASE WHEN ClosedFlag = 'Y' THEN 'Closed' ELSE
	CASE WHEN QtyReceived + QtyCancelled >= QtyOrdered THEN 'Closed' ELSE 'Open' END
	END 																as POStatus,
CASE WHEN POItemType = 'S' THEN 'N/A' ELSE
	CASE WHEN Dateadd(day, 3, ExpectedDeliveryDate) <= GETDATE() AND (QtyReceived+QtyCancelled < QtyOrdered) THEN 'Late' ELSE
		CASE WHEN Dateadd(day, 3, ExpectedDeliveryDate) > GETDATE() THEN 'In-Progress' ELSE
			CASE WHEN ReceivedDate <= Dateadd(day, 3, ExpectedDeliveryDate) AND (QtyReceived + QtyCancelled) >= QtyOrdered THEN 'On-Time' ELSE 'Late' END
		END	
	
	END

END as PODeliveryStatus

FROM A)

SELECT B.*,
       CASE
         WHEN B.PODeliveryStatus = 'In-Progress' THEN 1
         ELSE 0
       END AS InProgress,
       CASE
         WHEN B.PODeliveryStatus = 'On-Time' THEN 1
         ELSE 0
       END AS OnTime,
       CASE
         WHEN B.PODeliveryStatus = 'Late' THEN 1
         ELSE 0
       END AS Late,
	   case when dl.BlueBinFlag = 1 then 'Yes' else 'No' end as BlueBinFlag,
	   df.FacilityName,
	   dl.LocationName,
	   iv.ITM_ID_VNDR as VendorItemNbr

INTO   tableau.Sourcing 
FROM   B
LEFT JOIN bluebin.DimLocation dl on ltrim(rtrim(B.PurchaseLocation)) = ltrim(rtrim(dl.LocationID)) and ltrim(rtrim(B.PurchaseFacility)) = ltrim(rtrim(dl.LocationFacility))
LEFT JOIN bluebin.DimFacility df on ltrim(rtrim(B.PurchaseFacility)) = ltrim(rtrim(df.FacilityID))
LEFT JOIN (select VENDOR_ID,ITM_ID_VNDR,INV_ITEM_ID from ITM_VENDOR where ITM_STATUS = 'A') iv on B.ItemNumber = iv.INV_ITEM_ID and B.VendorCode = iv.VENDOR_ID
--where ItemNumber= '0761925'
--where dl.BlueBinFlag = 1

GO

UPDATE etl.JobSteps
SET LastModifiedDate = GETDATE()
WHERE StepName = 'Sourcing'

GO
grant exec on tb_Sourcing to public
GO




