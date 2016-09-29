if exists (select * from dbo.sysobjects where id = object_id(N'sp_EditBlueBinItemMaster') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_EditBlueBinItemMaster
GO

--exec sp_EditBlueBinItemMaster '0000001','Test','Test2'
CREATE PROCEDURE sp_EditBlueBinItemMaster
@ItemKey int,
@ItemID varchar(32),
@ItemDescription varchar(255),
@ItemClinicalDescription varchar(255),
@ItemManufacturer char(30),
@ItemManufacturerNumber char(35),
@ItemVendor char(30),
@ItemVendorNumber char(9),
@VendorItemNumber char(32),
@StockUOM char(4),
@ActiveStatus char(1),
@BuyUOM char(4),
@PackageString varchar(38),
@StockLocation char(7)


--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON

update [bluebin].[DimItem] 
set 
ItemDescription = @ItemDescription,
ItemClinicalDescription = @ItemClinicalDescription,
ItemManufacturer = @ItemManufacturer,
ItemManufacturerNumber = @ItemManufacturerNumber,
ItemVendor = @ItemVendor,
ItemVendorNumber = @ItemVendorNumber,
VendorItemNumber = @VendorItemNumber,
StockUOM = @StockUOM,
ActiveStatus = @ActiveStatus,
BuyUOM=@BuyUOM,
PackageString=@PackageString,
StockLocation=@StockLocation

where ItemKey = @ItemKey


END
GO
grant exec on sp_EditBlueBinItemMaster to appusers
GO
