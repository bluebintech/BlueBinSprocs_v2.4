
--/******************************************

--			DimItem

--******************************************/
--Updated GB 20180219 Added Expireable

IF EXISTS ( SELECT  *
            FROM    sys.objects
            WHERE   object_id = OBJECT_ID(N'etl_DimItem')
                    AND type IN ( N'P', N'PC' ) ) 

DROP PROCEDURE  etl_DimItem
GO

--exec etl_DimItem  select count(*) from bluebin.DimItem select * from bluebin.DimItem
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
	   --DESCR                       AS ItemClinicalDescription,--****
	   case when @UseClinicalDescription = 1 then
			case 
				when bn.INV_BRAND_NAME is null or bn.INV_BRAND_NAME = ''  then
						case 
							when DESCR is null or DESCR = '' then '*NEEDS*' 
							else DESCR end 
			else bn.INV_BRAND_NAME end 
		else DESCR end as ItemClinicalDescription,
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
       ''							AS PackageString,--****
	   ISNULL(ex.Expireable,'') as Expireable
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
	   left join BRAND_NAMES_INV bn on a.INV_ITEM_ID = bn.INV_ITEM_ID
	   left join (select INV_ITEM_ID,ITEM_FIELD_C2 as Expireable from BU_ITEMS_INV where ITEM_FIELD_C2 = 'Y' group by INV_ITEM_ID,ITEM_FIELD_C2) ex on a.INV_ITEM_ID = ex.INV_ITEM_ID

--select count(*) select * from bluebin.DimItem where ItemID = '1000250'
GO
--exec etl_DimItem


UPDATE etl.JobSteps
SET LastModifiedDate = GETDATE()
WHERE StepName = 'DimItem'
GO


