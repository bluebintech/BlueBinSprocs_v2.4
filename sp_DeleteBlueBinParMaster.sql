if exists (select * from dbo.sysobjects where id = object_id(N'sp_DeleteBlueBinParMaster') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_DeleteBlueBinParMaster
GO

--exec sp_DeleteBlueBinParMaster '','',''
CREATE PROCEDURE sp_DeleteBlueBinParMaster
@ParMasterID int
--@FacilityID int
--,@LocationID varchar(10)
--,@ItemID varchar(32)

--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON
delete from [bluebin].[BlueBinParMaster] 
WHERE ParMasterID = @ParMasterID 
--WHERE rtrim(LocationID) = rtrim(@LocationID)
--	and rtrim(ItemID) = rtrim(@ItemID)
--		and FacilityID = @FacilityID 


END
GO
grant exec on sp_DeleteBlueBinParMaster to appusers
GO