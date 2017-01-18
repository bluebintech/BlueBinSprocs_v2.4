
--*****************************************************
--**************************SPROC**********************

if exists (select * from dbo.sysobjects where id = object_id(N'sp_InsertTimeStudyGroup') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_InsertTimeStudyGroup
GO

/*
exec sp_InsertTimeStudyGroup '6','BB001','Region 1','Region 1','gbutler@bluebin.com'
exec sp_InsertTimeStudyGroup '6','BB002','Region 2','Region 2','gbutler@bluebin.com'
exec sp_InsertTimeStudyGroup '6','BB003','Region 3','Region 3','gbutler@bluebin.com'
exec sp_InsertTimeStudyGroup '6','BB004','Region 4','Region 4','gbutler@bluebin.com'
exec sp_InsertTimeStudyGroup '6','BB005','Region 5','Region 5','gbutler@bluebin.com'
exec sp_InsertTimeStudyGroup '6','BB006','Region 6','Region 6','gbutler@bluebin.com'
*/

CREATE PROCEDURE sp_InsertTimeStudyGroup
@FacilityID int,
@LocationID varchar(10),
@GroupName varchar(50),
@Description varchar(255),
@BlueBinUser varchar(30)


--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON

if not exists (select * from bluebin.TimeStudyGroup where FacilityID = @FacilityID and LocationID = @LocationID and GroupName = @GroupName)
Begin
Insert into bluebin.TimeStudyGroup (
	[FacilityID],
	[LocationID],
	[GroupName],
	[Description],
	[Active],
	[LastUpdated] )
VALUES (
	@FacilityID,
	@LocationID,
	@GroupName,
	@Description,
	1,
	getdate()
)


Declare @TimeStudyID int, @message varchar(255)
SET @TimeStudyID = SCOPE_IDENTITY()
set @message = 'Added Location ' + @LocationID + ' to group ' + @GroupName
	exec sp_InsertMasterLog @BlueBinUser,'TimeStudy',@message,@TimeStudyID
END

END
GO
grant exec on sp_InsertTimeStudyGroup to appusers
GO



