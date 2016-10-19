
--*****************************************************
--**************************SPROC**********************

if exists (select * from dbo.sysobjects where id = object_id(N'sp_InsertTimeStudyNodeService') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_InsertTimeStudyNodeService
GO

--

/*
exec sp_InsertTimeStudyNodeService '6','BB001','','5','08:51','08:57','19','Test Comments',1,1
exec sp_InsertTimeStudyNodeService '6','BB001','','6','09:03','09:18','19','Test Comments',1,1
exec sp_InsertTimeStudyNodeService '6','BB001','','7','09:16','09:23','19','Test Comments',1,1
exec sp_InsertTimeStudyNodeService '6','BB001','BB002','8','09:28','09:29','19','Test Comments',1,1


exec sp_InsertTimeStudyNodeService '6','BB002','','6','09:30','09:36','19','Test Comments',1,1
exec sp_InsertTimeStudyNodeService '6','BB002','','7','09:37','09:38','19','Test Comments',1,1
exec sp_InsertTimeStudyNodeService '6','BB002','BB003','8','09:40','09:42','19','Test Comments',1,1


select * from bluebin.TimeStudyNodeService
select * from bluebin.TimeStudyProcess
select * from bluebin.TimeStudyGroup
*/ 

CREATE PROCEDURE sp_InsertTimeStudyNodeService
	@FacilityID int,
	@LocationID varchar(10),
	@TravelLocationID varchar(10),	
	@TimeStudyProcessID int,
	@StartTime varchar(5),
	@StopTime varchar(5),
	@SKUS int,
	@Comments varchar(max),
	@BlueBinUser varchar(30),
	@BlueBinResourceID int


--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON

update bluebin.TimeStudyNodeService set MostRecent = 0 where MostRecent = 1 and FacilityID = @FacilityID and LocationID = @LocationID and TimeStudyProcessID = @TimeStudyProcessID and [Date] < getdate()
;

declare @BlueBinUserID int 
select @bluebinUserID = BlueBinUserID from bluebin.BlueBinUser where UserLogin = @BlueBinUser
declare @Times Table ([Start] varchar(11),[Stop] varchar(11))
insert into @Times select left(getdate(),11),left(getdate(),11) 

Insert into bluebin.TimeStudyNodeService (	
	[Date],
	[FacilityID],
	[LocationID],
	[TravelLocationID], 
	[TimeStudyProcessID],
	[StartTime],
	[StopTime],
	[SKUS],
	[Comments],
	[BlueBinUserID],
	[BlueBinResourceID],
	[MostRecent],
	[Active],
    [LastUpdated])
VALUES (
	getdate(), --Entered is current time
	@FacilityID,
	@LocationID,
	@TravelLocationID,
	@TimeStudyProcessID,
	(select convert(datetime,([Start] + ' ' + @StartTime),112) from @Times),
	(select convert(datetime,([Stop] + ' ' + @StopTime),112) from @Times),
	@SKUS,
	@Comments,
	@BlueBinUserID,
	@BlueBinResourceID,
	1, --Most Recent  New entries default to 1
	1, --Active Flag  Default to 1
	getdate() --Last Updated is current time
)

Declare @TimeStudyID int, @BlueBinUserLogin varchar(50)
SET @TimeStudyID = SCOPE_IDENTITY()
	exec sp_InsertMasterLog @BlueBinUser,'TimeStudy','Submit Time Study NodeService',@TimeStudyID


END 

GO
grant exec on sp_InsertTimeStudyNodeService to appusers
GO