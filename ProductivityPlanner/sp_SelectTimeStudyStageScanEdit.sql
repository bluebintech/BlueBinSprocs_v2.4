
--*****************************************************
--**************************SPROC**********************

if exists (select * from dbo.sysobjects where id = object_id(N'sp_SelectTimeStudyStageScanEdit') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_SelectTimeStudyStageScanEdit
GO

--exec sp_SelectTimeStudyStageScanEdit 'TEST'

CREATE PROCEDURE sp_SelectTimeStudyStageScanEdit
@TimeStudyStageScanID int


--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON
	
select
	[TimeStudyStageScanID] ,
	[Date] ,
	[FacilityID],
	[LocationID],
	convert(varchar(2),DATEPART(hh,StartTime))+':'+right(('0' + convert(varchar(2),DATEPART(mi,StartTime))),2) as StartTime,
	convert(varchar(2),DATEPART(hh,StopTime))+':'+right(('0' + convert(varchar(2),DATEPART(mi,StopTime))),2) as StopTime,
	[SKUS],
	[Comments],
	[BlueBinUserID] ,
	[BlueBinResourceID]

FROM bluebin.TimeStudyStageScan t

WHERE [TimeStudyStageScanID] = @TimeStudyStageScanID 
				

END
GO
grant exec on sp_SelectTimeStudyStageScanEdit to appusers
GO
