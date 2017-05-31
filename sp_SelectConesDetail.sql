--*****************************************************
--**************************SPROC**********************

if exists (select * from dbo.sysobjects where id = object_id(N'sp_SelectConesDetail') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_SelectConesDetail
GO

--exec sp_SelectConesDetail '',''

CREATE PROCEDURE sp_SelectConesDetail
@ConesDeployedID int

--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON
	SELECT 
	cd.ConesDeployedID,
	cd.Details as DetailsText
	
	
	FROM bluebin.[ConesDeployed] cd
	where ConesDeployedID = @ConesDeployedID
	
END
GO
grant exec on sp_SelectConesDetail to appusers
GO
