--*****************************************************
--**************************SPROC**********************

if exists (select * from dbo.sysobjects where id = object_id(N'sp_SelectGembaAuditNodeUser') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_SelectGembaAuditNodeUser
GO

--exec sp_SelectGembaAuditNodeUser

CREATE PROCEDURE sp_SelectGembaAuditNodeUser

--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON
    SELECT 
	
	DISTINCT 
	AuditerUserID,
	u.LastName + ', ' + u.FirstName as Auditer 
	
	FROM [gemba].[GembaAuditNode]  
	inner join [bluebin].[BlueBinUser] u on AuditerUserID = u.BlueBinUserID 
	
	order by 2
END
GO
grant exec on sp_SelectGembaAuditNodeUser to appusers
GO


