
--*****************************************************
--**************************SPROC**********************

if exists (select * from dbo.sysobjects where id = object_id(N'sp_SelectTimeStudyGroup') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_SelectTimeStudyGroup
GO

--select * from bluebin.TimeStudyGroup
--exec sp_SelectTimeStudyGroup 

CREATE PROCEDURE sp_SelectTimeStudyGroup
@FacilityName varchar(50)
,@LocationName varchar(50)
,@GroupName varchar(50)

--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON

select
df.FacilityName,
dl.LocationID,
dl.LocationName,
t.GroupName,
t.Active,
t.LastUpdated,
t.Description

FROM bluebin.TimeStudyGroup t
inner join bluebin.DimLocation dl on t.LocationID = dl.LocationID and t.FacilityID = dl.LocationFacility
inner join bluebin.DimFacility df on t.FacilityID = df.FacilityID
where t.Active = 1
and df.FacilityName like '%' + @FacilityName + '%'
and dl.LocationName like '%' + @LocationName + '%'
and t.GroupName like '%' + @GroupName + '%'

END
GO
grant exec on sp_SelectTimeStudyGroup to appusers
GO




