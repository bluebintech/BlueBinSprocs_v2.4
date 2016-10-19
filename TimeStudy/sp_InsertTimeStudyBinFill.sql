
--*****************************************************
--**************************SPROC**********************

if exists (select * from dbo.sysobjects where id = object_id(N'sp_InsertTimeStudyBinFill') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_InsertTimeStudyBinFill
GO

--exec sp_InsertTimeStudyBinFill '6','BB001','10:00','14:00','5','Test Comments',1,1
/*
select * from bluebin.TimeStudyBinFill
select * from bluebin.TimeStudyProcess
select * from bluebin.TimeStudyGroup
*/

CREATE PROCEDURE sp_InsertTimeStudyBinFill
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

update bluebin.TimeStudyBinFill set MostRecent = 0 where MostRecent = 1 and FacilityID = @FacilityID and LocationID = @LocationID and [Date] < getdate()

declare @BlueBinUserID int 
select @bluebinUserID = BlueBinUserID from bluebin.BlueBinUser where UserLogin = @BlueBinUser

declare @Times Table ([Start] varchar(11),[Stop] varchar(11))
insert into @Times select left(getdate(),11),left(getdate(),11) 


Insert into bluebin.TimeStudyBinFill (	
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

	exec sp_InsertMasterLog @BlueBinUser,'TimeStudy','Submit Time Study BinFill',@TimeStudyID


END

GO
grant exec on sp_InsertTimeStudyBinFill to appusers
GO