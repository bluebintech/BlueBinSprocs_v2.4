/************************************************************

			DimWarehouseItem

************************************************************/

IF EXISTS ( SELECT  *
            FROM    sys.objects
            WHERE   object_id = OBJECT_ID(N'etl_DimWarehouseItem')
                    AND type IN ( N'P', N'PC' ) ) 

DROP PROCEDURE  etl_DimWarehouseItem
GO

CREATE PROCEDURE	etl_DimWarehouseItem

AS
--exec etl_DimWarehouseItem
/********************************		DROP DimWarehouseItem		**********************************/

BEGIN TRY
    DROP TABLE bluebin.DimWarehouseItem
END TRY

BEGIN CATCH
END CATCH

declare @Facility int, @UsePriceList int
   select @Facility = ConfigValue from bluebin.Config where ConfigName = 'PS_DefaultFacility'
   select @UsePriceList = ConfigValue from bluebin.Config where ConfigName = 'PS_UsePriceList'
   

SELECT 
		--d.LocationID,
		case when @Facility is not null or @Facility <> '' then @Facility else ''end as FacilityID,
		case when @Facility is not null or @Facility <> '' then (select FacilityName from bluebin.DimFacility where FacilityID = @Facility) else ''end as FacilityName,
		a.BUSINESS_UNIT as LocationID,
		a.BUSINESS_UNIT as LocationName,
		b.ItemKey,
       b.ItemID,
       b.ItemDescription,
       b.ItemClinicalDescription,
       b.ItemManufacturer,
       b.ItemManufacturerNumber,
       b.ItemVendor,
       b.ItemVendorNumber,
       ''    AS StockLocation,
       a.[QTY_ONHAND]       AS SOHQty,
       a.[QTY_MAXIMUM]     AS ReorderQty,
       a.[REORDER_POINT] AS ReorderPoint,
	   a.[LAST_PRICE_PAID] as UnitCost,
	   --CASE 		--Use if PriceList should be part of the Warehouse report as well  Uncomment left join to PURCHITEM_ATTR if activating
		--WHEN @UsePriceList = 1 then p.PRICE_LIST
		--else a.[LAST_PRICE_PAID]	
		--End AS UnitCost,
       b.StockUOM,
       b.BuyUOM,
       b.PackageString
INTO   bluebin.DimWarehouseItem
FROM   [dbo].[BU_ITEMS_INV] a
       INNER JOIN bluebin.DimItem b
               ON a.[INV_ITEM_ID] = b.ItemID
		--LEFT JOIN [dbo].PURCH_ITEM_ATTR p on a.INV_ITEM_ID = p.INV_ITEM_ID
		
       --INNER JOIN ICCATEGORY c
       --        ON a.COMPANY = c.COMPANY
       --           AND a.LOCATION = c.LOCATION
       --           AND a.GL_CATEGORY = c.GL_CATEGORY
		--INNER JOIN 
		--bluebin.DimLocation d
		--ON a.LOCATION = d.LocationID
		--INNER JOIN ICLOCATION e
		--ON a.COMPANY = e.COMPANY
		--AND a.LOCATION = e.LOCATION

--WHERE a.BUSINESS_UNIT in (Select ConfigValue from bluebin.Config where ConfigName = 'LOCATION')
WHERE a.BUSINESS_UNIT in (Select ConfigValue from bluebin.Config where ConfigName = 'PS_BUSINESSUNIT')

GO

UPDATE etl.JobSteps
SET LastModifiedDate = GETDATE()
WHERE StepName = 'Warehouse Item'

GO

