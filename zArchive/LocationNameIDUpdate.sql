--*****************************************************
--**************************SPROC**********************

if exists (select * from dbo.sysobjects where id = object_id(N'sp_SelectLocation') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_SelectLocation
GO

--exec sp_SelectLocation 

CREATE PROCEDURE sp_SelectLocation

--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON

SELECT 
LocationFacility as FacilityID,
rtrim(LocationID) as LocationID,
--LocationName,
case when LocationID = LocationName then LocationID else rtrim([LocationName]) + ' - ' + LocationID end as LocationName 
FROM [bluebin].[DimLocation] where BlueBinFlag = 1

order by LocationID
END
GO
grant exec on sp_SelectLocation to appusers
GO

--*****************************************************
--**************************SPROC**********************

if exists (select * from dbo.sysobjects where id = object_id(N'sp_SelectGembaAuditNodeLocation') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_SelectGembaAuditNodeLocation
GO

--exec sp_SelectGembaAuditNodeLocation
CREATE PROCEDURE sp_SelectGembaAuditNodeLocation

--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON

select 
	distinct 
	q.[LocationID],
	rtrim(dl.[LocationName]) + ' - ' + dl.LocationID  as LocationName
	--dl.LocationID + ' - ' + dl.[LocationName] as LocationName
	from gemba.GembaAuditNode q
	left join [bluebin].[DimLocation] dl on q.LocationID = dl.LocationID and dl.BlueBinFlag = 1
	order by LocationID
END
GO
grant exec on sp_SelectGembaAuditNodeLocation to appusers
GO


--*****************************************************
--**************************SPROC**********************

if exists (select * from dbo.sysobjects where id = object_id(N'sp_SelectQCNLocation') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_SelectQCNLocation
GO

--exec sp_SelectQCNLocation
CREATE PROCEDURE sp_SelectQCNLocation

--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON

select 
	distinct 
	q.[LocationID],
    case
		when q.[LocationID] = 'Multiple' then q.LocationID
		else case	when dl.LocationID = dl.LocationName then dl.LocationID
					else rtrim(dl.[LocationName]) + ' - ' + dl.LocationID end end as LocationName
	from qcn.QCN q
	left join [bluebin].[DimLocation] dl on q.LocationID = dl.LocationID and dl.BlueBinFlag = 1
	order by LocationID
END
GO
grant exec on sp_SelectQCNLocation to appusers
GO

--*****************************************************
--**************************SPROC**********************

if exists (select * from dbo.sysobjects where id = object_id(N'sp_SelectLocationCascade') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_SelectLocationCascade
GO

--exec sp_SelectLocationCascade 'Yes'

CREATE PROCEDURE sp_SelectLocationCascade
@Multiple varchar(3)

--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON
declare @MultipleID varchar(10), @MultipleName varchar(10)
select @MultipleID = case when @Multiple = 'Yes' then 'Multiple' else '' end
select @MultipleName = case when @Multiple = 'Yes' then 'Multiple' else '--Select--' end


Select distinct 
FacilityID,
LocationID,
LocationName
from (
SELECT 
LocationFacility as FacilityID,
LocationID,
--LocationName,
case when LocationID = LocationName then LocationID else rtrim([LocationName]) + ' - ' +  LocationID end as LocationName 

FROM [bluebin].[DimLocation] where BlueBinFlag = 1
UNION ALL 
select distinct LocationFacility as FacilityID,'','--Select--' FROM [bluebin].[DimLocation] where BlueBinFlag = 1
UNION ALL 
select distinct LocationFacility as FacilityID,@MultipleID,@MultipleName FROM [bluebin].[DimLocation] where BlueBinFlag = 1
) as a
order by LocationID
END
GO
grant exec on sp_SelectLocationCascade to appusers
GO

--*****************************************************
--**************************SPROC**********************

if exists (select * from dbo.sysobjects where id = object_id(N'sp_SelectQCN') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_SelectQCN
GO

--select * from qcn.QCN
--exec sp_SelectQCN '%','%','%','0','%'
CREATE PROCEDURE sp_SelectQCN
@FacilityName varchar(50)
,@LocationName varchar(50)
,@QCNStatusName varchar(255)
,@Completed int
,@AssignedUserName varchar(50)

--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON
declare @QCNStatus int = 0
declare @QCNStatus2 int = 0
if @Completed = 0
begin
select @QCNStatus = QCNStatusID from qcn.QCNStatus where Status = 'Completed'
select @QCNStatus2 = QCNStatusID from qcn.QCNStatus where Status = 'Rejected'
end

select 
	q.[QCNID],
	q.FacilityID,
	df.FacilityName,
	q.[LocationID],
    case
		when q.[LocationID] like 'Mult%' then q.LocationID
		else case	when dl.LocationID = dl.LocationName then dl.LocationID
					else rtrim(dl.[LocationName]) + ' - ' +  dl.LocationID end end as LocationName,
	RequesterUserID  as RequesterUserName,
	ApprovedBy as ApprovedBy,
    case when v.UserLogin is null then '' else v.LastName + ', ' + v.FirstName end as AssignedUserName,
        ISNULL(v.[UserLogin],'') as AssignedLogin,
    ISNULL(v.[Title],'') as AssignedTitleName,
	qt.Name as QCNType,
q.[ItemID],
q.ClinicalDescription as ItemClinicalDescription,
q.Par,
q.UOM,
q.ManuNumName,
	q.[Details] as [DetailsText],
            case when q.[Details] ='' then 'No' else 'Yes' end Details,
	q.[Updates] as [UpdatesText],
            case when q.[Updates] ='' then 'No' else 'Yes' end Updates,
	case when qs.Status in ('Rejected','Completed') then convert(int,(q.[DateCompleted] - q.[DateEntered]))
		else convert(int,(getdate() - q.[DateEntered])) end as DaysOpen,
            q.[DateEntered],
	q.[DateCompleted],
	qs.Status,
    q.[LastUpdated],
	q.InternalReference,
	qc.Name as Complexity
from [qcn].[QCN] q
--left join [bluebin].[DimBin] db on q.LocationID = db.LocationID and rtrim(q.ItemID) = rtrim(db.ItemID)
left join [bluebin].[DimItem] di on rtrim(q.ItemID) = rtrim(di.ItemID)
        left join [bluebin].[DimLocation] dl on q.LocationID = dl.LocationID and dl.BlueBinFlag = 1
		left join [bluebin].[DimFacility] df on q.FacilityID = df.FacilityID
left join [bluebin].[BlueBinUser] v on q.AssignedUserID = v.BlueBinUserID
inner join [qcn].[QCNType] qt on q.QCNTypeID = qt.QCNTypeID
inner join [qcn].[QCNStatus] qs on q.QCNStatusID = qs.QCNStatusID
left join qcn.QCNComplexity qc on q.QCNCID = qc.QCNCID

WHERE q.Active = 1 
and df.FacilityName like '%' + @FacilityName + '%'
and (rtrim(dl.[LocationName]) + ' - ' +  dl.LocationID LIKE '%' + @LocationName + '%' or q.LocationID like '%' + @LocationName + '%')
and qs.Status LIKE '%' + @QCNStatusName + '%'
and q.QCNStatusID not in (@QCNStatus,@QCNStatus2)
and case	
		when @AssignedUserName <> '%' then v.LastName + ', ' + v.FirstName else '' end LIKE  '%' + @AssignedUserName + '%' 
            order by q.[DateEntered] asc--,convert(int,(getdate() - q.[DateEntered])) desc

END
GO
grant exec on sp_SelectQCN to appusers
GO

--*****************************************************
--**************************SPROC**********************

if exists (select * from dbo.sysobjects where id = object_id(N'sp_SelectGembaAuditNode') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_SelectGembaAuditNode
GO

--exec sp_SelectGembaAuditNode '%','%','%'

CREATE PROCEDURE sp_SelectGembaAuditNode
@FacilityName varchar(50),
@LocationName varchar(50),
@Auditer varchar(50)

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
    q.AdditionalComments as AdditionalCommentsText,
    case when q.AdditionalComments ='' then 'No' else 'Yes' end [Addtl Comments],
    q.LastUpdated
from [gemba].[GembaAuditNode] q
inner join bluebin.DimFacility df on q.FacilityID = df.FacilityID
inner join [bluebin].[DimLocation] dl on q.LocationID = dl.LocationID and dl.BlueBinFlag = 1
inner join [bluebin].[BlueBinUser] u on q.AuditerUserID = u.BlueBinUserID
    Where q.Active = 1 
	and df.[FacilityName] LIKE '%' + @FacilityName + '%' 
	and rtrim(dl.[LocationName]) + ' - ' +  dl.LocationID LIKE '%' + @LocationName + '%'
	and u.LastName + ', ' + u.FirstName LIKE '%' + @Auditer + '%'
	order by q.Date desc

END
GO
grant exec on sp_SelectGembaAuditNode to appusers
GO













