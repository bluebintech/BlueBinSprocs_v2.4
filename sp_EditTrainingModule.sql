if exists (select * from dbo.sysobjects where id = object_id(N'sp_EditTrainingModule') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_EditTrainingModule
GO

--exec sp_EditTrainingModule ''
--select * from [bluebin].[TrainingModule]


CREATE PROCEDURE sp_EditTrainingModule
@TrainingModuleID int, 
@ModuleName varchar(50),
@ModuleDescription varchar(255),
@Required int

--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON


update [bluebin].[TrainingModule]
set
ModuleName=@ModuleName,
ModuleDescription=@ModuleDescription,
[Required]=@Required,
LastUpdated = getdate()
where TrainingModuleID = @TrainingModuleID
	;

END
GO

grant exec on sp_EditTrainingModule to appusers
GO

