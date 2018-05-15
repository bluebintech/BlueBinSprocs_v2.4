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

declare @UsePriceList int
declare @Facility int = (select ConfigValue from bluebin.Config where ConfigName = 'PS_DefaultFacility')
declare @FacilityName varchar(30) = (select PSFacilityName from bluebin.DimFacility where FacilityID = @Facility)
   select @UsePriceList = ConfigValue from bluebin.Config where ConfigName = 'PS_UsePriceList'
   

SELECT distinct
		--d.LocationID,
		--case when @Facility is not null or @Facility <> '' then @Facility else ''end as FacilityID,
		--case when @Facility is not null or @Facility <> '' then (select FacilityName from bluebin.DimFacility where FacilityID = @Facility) else ''end as FacilityName,
		COALESCE(df.FacilityID,@Facility) AS COMPANY,
		COALESCE(df.FacilityName,@FacilityName) AS FacilityName,
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
	   --a.[LAST_PRICE_PAID] as UnitCost,
	   CASE
			When @UsePriceList = 1 then
			COALESCE(a2.PRICE_LIST,a2.LAST_PRICE_PAID,a2.LAST_PO_PRICE_PAID,0)
			Else
			COALESCE(a2.LAST_PRICE_PAID,a2.LAST_PO_PRICE_PAID,a2.PRICE_LIST,0) 
			end AS UnitCost,
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
		LEFT JOIN		
		(select
			m.INV_ITEM_ID
			,case when bu.LAST_PRICE_PAID = 0 then NULL else bu.LAST_PRICE_PAID end as LAST_PRICE_PAID
			,case when p.LAST_PO_PRICE_PAID = 0 then NULL else p.LAST_PO_PRICE_PAID end as LAST_PO_PRICE_PAID
			,case when p.PRICE_LIST = 0 then NULL else p.PRICE_LIST end as PRICE_LIST
			,bu.CONSIGNED_FLAG as CONSIGNED_FLAG_BU
			,m.CONSIGNED_FLAG as CONSIGNED_FLAG_M

			from (select INV_ITEM_ID,max(CONSIGNED_FLAG) as CONSIGNED_FLAG from MASTER_ITEM_TBL group by INV_ITEM_ID) m 
			LEFT JOIN PURCH_ITEM_ATTR p on m.INV_ITEM_ID = p.INV_ITEM_ID
			--LEFT JOIN BU_ITEMS_INV bu on m.INV_ITEM_ID = bu.INV_ITEM_ID and bu.BUSINESS_UNIT in (select ConfigValue from bluebin.Config where ConfigName = 'PS_BUSINESSUNIT')
			LEFT JOIN
				(select a.BUSINESS_UNIT,a.CONSIGNED_FLAG,a.INV_ITEM_ID,max(a.LAST_PRICE_PAID) as LAST_PRICE_PAID
					from BU_ITEMS_INV a
					inner join (select BUSINESS_UNIT,INV_ITEM_ID,max(LAST_ORDER_DATE) as LAST_ORDER_DATE from BU_ITEMS_INV group by BUSINESS_UNIT,INV_ITEM_ID) b 
							on a.BUSINESS_UNIT = b.BUSINESS_UNIT and a.INV_ITEM_ID = b.INV_ITEM_ID and a.LAST_ORDER_DATE = b.LAST_ORDER_DATE
					group by a.BUSINESS_UNIT,a.CONSIGNED_FLAG,a.INV_ITEM_ID) bu on m.INV_ITEM_ID = bu.INV_ITEM_ID and bu.BUSINESS_UNIT in (select ConfigValue from bluebin.Config where ConfigName = 'PS_BUSINESSUNIT')

			) a2 on a.INV_ITEM_ID = a2.INV_ITEM_ID
		left join bluebin.DimFacility df on a.BUSINESS_UNIT = df.FacilityName
--WHERE a.BUSINESS_UNIT in (Select ConfigValue from bluebin.Config where ConfigName = 'LOCATION')
WHERE a.BUSINESS_UNIT in (Select ConfigValue from bluebin.Config where ConfigName = 'PS_BUSINESSUNIT')
--and b.ItemID like '%10553%'

group by
		df.FacilityID,
		df.FacilityName,
		a.BUSINESS_UNIT,
		a.BUSINESS_UNIT,
		b.ItemKey,
       b.ItemID,
       b.ItemDescription,
       b.ItemClinicalDescription,
       b.ItemManufacturer,
       b.ItemManufacturerNumber,
       b.ItemVendor,
       b.ItemVendorNumber,
       a.[QTY_ONHAND],
       a.[QTY_MAXIMUM],
       a.[REORDER_POINT],
		a2.LAST_PRICE_PAID,
		a2.LAST_PO_PRICE_PAID,
		a2.PRICE_LIST,
       b.StockUOM,
       b.BuyUOM,
       b.PackageString
	   order by 6,2,3

--select count(*) from bluebin.DimWarehouseItem
GO

UPDATE etl.JobSteps
SET LastModifiedDate = GETDATE()
WHERE StepName = 'Warehouse Item'

GO

