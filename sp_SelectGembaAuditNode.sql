--*****************************************************
--**************************SPROC**********************

if exists (select * from dbo.sysobjects where id = object_id(N'sp_SelectGembaAuditNode') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_SelectGembaAuditNode
GO
--Edited GB 20180208
--exec sp_SelectGembaAuditNode '%','%','%','%'

CREATE PROCEDURE sp_SelectGembaAuditNode
@FacilityName varchar(50),
@LocationName varchar(50),
@Auditer varchar(50),
@ExpiredItems varchar(1)

--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON
    select 
	q.Date,
    q.[GembaAuditNodeID],
	df.FacilityName,
	case
		when dl.LocationID = dl.LocationName then dl.LocationID
		else rtrim(dl.[LocationName]) + ' - ' +  dl.LocationID end as LocationName,
		--else dl.LocationID + ' - ' + dl.[LocationName] end as LocationName,
	u.LastName + ', ' + u.FirstName as Auditer,
    u.UserLogin as AuditerLogin,
    q.PS_TotalScore as [Pull Score],
    q.RS_TotalScore as [Replenishment Score],
    q.NIS_TotalScore as [Node Integrity Score],
	q.SS_TotalScore as [Stage Score],
    q.TotalScore as [Total Score],
    case when i.ImageSourceID is null then 'No' else 'Yes' end as Images,
	q.AdditionalComments as AdditionalCommentsText,
    case when q.AdditionalComments ='' then 'No' else 'Yes' end [Addtl Comments],
	case when q.PS_ExpiredItems = '5' then 'No' else 'Yes' end as ExpiredItems,
    q.LastUpdated
from [gemba].[GembaAuditNode] q
inner join bluebin.DimFacility df on q.FacilityID = df.FacilityID
inner join [bluebin].[DimLocation] dl on q.LocationID = dl.LocationID and q.FacilityID = dl.LocationFacility and dl.BlueBinFlag = 1
inner join [bluebin].[BlueBinUser] u on q.AuditerUserID = u.BlueBinUserID
left join (select distinct ImageSourceID from bluebin.Image where ImageSource like 'Gemba%' and Active = 1) i on q.GembaAuditNodeID = i.ImageSourceID
    Where q.Active = 1 
	and df.[FacilityName] LIKE '%' + @FacilityName + '%' 
	and rtrim(dl.[LocationName]) + ' - ' +  dl.LocationID LIKE '%' + @LocationName + '%'
	and u.LastName + ', ' + u.FirstName LIKE '%' + @Auditer + '%'
	and q.PS_ExpiredItems like '%' + @ExpiredItems + '%'
	order by q.Date desc

END
GO
grant exec on sp_SelectGembaAuditNode to appusers
GO


