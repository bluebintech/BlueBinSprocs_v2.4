if exists (select * from dbo.sysobjects where id = object_id(N'sp_DeleteTrainingModule') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_DeleteTrainingModule
GO

CREATE PROCEDURE sp_DeleteTrainingModule
@TrainingModuleID int

--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON
Update [bluebin].[TrainingModule] set [Active] = 0, [LastUpdated] = getdate() where TrainingModuleID = @TrainingModuleID

update bluebin.Training set [Active] = 0, [LastUpdated] = getdate() where TrainingModuleID = @TrainingModuleID
END
GO
grant exec on sp_DeleteTrainingModule to appusers
GO
