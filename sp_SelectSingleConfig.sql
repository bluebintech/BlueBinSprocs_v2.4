if exists (select * from dbo.sysobjects where id = object_id(N'sp_SelectSingleConfig') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_SelectSingleConfig
GO

--exec sp_SelectSingleConfig 'SiteAppURL'

CREATE PROCEDURE sp_SelectSingleConfig
@ConfigName varchar(30)

--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON
	SELECT 
	ConfigValue
	
	FROM bluebin.[Config]
	where ConfigName = @ConfigName and Active = 1

END
GO
grant exec on sp_SelectSingleConfig to appusers
GO

