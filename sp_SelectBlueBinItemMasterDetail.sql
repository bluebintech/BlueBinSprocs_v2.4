if exists (select * from dbo.sysobjects where id = object_id(N'sp_SelectBlueBinItemMasterDetail') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_SelectBlueBinItemMasterDetail
GO

--exec sp_SelectBlueBinItemMaster '2601'
CREATE PROCEDURE sp_SelectBlueBinItemMasterDetail
@ItemKey int

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
ISNULL(ItemManufacturer,'') as ItemManufacturer,
ISNULL(ItemManufacturerNumber,'') as ItemManufacturerNumber,
ISNULL(ItemVendor,'') as ItemVendor,
ISNULL(ItemVendorNumber,'') as ItemVendorNumber,
ISNULL(VendorItemNumber,'') as VendorItemNumber,
LastPODate,
StockUOM,
BuyUOM,
PackageString,
StockLocation
from  [bluebin].[DimItem] 

WHERE ([ItemKey] = @ItemKey)


END
GO
grant exec on sp_SelectBlueBinItemMasterDetail to appusers
GO

