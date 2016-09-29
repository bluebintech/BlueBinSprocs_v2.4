if exists (select * from dbo.sysobjects where id = object_id(N'sp_DeleteTraining') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_DeleteTraining
GO

CREATE PROCEDURE sp_DeleteTraining
@TrainingID int

--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON
Update [bluebin].[Training] set [Active] = 0, [LastUpdated] = getdate() where TrainingID = @TrainingID

END
GO
grant exec on sp_DeleteTraining to appusers
GO
