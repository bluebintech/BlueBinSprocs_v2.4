
--*****************************************************
--**************************SPROC**********************

if exists (select * from dbo.sysobjects where id = object_id(N'sp_SelectTimeStudyProcess') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_SelectTimeStudyProcess
GO

--select * from bluebin.TimeStudyProcess
--exec sp_SelectTimeStudyProcess 'Summary Information','Efficiency Factor'

CREATE PROCEDURE sp_SelectTimeStudyProcess
@ProcessType varchar(100),
@ProcessName varchar(100)
--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON

select
TimeStudyProcessID,
ProcessType,
ProcessName,
ProcessValue,
Description,
LastUpdated

FROM bluebin.TimeStudyProcess 

where Active = 1 and ProcessType like '%' + @ProcessType + '%' and ProcessName like '%' + @ProcessName + '%'

END
GO
grant exec on sp_SelectTimeStudyProcess to appusers
GO



