if exists (select * from dbo.sysobjects where id = object_id(N'sp_SelectConfigValues') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_SelectConfigValues
GO

--exec sp_SelectConfigValues 'TableauSiteName'  exec sp_SelectConfigValues 'TableauDefaultUser'

CREATE PROCEDURE sp_SelectConfigValues
	@ConfigName NVARCHAR(50)

--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON
	SELECT 
	ConfigValue
	FROM bluebin.[Config] 
	where ConfigName = @ConfigName

END
GO
grant exec on sp_SelectConfigValues to appusers
GO
