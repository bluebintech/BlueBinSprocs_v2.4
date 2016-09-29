if exists (select * from dbo.sysobjects where id = object_id(N'tb_GembaDashboard') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure tb_GembaDashboard
GO

--exec tb_GembaDashboard 
CREATE PROCEDURE tb_GembaDashboard

--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON

select 
	g.[GembaAuditNodeID],
	df.FacilityName,
	dl.[LocationID],
	g.LocationID as AuditLocationID,
        dl.[LocationName],
			dl.BlueBinFlag,
	u.LastName + ', ' + u.FirstName  as Auditer,
    u.[UserLogin] as Login,
	u.Title as RoleName,
	u.GembaTier,
	g.PS_TotalScore,
	g.RS_TotalScore,
	g.SS_TotalScore,
	g.NIS_TotalScore,
	g.TotalScore,
	case when TotalScore < 90 then 1 else 0 end as ScoreUnder,
	(select count(*) from bluebin.DimLocation where BlueBinFlag = 1) as LocationCount,
    g.[Date],
	g2.[MaxDate] as LastAuditDate,
	case 
		when g.[Date] is null then 365
		else convert(int,(getdate() - g2.[MaxDate])) end as LastAudit,
	tier1.[MaxDate] as LastAuditDateTier1,
	case 
		when g.[Date] is null  and tier1.[MaxDate] is null or g2.[MaxDate] is not null and dl.LocationID not in (select LocationID from [gemba].[GembaAuditNode] where AuditerUserID in (select BlueBinUserID from bluebin.BlueBinUser where GembaTier = 'Tier1')) then 365
		else convert(int,(getdate() - tier1.[MaxDate])) end as LastAuditTier1,
	tier2.[MaxDate] as LastAuditDateTier2,	
	case 
		when g.[Date] is null  and tier2.[MaxDate] is null or g2.[MaxDate] is not null and dl.LocationID not in (select LocationID from [gemba].[GembaAuditNode] where AuditerUserID in (select BlueBinUserID from bluebin.BlueBinUser where GembaTier = 'Tier2')) then 365
		else convert(int,(getdate() - tier2.[MaxDate])) end as LastAuditTier2,
	tier3.[MaxDate] as LastAuditDateTier3,	
	case 
		when g.[Date] is null and tier3.[MaxDate] is null  or g2.[MaxDate] is not null and dl.LocationID not in (select LocationID from [gemba].[GembaAuditNode] where AuditerUserID in (select BlueBinUserID from bluebin.BlueBinUser where GembaTier = 'Tier3')) then 365
		else convert(int,(getdate() - tier3.[MaxDate])) end as LastAuditTier3,
		
    g.[LastUpdated]
from  [bluebin].[DimLocation] dl
		left join [gemba].[GembaAuditNode] g on dl.LocationID = g.LocationID
		left join (select Max([Date]) as MaxDate,LocationID from [gemba].[GembaAuditNode] group by LocationID) g2 on dl.LocationID = g2.LocationID and g.[Date] = g2.MaxDate
		left join (select Max([Date]) as MaxDate,LocationID from [gemba].[GembaAuditNode] where AuditerUserID in (select BlueBinUserID from bluebin.BlueBinUser where GembaTier = 'Tier1') group by LocationID) tier1 on dl.LocationID = tier1.LocationID and g.[Date] = tier1.MaxDate
		left join (select Max([Date]) as MaxDate,LocationID from [gemba].[GembaAuditNode] where AuditerUserID in (select BlueBinUserID from bluebin.BlueBinUser where GembaTier = 'Tier2') group by LocationID) tier2 on dl.LocationID = tier2.LocationID and g.[Date] = tier2.MaxDate
		left join (select Max([Date]) as MaxDate,LocationID from [gemba].[GembaAuditNode] where AuditerUserID in (select BlueBinUserID from bluebin.BlueBinUser where GembaTier = 'Tier3') group by LocationID) tier3 on dl.LocationID = tier3.LocationID and g.[Date] = tier3.MaxDate
        --left join [bluebin].[DimLocation] dl on g.LocationID = dl.LocationID and dl.BlueBinFlag = 1
		left join [bluebin].[BlueBinUser] u on g.AuditerUserID = u.BlueBinUserID
		left join bluebin.BlueBinRoles bbr on u.RoleID = bbr.RoleID
		left join bluebin.DimFacility df on dl.LocationFacility = df.FacilityID
WHERE dl.BlueBinFlag = 1 and g.Active = 1
            order by dl.LocationID,[Date] asc

END
GO
grant exec on tb_GembaDashboard to public
GO


