--*****************************************************
--**************************SPROC**********************

if exists (select * from dbo.sysobjects where id = object_id(N'sp_SelectQCNUser') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_SelectQCNUser
GO

--exec sp_SelectQCNUser

CREATE PROCEDURE sp_SelectQCNUser

--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON
    SELECT 
	
	DISTINCT 
	u.BlueBinUserID,
	u.LastName + ', ' + u.FirstName as AssignedUserName 
	
	FROM [qcn].[QCN] q 
	inner join [bluebin].[BlueBinUser] u on AssignedUserID = u.BlueBinUserID 
	
	order by 2


END
GO
grant exec on sp_SelectQCNUser to appusers
GO


