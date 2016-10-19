
--*****************************************************
--**************************SPROC**********************

if exists (select * from dbo.sysobjects where id = object_id(N'sp_EditTimeStudyBinFill') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_EditTimeStudyBinFill
GO

--exec sp_EditTimeStudyBinFill 
CREATE PROCEDURE sp_EditTimeStudyBinFill
@TimeStudyBinFillID int,
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
insert into @Times select left(StartTime,10),left(StopTime,10) from [bluebin].[TimeStudyStockOut] where TimeStudyStockOutID = @TimeStudyBinFillID


update [bluebin].[TimeStudyBinFill] 
set 

StartTime = (select convert(datetime,([Start] + ' ' + @StartTime),112) from @Times),
StopTime = (select convert(datetime,([Stop] + ' ' + @StopTime),112) from @Times),
SKUS = @SKUS,
Comments = @Comments,
BlueBinResourceID = @BlueBinResourceID


where TimeStudyBinFillID = @TimeStudyBinFillID
;
declare @BlueBinUserID int 
select @BlueBinUserID = BlueBinUserID from [bluebin].[TimeStudyBinFill] where TimeStudyBinFillID = @TimeStudyBinFillID
exec sp_InsertMasterLog @BlueBinUserID,'TimeStudy','Edit Time Study BinFill',@TimeStudyBinFillID

END
GO
grant exec on sp_EditTimeStudyBinFill to appusers
GO
