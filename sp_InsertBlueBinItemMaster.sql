if exists (select * from dbo.sysobjects where id = object_id(N'sp_InsertBlueBinItemMaster') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_InsertBlueBinItemMaster
GO

--exec sp_InsertBlueBinItemMaster '2601'
CREATE PROCEDURE sp_InsertBlueBinItemMaster
@ItemID varchar(32),
@ItemDescription varchar(255),
@ItemClinicalDescription varchar(255),
@ItemManufacturer char(30),
@ItemManufacturerNumber char(35),
@ItemVendor char(30),
@ItemVendorNumber char(9),
@VendorItemNumber char(32),
@StockUOM char(4)




--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON

if not exists(select * from bluebin.DimItem where ItemID = @ItemID)
BEGIN
set @ItemManufacturerNumber = isnull(@ItemManufacturerNumber,'None')

insert into [bluebin].[DimItem] (ItemKey,ActiveStatus,[ItemID],ItemDescription,ItemDescription2,ItemClinicalDescription,ItemManufacturer,ItemManufacturerNumber,ItemVendor,ItemVendorNumber,VendorItemNumber,StockUOM)

VALUES ((Select max(ItemKey) + 1 from bluebin.DimItem),'A',rtrim(@ItemID),@ItemDescription,@ItemClinicalDescription,@ItemClinicalDescription,@ItemManufacturer,@ItemManufacturerNumber,@ItemVendor,@ItemVendorNumber,@VendorItemNumber,@StockUOM)
END

END
GO
grant exec on sp_InsertBlueBinItemMaster to appusers
GO
