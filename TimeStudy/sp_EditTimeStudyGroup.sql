
--*****************************************************
--**************************SPROC**********************

if exists (select * from dbo.sysobjects where id = object_id(N'sp_EditTimeStudyGroup') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_EditTimeStudyGroup
GO

--exec sp_EditTimeStudyGroup 
CREATE PROCEDURE sp_EditTimeStudyGroup
@TimeStudyGroupID int,
@GroupName varchar(50),
@Description varchar(255)

--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON

update [bluebin].[TimeStudyGroup] 
set 
GroupName = @GroupName,
[Description] = @Description

where TimeStudyGroupID = @TimeStudyGroupID


END
GO
grant exec on sp_EditTimeStudyGroup to appusers
GO
