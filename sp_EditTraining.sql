if exists (select * from dbo.sysobjects where id = object_id(N'sp_EditTraining') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_EditTraining
GO

--exec sp_EditTraining ''
--select * from [bluebin].[Training]


CREATE PROCEDURE sp_EditTraining
@TrainingID int, 
@Status varchar(10),
@Updater varchar(255)

--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON


update [bluebin].[Training]
set
Status=@Status,
BlueBinUserID = (select BlueBinUserID from bluebin.BlueBinUser where LOWER(UserLogin) = LOWER(@Updater)),
	LastUpdated = getdate()
where TrainingID = @TrainingID
	;
exec sp_InsertMasterLog @Updater,'Training','Training Record Updated',@TrainingID
END
GO

grant exec on sp_EditTraining to appusers
GO

