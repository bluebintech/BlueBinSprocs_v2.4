if exists (select * from dbo.sysobjects where id = object_id(N'sp_SelectTrainingModule') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_SelectTrainingModule
GO


--exec sp_SelectTrainingModule 
CREATE PROCEDURE sp_SelectTrainingModule
@Module varchar (50)


--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON
select 
TrainingModuleID,
ModuleName,
ModuleDescription,
Active,
[Required],
LastUpdated
 from bluebin.TrainingModule
WHERE
ModuleName like '%' + @Module + '%'
and Active = 1
END

GO
grant exec on sp_SelectTrainingModule to appusers
GO
