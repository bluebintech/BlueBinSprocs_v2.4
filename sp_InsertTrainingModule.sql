if exists (select * from dbo.sysobjects where id = object_id(N'sp_InsertTrainingModule') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_InsertTrainingModule
GO

--exec sp_InsertTrainingModule '',''
--select * from bluebin.TrainingModule

CREATE PROCEDURE sp_InsertTrainingModule 
@ModuleName varchar(50),
@ModuleDescription varchar(255),
@Required int


--WITH ENCRYPTION 
AS
BEGIN
SET NOCOUNT ON

if not exists (select * from bluebin.TrainingModule where ModuleName = @ModuleName)
	BEGIN
	insert into bluebin.TrainingModule (ModuleName,ModuleDescription,[Active],Required,[LastUpdated])
	select 
		@ModuleName,
		@ModuleDescription,
		1, --Default Active to Yes
		@Required,
		getdate()

		END
END
GO

grant exec on sp_InsertTrainingModule to appusers
GO


if exists (select * from dbo.sysobjects where id = object_id(N'sp_InsertTrainingModule') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_InsertTrainingModule
GO

--exec sp_InsertTrainingModule '',''
--select * from bluebin.TrainingModule

CREATE PROCEDURE sp_InsertTrainingModule 
@ModuleName varchar(50),
@ModuleDescription varchar(255),
@Required int


--WITH ENCRYPTION 
AS
BEGIN
SET NOCOUNT ON

if not exists (select * from bluebin.TrainingModule where ModuleName = @ModuleName)
	BEGIN
	insert into bluebin.TrainingModule (ModuleName,ModuleDescription,[Active],Required,[LastUpdated])
	select 
		@ModuleName,
		@ModuleDescription,
		1, --Default Active to Yes
		@Required,
		getdate()

		END
END
GO

grant exec on sp_InsertTrainingModule to appusers
GO




