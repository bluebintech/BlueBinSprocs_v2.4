
--*****************************************************
--**************************SPROC**********************

if exists (select * from dbo.sysobjects where id = object_id(N'sp_InsertTimeStudyProcess') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_InsertTimeStudyProcess
GO

/*
exec sp_InsertTimeStudyProcess 'Double Bin StockOut','Write down Item numbers and sweep Stage','','Write down Item numbers and sweep Stage' 
exec sp_InsertTimeStudyProcess 'Double Bin StockOut','Key out MSR','','Key out MSR'
exec sp_InsertTimeStudyProcess 'Double Bin StockOut','Pick Items','','Pick Items'
exec sp_InsertTimeStudyProcess 'Double Bin StockOut','Deliver Items','','Deliver Items'

exec sp_InsertTimeStudyProcess 'Node Service','Leave Stage to enter node','','Leave Stage to enter node'
exec sp_InsertTimeStudyProcess 'Node Service','Node service time','','Node service time'
exec sp_InsertTimeStudyProcess 'Node Service','Returns bin time','','Returns bin time'
exec sp_InsertTimeStudyProcess 'Node Service','Travel time to next node','','Travel time to next node'

exec sp_InsertTimeStudyProcess 'Stat Calls','Travel to WH','','Travel to WH'
exec sp_InsertTimeStudyProcess 'Stat Calls','Pick Product','','Pick Product'
exec sp_InsertTimeStudyProcess 'Stat Calls','Paperwork','','Paperwork'
exec sp_InsertTimeStudyProcess 'Stat Calls','Deliver Product','','Deliver Product'

exec sp_InsertTimeStudyProcess 'Summary Information','Returns Bins','2.30','Average Time to Return Default Setting(s)'
exec sp_InsertTimeStudyProcess 'Summary Information','Returns Bins','1.86','Average Time to Return Default Setting(s)'
exec sp_InsertTimeStudyProcess 'Summary Information','Efficiency Factor','.75','Default Efficiency Factor'

*/

CREATE PROCEDURE sp_InsertTimeStudyProcess
@ProcessType varchar(100),
@ProcessName varchar(100),
@ProcessValue varchar(100),
@Description varchar(255)


--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON

Insert into bluebin.TimeStudyProcess ([ProcessType],[ProcessName],[ProcessValue],[Description],[Active],[LastUpdated]) VALUES
(
@ProcessType,
@ProcessName,
@ProcessValue,
@Description,
1,
getdate()
)
END
GO
grant exec on sp_InsertTimeStudyProcess to appusers
GO