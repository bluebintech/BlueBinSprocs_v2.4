if exists (select * from dbo.sysobjects where id = object_id(N'sp_DeleteBlueBinLocationMaster') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_DeleteBlueBinLocationMaster 

GO

--exec sp_DeleteBlueBinLocationMaster 'DN000  '
CREATE PROCEDURE sp_DeleteBlueBinLocationMaster
@LocationKey int

--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON
delete from [bluebin].[DimLocation]  
where LocationKey = @LocationKey

if exists (select * from bluebin.BlueBinParMaster where LocationID = (select LocationID from [bluebin].[DimLocation] where LocationKey = @LocationKey))
BEGIN
delete from [bluebin].[BlueBinParMaster]
where LocationID = (select LocationID from [bluebin].[DimLocation] where LocationKey = @LocationKey)
END
END
GO
grant exec on sp_DeleteBlueBinLocationMaster to appusers
GO