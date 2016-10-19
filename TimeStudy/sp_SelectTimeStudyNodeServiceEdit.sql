
--*****************************************************
--**************************SPROC**********************

if exists (select * from dbo.sysobjects where id = object_id(N'sp_SelectTimeStudyNodeServiceEdit') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_SelectTimeStudyNodeServiceEdit
GO

--exec sp_SelectTimeStudyNodeServiceEdit 'TEST'

CREATE PROCEDURE sp_SelectTimeStudyNodeServiceEdit
@TimeStudyNodeServiceID int



--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON
	
select
	[TimeStudyNodeServiceID] ,
	[Date] ,
	[FacilityID],
	[LocationID],
	[TravelLocationID],
	[TimeStudyProcessID],
	convert(varchar(2),DATEPART(hh,StartTime))+':'+right(('0' + convert(varchar(2),DATEPART(mi,StartTime))),2) as StartTime,
	convert(varchar(2),DATEPART(hh,StopTime))+':'+right(('0' + convert(varchar(2),DATEPART(mi,StopTime))),2) as StopTime,
	[SKUS],
	[Comments],
	[BlueBinUserID] ,
	[BlueBinResourceID]

FROM bluebin.TimeStudyNodeService t

WHERE [TimeStudyNodeServiceID] = @TimeStudyNodeServiceID 
				

END
GO
grant exec on sp_SelectTimeStudyNodeServiceEdit to appusers
GO
