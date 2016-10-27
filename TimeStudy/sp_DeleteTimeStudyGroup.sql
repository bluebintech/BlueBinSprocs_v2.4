
--*****************************************************
--**************************SPROC**********************

if exists (select * from dbo.sysobjects where id = object_id(N'sp_DeleteTimeStudyGroup') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_DeleteTimeStudyGroup
GO

--exec sp_DeleteTimeStudyGroup 'TEST'

CREATE PROCEDURE sp_DeleteTimeStudyGroup
@TimeStudyGroupID int



--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON
	
Delete from bluebin.[TimeStudyGroup] 
WHERE [TimeStudyGroupID] = @TimeStudyGroupID 
				

END
GO
grant exec on sp_DeleteTimeStudyGroup to appusers
GO
