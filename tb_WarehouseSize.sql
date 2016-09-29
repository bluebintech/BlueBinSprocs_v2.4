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
       ,Sum(CASE
             WHEN TRANS_DATE >= Dateadd(YEAR, Datediff(YEAR, 0, Dateadd(YEAR, -1, Getdate())), 0)
                  AND TRANS_DATE <= Dateadd(YEAR, -1, Getdate()) THEN b.QUANTITY * -1
             ELSE 0
           END) / Month(Getdate()) AS LYYTDIssueQty,
       Sum(CASE
             WHEN TRANS_DATE >= Dateadd(YEAR, Datediff(YEAR, 0, Getdate()), 0) THEN b.QUANTITY * -1
             ELSE 0
           END) / Month(Getdate()) AS CYYTDIssueQty
FROM   bluebin.DimWarehouseItem a
       LEFT JOIN ICTRANS b
               ON ltrim(rtrim(a.ItemID)) = ltrim(rtrim(ITEM)) 
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
