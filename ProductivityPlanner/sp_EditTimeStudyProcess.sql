
--*****************************************************
--**************************SPROC**********************

if exists (select * from dbo.sysobjects where id = object_id(N'sp_EditTimeStudyProcess') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_EditTimeStudyProcess
GO

--exec sp_EditTimeStudyNodeService Type
CREATE PROCEDURE sp_EditTimeStudyProcess
@TimeStudyProcessID int,
@ProcessType varchar(100),
@ProcessName varchar(100),
@ProcessValue varchar(100),
@Description varchar(255)

--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON

update [bluebin].[TimeStudyProcess] 
set 
	[Description] = @Description,
	[ProcessType] = @ProcessType,
	[ProcessName] = @ProcessName,
	[ProcessValue] = @ProcessValue,
	[LastUpdated] = getdate()

where TimeStudyProcessID = @TimeStudyProcessID


END
GO
grant exec on sp_EditTimeStudyProcess to appusers
GO
