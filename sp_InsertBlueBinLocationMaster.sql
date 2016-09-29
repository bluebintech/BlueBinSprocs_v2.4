if exists (select * from dbo.sysobjects where id = object_id(N'sp_InsertBlueBinLocationMaster') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_InsertBlueBinLocationMaster
GO

--exec sp_InsertBlueBinLocationMaster 'BB'
CREATE PROCEDURE sp_InsertBlueBinLocationMaster
@LocationID varchar(10),
@LocationName varchar(255)


--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON
if not exists (select * from bluebin.DimLocation where rtrim(LocationID) = rtrim(@LocationID))
BEGIN
insert [bluebin].[DimLocation] (LocationKey,LocationID,LocationName,LocationFacility,BlueBinFlag)
VALUES ((select max(LocationKey)+1 from bluebin.DimLocation),@LocationID,@LocationName,1,1)
END

END
GO
grant exec on sp_InsertBlueBinLocationMaster to appusers
GO


