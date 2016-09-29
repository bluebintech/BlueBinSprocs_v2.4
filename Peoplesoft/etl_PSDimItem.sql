
--/******************************************

--			DimItem

--******************************************/

IF EXISTS ( SELECT  *
            FROM    sys.objects
            WHERE   object_id = OBJECT_ID(N'etl_DimItem')
                    AND type IN ( N'P', N'PC' ) ) 

DROP PROCEDURE  etl_DimItem
GO

--exec etl_DimItem
CREATE PROCEDURE etl_DimItem

AS

/**************		SET BUSINESS RULES		***************/




/**************		DROP DimItem			***************/

BEGIN Try
    DROP TABLE bluebin.DimItem
END Try

BEGIN Catch
END Catch



/*********************		CREATE DimItem		**************************************/
Declare @UseClinicalDescription int
select @UseClinicalDescription = ConfigValue from bluebin.Config where ConfigName = 'UseClinicalDescription'         
		
SELECT Row_number()
         OVER(
           ORDER BY a.INV_ITEM_ID) AS ItemKey,
       a.INV_ITEM_ID               AS ItemID,
       DESCR                       AS ItemDescription,
	   ''							AS ItemDescription2,--****
	   DESCR                       AS ItemClinicalDescription,--****
	   'A'							AS ActiveStatus,--****
       b.MFG_ID                    AS ItemManufacturer,
       b.MFG_ITM_ID                AS ItemManufacturerNumber,
       d.NAME1                     AS ItemVendor,
       c.ITM_ID_VNDR               AS ItemVendorNumber,
	   
	   ''							AS LastPODate,--****
       ''							AS StockLocation,--****
       ''							AS VendorItemNumber,--****
	   UNIT_MEASURE_STD			   AS StockUOM,
       UNIT_MEASURE_STD            AS BuyUOM,
       ''							AS PackageString--****
INTO   bluebin.DimItem
FROM   dbo.MASTER_ITEM_TBL a
       LEFT JOIN dbo.ITEM_MFG b
              ON a.INV_ITEM_ID COLLATE DATABASE_DEFAULT = b.INV_ITEM_ID
                 AND b.PREFERRED_MFG = 'Y'
       LEFT JOIN dbo.ITM_VENDOR c
              ON a.INV_ITEM_ID COLLATE DATABASE_DEFAULT = c.INV_ITEM_ID
                 AND c.ITM_VNDR_PRIORITY = 1
       LEFT JOIN dbo.VENDOR d
              ON c.VENDOR_ID COLLATE DATABASE_DEFAULT = d.VENDOR_ID 
GO
--exec etl_DimItem


UPDATE etl.JobSteps
SET LastModifiedDate = GETDATE()
WHERE StepName = 'DimItem'
GO


