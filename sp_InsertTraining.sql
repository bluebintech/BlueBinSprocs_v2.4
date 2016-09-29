if exists (select * from dbo.sysobjects where id = object_id(N'sp_InsertTraining') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_InsertTraining
GO

--exec sp_InsertTraining 1,'Yes','No','No','No','No','No','No','No','No','No','No','gbutler@bluebin.com'


CREATE PROCEDURE sp_InsertTraining
@BlueBinResource int,--varchar(255), 
@TrainingModuleID int,
@Status varchar(10),
@Updater varchar(255)

--WITH ENCRYPTION 
AS
BEGIN
SET NOCOUNT ON

if not exists (select * from bluebin.Training where Active = 1 and TrainingModuleID = @TrainingModuleID and BlueBinResourceID in (select BlueBinResourceID from bluebin.BlueBinResource where BlueBinResourceID  = @BlueBinResource))--
	BEGIN
	insert into bluebin.Training ([BlueBinResourceID],[TrainingModuleID],[Status],[BlueBinUserID],[Active],[LastUpdated])
	select 
		@BlueBinResource,
		@TrainingModuleID,
		@Status,
		(select BlueBinUserID from bluebin.BlueBinUser where LOWER(UserLogin) = LOWER(@Updater)),
		1, --Default Active to Yes
		getdate()


	
	;
	declare @TrainingID int
	SET @TrainingID = SCOPE_IDENTITY()
		exec sp_InsertMasterLog @Updater,'Training','New Training Record Entered',@TrainingID
	END
END
GO

grant exec on sp_InsertTraining to appusers
GO



