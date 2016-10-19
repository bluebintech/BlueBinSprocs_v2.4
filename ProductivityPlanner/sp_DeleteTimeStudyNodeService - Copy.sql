
--*****************************************************
--**************************SPROC**********************

if exists (select * from dbo.sysobjects where id = object_id(N'sp_DeleteTimeStudyNodeService') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_DeleteTimeStudyNodeService
GO

--exec sp_DeleteTimeStudyNodeService 'TEST'

CREATE PROCEDURE sp_DeleteTimeStudyNodeService
@TimeStudyNodeServiceID int



--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON
	
UPDATE bluebin.[TimeStudyNodeService] 
set Active = 0, MostRecent = 0
WHERE [TimeStudyNodeServiceID] = @TimeStudyNodeServiceID 
				

END
GO
grant exec on sp_DeleteTimeStudyNodeService to appusers
GO
