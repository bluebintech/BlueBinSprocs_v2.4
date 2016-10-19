
--*****************************************************
--**************************SPROC**********************

if exists (select * from dbo.sysobjects where id = object_id(N'sp_InsertTimeStudyStockOut') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_InsertTimeStudyStockOut
GO

/*
exec sp_InsertTimeStudyStockOut '6','BB001','1','09:51','09:59','3','Test Comments',1,1
exec sp_InsertTimeStudyStockOut '6','BB002','1','09:01','09:13','3','Test Comments',1,1
exec sp_InsertTimeStudyStockOut '6','BB001','2','09:03','09:22','14','Test Comments',1,1
exec sp_InsertTimeStudyStockOut '6','BB001','3','09:16','09:20','14','Test Comments',1,1
exec sp_InsertTimeStudyStockOut '6','BB002','3','09:26','09:50','14','Test Comments',1,1
exec sp_InsertTimeStudyStockOut '6','BB001','4','09:28','09:33','3','Test Comments',1,1
exec sp_InsertTimeStudyStockOut '6','BB002','4','09:34','09:40','2','Test Comments',1,1
exec sp_InsertTimeStudyStockOut '6','BB003','4','09:42','09:50','2','Test Comments',1,1

select * from bluebin.TimeStudyStockOut
select * from bluebin.TimeStudyProcess
select * from bluebin.TimeStudyGroup
*/

CREATE PROCEDURE sp_InsertTimeStudyStockOut
	@FacilityID int,
	@LocationID varchar(10),	
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

update bluebin.TimeStudyStockOut set MostRecent = 0 where MostRecent = 1 and FacilityID = @FacilityID and LocationID = @LocationID and TimeStudyProcessID = @TimeStudyProcessID and [Date] < getdate()
;

declare @BlueBinUserID int 
select @bluebinUserID = BlueBinUserID from bluebin.BlueBinUser where UserLogin = @BlueBinUser

declare @Times Table ([Start] varchar(11),[Stop] varchar(11))
insert into @Times select left(getdate(),11),left(getdate(),11) 

Insert into bluebin.TimeStudyStockOut (	
	[Date],
	[FacilityID],
	[LocationID],
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

	exec sp_InsertMasterLog @BlueBinUser,'TimeStudy','Submit Time Study Stock Out',@TimeStudyID

END
GO
grant exec on sp_InsertTimeStudyStockOut to appusers
GO