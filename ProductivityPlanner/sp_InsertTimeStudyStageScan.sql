
--*****************************************************
--**************************SPROC**********************

if exists (select * from dbo.sysobjects where id = object_id(N'sp_InsertTimeStudyStageScan') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_InsertTimeStudyStageScan
GO

/*
exec sp_InsertTimeStudyStageScan '6','BB001','08:51','08:57','19','Test Comments',1,1
exec sp_InsertTimeStudyStageScan '6','BB002','09:03','09:10','19','Test Comments',1,1
exec sp_InsertTimeStudyStageScan '6','BB003','09:16','09:20','19','Test Comments',1,1
exec sp_InsertTimeStudyStageScan '6','BB004','09:28','09:29','19','Test Comments',1,1

select * from bluebin.TimeStudyStageScan
select * from bluebin.TimeStudyProcess
select * from bluebin.TimeStudyGroup
*/ 

CREATE PROCEDURE sp_InsertTimeStudyStageScan
	@FacilityID int,
	@LocationID varchar(10),
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

update bluebin.TimeStudyStageScan set MostRecent = 0 where MostRecent = 1 and FacilityID = @FacilityID and LocationID = @LocationID and [Date] < getdate()
;

declare @BlueBinUserID int 
select @bluebinUserID = BlueBinUserID from bluebin.BlueBinUser where UserLogin = @BlueBinUser

declare @Times Table ([Start] varchar(11),[Stop] varchar(11))
insert into @Times select left(getdate(),11),left(getdate(),11) 

Insert into bluebin.TimeStudyStageScan (	
	[Date],
	[FacilityID],
	[LocationID],
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

	exec sp_InsertMasterLog @BlueBinUser,'TimeStudy','Submit Time Study StageScan',@TimeStudyID

END
GO
grant exec on sp_InsertTimeStudyStageScan to appusers
GO