
--*****************************************************
--**************************SPROC**********************

if exists (select * from dbo.sysobjects where id = object_id(N'sp_SelectTimeStudyNodeService') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_SelectTimeStudyNodeService
GO


--select * from bluebin.TimeStudyNodeService
--exec sp_SelectTimeStudyNodeService '%','%','%','2'

CREATE PROCEDURE sp_SelectTimeStudyNodeService
@FacilityName varchar(50)
,@LocationName varchar(50)
,@UserName varchar(50)
,@MostRecent int

--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON

declare @MostRecent2 int
if @MostRecent = 2 
BEGIN
set @MostRecent = 0
set @MostRecent2 = 1
END

select
'Time Study Node Service' as TimeStudy,
t.TimeStudyNodeServiceID,
t.Date,
df.FacilityName,
dl.LocationID,
case
		when t.[LocationID] = 'Multiple' then t.LocationID
		else case	when dl.LocationID = dl.LocationName then dl.LocationID
					else dl.LocationID + ' - ' + dl.[LocationName] end end as LocationName,
bbu.LastName + ', ' + bbu.FirstName as SubmittedBy,
ISNULL(bbr.LastName + ', ' + bbr.FirstName,'') as ServiceTech,
case when t.MostRecent = '1' then 'Yes' else 'No' end as MostRecent,
c.ConfigValue as ProcessName,
t.SKUS,
ISNULL(dl2.LocationID,'') as TravelLocationID,
ISNULL(dl2.LocationName,'') as TravelLocationName,
DATEDIFF(ss,t.StartTime,t.StopTime) as [Seconds],
DATEDIFF(mi,t.StartTime,t.StopTime) as [Minutes]

FROM bluebin.TimeStudyNodeService t
inner join bluebin.Config c on t.TimeStudyProcessID = c.ConfigID and c.ConfigType = 'TimeStudy'
inner join bluebin.DimLocation dl on t.LocationID = dl.LocationID and t.FacilityID = dl.LocationFacility
inner join bluebin.DimFacility df on t.FacilityID = df.FacilityID
inner join bluebin.BlueBinUser bbu on t.BlueBinUserID = bbu.BlueBinUserID
left join bluebin.DimLocation dl2 on t.TravelLocationID = dl2.LocationID
left join bluebin.BlueBinResource bbr on t.BlueBinResourceID = bbr.BlueBinResourceID
where t.Active = 1
and df.FacilityName like '%' + @FacilityName + '%'
and (dl.LocationID + ' - ' + dl.[LocationName] LIKE '%' + @LocationName + '%' or t.LocationID like '%' + @LocationName + '%')
and t.MostRecent in (@MostRecent,@MostRecent2)
and case	
	when @UserName <> '%' then bbu.LastName + ', ' + bbu.FirstName else '' end LIKE  '%' + @UserName + '%'

END
GO
grant exec on sp_SelectTimeStudyNodeService to appusers
GO



