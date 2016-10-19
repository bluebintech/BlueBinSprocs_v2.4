
--*****************************************************
--**************************SPROC**********************

if exists (select * from dbo.sysobjects where id = object_id(N'sp_EditTimeStudyNodeService') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_EditTimeStudyNodeService
GO

--exec sp_EditTimeStudyNodeService 
CREATE PROCEDURE sp_EditTimeStudyNodeService
@TimeStudyNodeServiceID int,
@TravelLocationID varchar(10),
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
insert into @Times select left(StartTime,10),left(StopTime,10) from [bluebin].[TimeStudyStockOut] where TimeStudyStockOutID = @TimeStudyNodeServiceID


update [bluebin].[TimeStudyNodeService] 
set 

StartTime = (select convert(datetime,([Start] + ' ' + @StartTime),112) from @Times),
StopTime = (select convert(datetime,([Stop] + ' ' + @StopTime),112) from @Times),
SKUS = @SKUS,
Comments = @Comments,
BlueBinResourceID = @BlueBinResourceID,
TravelLocationID = @TravelLocationID

where TimeStudyNodeServiceID = @TimeStudyNodeServiceID
;
declare @BlueBinUserID int 
select @BlueBinUserID = BlueBinUserID from [bluebin].[TimeStudyNodeService] where TimeStudyNodeServiceID = @TimeStudyNodeServiceID
exec sp_InsertMasterLog @BlueBinUserID,'TimeStudy','Edit Time Study NodeService',@TimeStudyNodeServiceID


END
GO
grant exec on sp_EditTimeStudyNodeService to appusers
GO
