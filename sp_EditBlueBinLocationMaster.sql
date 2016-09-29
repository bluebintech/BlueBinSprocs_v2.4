if exists (select * from dbo.sysobjects where id = object_id(N'sp_EditBlueBinLocationMaster') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_EditBlueBinLocationMaster
GO

--exec sp_EditBlueBinLocationMaster 'DN000','Testing'
CREATE PROCEDURE sp_EditBlueBinLocationMaster
@LocationKey int,
@LocationID varchar(10),
@LocationName varchar(255)

--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON

update [bluebin].[DimLocation]  
set LocationName=@LocationName
where LocationKey = @LocationKey

END
GO
grant exec on sp_EditBlueBinLocationMaster to appusers
GO

