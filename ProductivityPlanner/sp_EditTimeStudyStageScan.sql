
--*****************************************************
--**************************SPROC**********************

if exists (select * from dbo.sysobjects where id = object_id(N'sp_EditTimeStudyStageScan') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_EditTimeStudyStageScan
GO

--exec sp_EditTimeStudyStageScan 
CREATE PROCEDURE sp_EditTimeStudyStageScan
@TimeStudyStageScanID int,
@StartTime varchar(5),
@StopTime varchar(5),
@SKUS int,
@Comments varchar(max),
@BlueBinResourceID int

--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON


declare @Times Table ([Start] varchar(10),[Stop] varchar(10))
insert into @Times select left(StartTime,10),left(StopTime,10) from [bluebin].[TimeStudyStockOut] where TimeStudyStockOutID = @TimeStudyStageScanID


update [bluebin].[TimeStudyStageScan] 
set 

StartTime = (select convert(datetime,([Start] + ' ' + @StartTime),112) from @Times),
StopTime = (select convert(datetime,([Stop] + ' ' + @StopTime),112) from @Times),
SKUS = @SKUS,
Comments = @Comments,
BlueBinResourceID = @BlueBinResourceID

where TimeStudyStageScanID = @TimeStudyStageScanID
;
declare @BlueBinUserID int 
select @BlueBinUserID = BlueBinUserID from [bluebin].[TimeStudyStageScan] where TimeStudyStageScanID = @TimeStudyStageScanID
exec sp_InsertMasterLog @BlueBinUserID,'TimeStudy','Edit Time Study StageScan',@TimeStudyStageScanID

END
GO
grant exec on sp_EditTimeStudyStageScan to appusers
GO
