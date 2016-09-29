if exists (select * from dbo.sysobjects where id = object_id(N'sp_DeleteConesDeployed') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_DeleteConesDeployed
GO

--exec sp_EditConesDeployed'TEST'

CREATE PROCEDURE sp_DeleteConesDeployed
@ConesDeployedID int


--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON
	Update bluebin.[ConesDeployed] 
	set Deleted = 1, LastUpdated = getdate()
	WHERE [ConesDeployedID] = @ConesDeployedID 

				

END
GO
grant exec on sp_DeleteConesDeployed to appusers
GO
