if exists (select * from dbo.sysobjects where id = object_id(N'sp_EditConesDeployed') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_EditConesDeployed
GO

--exec sp_EditConesDeployed 


CREATE PROCEDURE sp_EditConesDeployed
@ConesDeployedID int



--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON
	Update bluebin.ConesDeployed set 
	ConeReturned = 1,
	Returned = getdate(),
	LastUpdated = getdate() 
	where ConesDeployedID = @ConesDeployedID

END
GO
grant exec on sp_EditConesDeployed to appusers
GO
