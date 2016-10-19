
--*****************************************************
--**************************SPROC**********************

if exists (select * from dbo.sysobjects where id = object_id(N'sp_DeleteTimeStudyProcess') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_DeleteTimeStudyProcess
GO

--exec sp_DeleteTimeStudyProcess 'TEST'

CREATE PROCEDURE sp_DeleteTimeStudyProcess
@TimeStudyProcessID int



--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON
	
UPDATE bluebin.[TimeStudyProcess] 
set Active = 0, LastUpdated = getdate()
WHERE [TimeStudyProcessID] = @TimeStudyProcessID 
				

END
GO
grant exec on sp_DeleteTimeStudyProcess to appusers
GO
