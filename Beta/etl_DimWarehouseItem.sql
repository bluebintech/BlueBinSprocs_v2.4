
/********************************************************************

					DimWarehouseItem

********************************************************************/
--Updated GB 20170423 Added logic on the costing to match with DimBin (AVG cost)

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

select ITEM,
sum(ENT_UNIT_CST)/max(ItemOrderSeq) as ENT_UNIT_CST 
into #ItemOrders2
from 
(
SELECT Row_number()
         OVER(
           Partition BY ITEM--, ENT_BUY_UOM
           ORDER BY PO_NUMBER DESC) AS ItemOrderSeq,
       ITEM,
	   ENT_UNIT_CST/EBUY_UOM_MULT as ENT_UNIT_CST
FROM   POLINE
WHERE  ITEM_TYPE IN ( 'I', 'N' ) and LOCATION in (Select ConfigValue from bluebin.Config where ConfigName = 'LOCATION')
--and ITEM = '00107'
) a
group by a.ITEM


SELECT 
		--d.LocationID,
		a.COMPANY,
		df.FacilityName,
		a.LOCATION as LocationID,
		a.LOCATION as LocationName,
		b.ItemKey,
       b.ItemID,
       b.ItemDescription,
       b.ItemClinicalDescription,
       b.ItemManufacturer,
       b.ItemManufacturerNumber,
       b.ItemVendor,
       b.ItemVendorNumber,
       a.PREFER_BIN    AS StockLocation,
       a.SOH_QTY       AS SOHQty,
       a.MAX_ORDER     AS ReorderQty,
       a.REORDER_POINT AS ReorderPoint,
	   COALESCE((case when a.LAST_ISS_COST = 0 then NULL else a.LAST_ISS_COST end),#ItemOrders2.ENT_UNIT_CST,0)	AS UnitCost,
       b.StockUOM,
       b.BuyUOM,
       b.PackageString
INTO   bluebin.DimWarehouseItem
FROM   ITEMLOC a
       INNER JOIN bluebin.DimItem b
               ON a.ITEM = b.ItemID
		INNER JOIN bluebin.DimFacility df on a.COMPANY = df.FacilityID
		LEFT JOIN #ItemOrders2 on a.ITEM = #ItemOrders2.ITEM
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

WHERE a.LOCATION in (Select ConfigValue from bluebin.Config where ConfigName = 'LOCATION')
order by 1,3,5
drop table #ItemOrders2


--select * from bluebin.DimWarehouseItem order by 1,3,5

GO

UPDATE etl.JobSteps
SET LastModifiedDate = GETDATE()
WHERE StepName = 'Warehouse Item'

GO

