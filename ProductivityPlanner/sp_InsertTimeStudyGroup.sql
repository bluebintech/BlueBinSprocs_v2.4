
--*****************************************************
--**************************SPROC**********************

if exists (select * from dbo.sysobjects where id = object_id(N'sp_InsertTimeStudyGroup') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_InsertTimeStudyGroup
GO

/*
exec sp_InsertTimeStudyGroup '6','BB001','Region 1','Region 1'
exec sp_InsertTimeStudyGroup '6','BB002','Region 2','Region 2'
exec sp_InsertTimeStudyGroup '6','BB003','Region 3','Region 3'
exec sp_InsertTimeStudyGroup '6','BB004','Region 4','Region 4'
exec sp_InsertTimeStudyGroup '6','BB005','Region 5','Region 5'
*/

CREATE PROCEDURE sp_InsertTimeStudyGroup
@FacilityID int,
@LocationID varchar(10),
@GroupName varchar(50),
@Description varchar(255)


--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON

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

END
GO
grant exec on sp_InsertTimeStudyGroup to appusers
GO



