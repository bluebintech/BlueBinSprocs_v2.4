if exists (select * from dbo.sysobjects where id = object_id(N'sp_SelectTraining') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_SelectTraining
GO

--select * from bluebin.Training  select * from bluebin.BlueBinResource
--exec sp_SelectTraining '','300'
CREATE PROCEDURE sp_SelectTraining
@Name varchar (30),
@Module varchar (50)


--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON
SELECT 
bbt.[TrainingID],
bbt.[BlueBinResourceID], 
bbr.[LastName] + ', ' +bbr.[FirstName] as ResourceName, 
bbr.Title,
bbt.Status,
ISNULL(trained.Ct,0) as Trained,
ISNULL(trained.Ct,0) + ISNULL(nottrained.Ct,0) as Total,
bbtm.ModuleName,
bbtm.ModuleDescription,
ISNULL((bbu.[LastName] + ', ' +bbu.[FirstName]),'N/A') as Updater,
case when bbt.Active = 0 then 'No' else 'Yes' end as Active,

bbt.LastUpdated

FROM [bluebin].[Training] bbt
inner join [bluebin].[BlueBinResource] bbr on bbt.[BlueBinResourceID] = bbr.[BlueBinResourceID]
inner join bluebin.TrainingModule bbtm on bbt.TrainingModuleID = bbtm.TrainingModuleID
left join [bluebin].[BlueBinUser] bbu on bbt.[BlueBinUserID] = bbu.[BlueBinUserID]
left join (select BlueBinResourceID,count(*) as Ct from [bluebin].[Training] where Active = 1 and Status = 'Trained' group by BlueBinResourceID) trained on bbt.[BlueBinResourceID] = trained.[BlueBinResourceID]
left join (select BlueBinResourceID,count(*) as Ct from [bluebin].[Training] where Active = 1 and Status <> 'Trained' group by BlueBinResourceID) nottrained on bbt.[BlueBinResourceID] = nottrained.[BlueBinResourceID]
WHERE 
bbt.Active = 1 and 
bbtm.ModuleName like '%' + @Module + '%' and 
(bbr.[LastName] like '%' + @Name + '%' 
	OR bbr.[FirstName] like '%' + @Name + '%') 
	
ORDER BY bbr.[LastName]
END

GO
grant exec on sp_SelectTraining to appusers
GO
