
--*****************************************************
--**************************SPROC**********************

if exists (select * from dbo.sysobjects where id = object_id(N'sp_SelectTimeStudyBinFillEdit') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_SelectTimeStudyBinFillEdit
GO

--exec sp_SelectTimeStudyBinFillEdit 'TEST'

CREATE PROCEDURE sp_SelectTimeStudyBinFillEdit
@TimeStudyBinFillID int



--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON
	
select
	[TimeStudyBinFillID] ,
	[Date] ,
	[FacilityID],
	[LocationID],
	convert(varchar(2),DATEPART(hh,StartTime))+':'+right(('0' + convert(varchar(2),DATEPART(mi,StartTime))),2) as StartTime,
	convert(varchar(2),DATEPART(hh,StopTime))+':'+right(('0' + convert(varchar(2),DATEPART(mi,StopTime))),2) as StopTime,
	[SKUS],
	[Comments],
	[BlueBinUserID] ,
	[BlueBinResourceID]

FROM bluebin.TimeStudyBinFill t
WHERE [TimeStudyBinFillID] = @TimeStudyBinFillID 				

END
GO
grant exec on sp_SelectTimeStudyBinFillEdit to appusers
GO
