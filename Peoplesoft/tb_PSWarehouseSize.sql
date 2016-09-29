if exists (select * from dbo.sysobjects where id = object_id(N'tb_WarehouseSize') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure tb_WarehouseSize
GO

--exec tb_WarehouseSize

CREATE PROCEDURE tb_WarehouseSize

--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON

SELECT 
       a.FacilityName,
	   a.LocationID,
	   a.LocationName,
	   a.ItemID,
       a.ItemDescription,
       a.ItemClinicalDescription,
       a.ItemManufacturer,
       a.ItemManufacturerNumber,
       a.StockLocation,
       a.SOHQty,
       a.ReorderQty,
       a.ReorderPoint,
       a.UnitCost,
	   c.LastPODate,
	   a.StockUOM as UOM
       ,'' AS LYYTDIssueQty,
       '' AS CYYTDIssueQty
FROM   bluebin.DimWarehouseItem a
       --LEFT JOIN ICTRANS b
       --        ON ltrim(rtrim(a.ItemID)) = ltrim(rtrim(ITEM)) 
		LEFT JOIN bluebin.DimItem c
			   ON a.ItemKey = c.ItemKey
WHERE  SOHQty > 0 --b.DOC_TYPE = 'IS' and Year(b.TRANS_DATE) >= Year(Getdate()) - 1
GROUP  BY 
a.FacilityName,
a.LocationID,
			a.LocationName,
			a.ItemID,
          a.ItemDescription,
          a.ItemClinicalDescription,
          a.ItemManufacturer,
          a.ItemManufacturerNumber,
          a.StockLocation,
          a.SOHQty,
          a.ReorderQty,
          a.ReorderPoint,
          a.UnitCost,
		  c.LastPODate,
		  a.StockUOM 

END
GO
grant exec on tb_WarehouseSize to public
GO
