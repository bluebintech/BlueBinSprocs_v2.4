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
		when q.[LocationID] = 'Multiple' then q.LocationID
		else case	when dl.LocationID = dl.LocationName then dl.LocationID
					else dl.LocationID + ' - ' + dl.[LocationName] end end as LocationName,
	RequesterUserID  as RequesterUserName,
	ApprovedBy as ApprovedBy,
    case when v.UserLogin is null then '' else v.LastName + ', ' + v.FirstName end as AssignedUserName,
        ISNULL(v.[UserLogin],'') as AssignedLogin,
    ISNULL(v.[Title],'') as AssignedTitleName,
	qt.Name as QCNType,
q.[ItemID],
COALESCE(di.ItemClinicalDescription,di.ItemDescription,'No Description') as ItemClinicalDescription,
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
and (dl.LocationID + ' - ' + dl.[LocationName] LIKE '%' + @LocationName + '%' or q.LocationID like '%' + @LocationName + '%')
and qs.Status LIKE '%' + @QCNStatusName + '%'
and q.QCNStatusID not in (@QCNStatus,@QCNStatus2)
and case	
		when @AssignedUserName <> '%' then v.LastName + ', ' + v.FirstName else '' end LIKE  '%' + @AssignedUserName + '%' 
            order by q.[DateEntered] asc--,convert(int,(getdate() - q.[DateEntered])) desc

END
GO
grant exec on sp_SelectQCN to appusers
GO



