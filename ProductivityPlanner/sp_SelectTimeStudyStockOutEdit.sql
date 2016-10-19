
--*****************************************************
--**************************SPROC**********************

if exists (select * from dbo.sysobjects where id = object_id(N'sp_SelectTimeStudyStockOutEdit') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_SelectTimeStudyStockOutEdit
GO

--exec sp_SelectTimeStudyStockOutEdit 'TEST'

CREATE PROCEDURE sp_SelectTimeStudyStockOutEdit
@TimeStudyStockOutID int



--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON
	
select
	[TimeStudyStockOutID] ,
	[Date] ,
	[FacilityID],
	[LocationID],
	[TimeStudyProcessID],
	convert(varchar(2),DATEPART(hh,StartTime))+':'+right(('0' + convert(varchar(2),DATEPART(mi,StartTime))),2) as StartTime,
	convert(varchar(2),DATEPART(hh,StopTime))+':'+right(('0' + convert(varchar(2),DATEPART(mi,StopTime))),2) as StopTime,
	[SKUS],
	[Comments],
	[BlueBinUserID] ,
	[BlueBinResourceID]

FROM bluebin.TimeStudyStockOut t
WHERE [TimeStudyStockOutID] = @TimeStudyStockOutID 
				

END
GO
grant exec on sp_SelectTimeStudyStockOutEdit to appusers
GO
