--*****************************************************
--**************************SPROC**********************
if exists (select * from dbo.sysobjects where id = object_id(N'sp_SelectGembaShadow') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_SelectGembaShadow
GO

--sp_SelectGembaShadow

CREATE PROCEDURE sp_SelectGembaShadow

--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON
	SELECT 
		BlueBinResourceID,
		LastName + ', ' + FirstName as FullName 
	
	FROM [bluebin].[BlueBinResource] 
	
	WHERE 
		Title in (Select ConfigValue from bluebin.Config where ConfigName = 'GembaShadowTitle')
		order by 2
END
GO
grant exec on sp_SelectGembaShadow to appusers
GO
