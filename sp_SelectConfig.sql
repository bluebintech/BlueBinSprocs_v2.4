if exists (select * from dbo.sysobjects where id = object_id(N'sp_SelectConfig') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_SelectConfig
GO

--exec sp_SelectConfig 'Tableau'

CREATE PROCEDURE sp_SelectConfig
@ConfigType varchar(50)

--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON
	SELECT 
	ConfigID,
	ConfigType,
	ConfigName,
	ConfigValue,
	case 
		when Active = 1 then 'Yes' 
		Else 'No' 
		end as ActiveName,
	Active,
	LastUpdated,
	[Description]
	
	FROM bluebin.[Config]
	where ConfigType like  '%' + @ConfigType + '%'
	order by ConfigType,ConfigName

END
GO
grant exec on sp_SelectConfig to appusers
GO
