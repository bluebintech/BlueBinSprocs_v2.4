if exists (select * from dbo.sysobjects where id = object_id(N'sp_SelectBlueBinItemMaster') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_SelectBlueBinItemMaster
GO


--exec sp_SelectBlueBinItemMaster '',''
CREATE PROCEDURE sp_SelectBlueBinItemMaster
@ItemDescription varchar(255),
@Manufacturer varchar(255)

--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON
select
ItemKey,
[ItemID],
ItemDescription,
ItemClinicalDescription,
ActiveStatus,
ISNULL(ItemManufacturer,'') as Manufacturer,
ISNULL(ItemManufacturerNumber,'') as ManufacturerNo,
ISNULL(ItemVendor,'') as Vendor,
ISNULL(ItemVendorNumber,'') as VendorNo,
ISNULL(VendorItemNumber,'') as VendorItemID,
LastPODate,
StockUOM,
BuyUOM,
PackageString,
StockLocation
from  [bluebin].[DimItem]
WHERE 
--ItemID in (select ItemID from bluebin.DimBin) and 
	rtrim(ItemManufacturerNumber) +' - ' + rtrim(ItemManufacturer) like '%' + @Manufacturer + '%'
	AND
	rtrim(ItemID) +' - ' + rtrim(ItemDescription) like '%' + @ItemDescription + '%'
OR
	rtrim(ItemManufacturerNumber) +' - ' + rtrim(ItemManufacturer) like '%' + @Manufacturer + '%'
	AND
	rtrim(ItemID) +' - ' + rtrim(ItemClinicalDescription) like '%' + @ItemDescription + '%'
order by ItemID

END
GO
grant exec on sp_SelectBlueBinItemMaster to appusers
GO

