if exists (select * from dbo.sysobjects where id = object_id(N'sp_DeleteBlueBinItemMaster') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_DeleteBlueBinItemMaster
GO

--exec sp_DeleteBlueBinItemMaster '2601'
CREATE PROCEDURE sp_DeleteBlueBinItemMaster
@ItemKey int

--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON
delete from [bluebin].[DimItem] 

where ItemKey = @ItemKey


END
GO
grant exec on sp_DeleteBlueBinItemMaster to appusers
GO
