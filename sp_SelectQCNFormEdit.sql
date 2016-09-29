if exists (select * from dbo.sysobjects where id = object_id(N'sp_SelectQCNFormEdit') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_SelectQCNFormEdit
GO

--exec sp_SelectQCNFormEdit '270'

CREATE PROCEDURE sp_SelectQCNFormEdit
@QCNID int

--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON
SELECT 
	[QCNID]
	,rtrim([LocationID]) as LocationID
	,a.FacilityID
	,rtrim(a.ItemID) as ItemID
	,a.ClinicalDescription
	,a.[Sequence]
	,RequesterUserID as RequesterUser
	,ApprovedBy
	,a.[AssignedUserID] as AssignedUser
	,a.QCNCID as QCNComplexity
	,qt.Name as QCNType
	,[Details]
	,[Updates]
	,convert(varchar,a.[DateRequested],101) as [DateRequested]
	,convert(varchar,a.[DateEntered],101) as [DateEntered]
	,convert(varchar,a.[DateCompleted],101) as [DateCompleted]
	,qs.Status as QCNStatus
	,convert(varchar,a.[LastUpdated],101) as [LastUpdated]
	,InternalReference
	,ManuNumName
	,bbu.LastName + ', ' + bbu.FirstName + ' (' + bbu.UserLogin + ')' as [LoggedByUser]
	,Par
	,UOM
		FROM [qcn].[QCN] a 
		inner join bluebin.BlueBinUser bbu on a.LoggedUserID = bbu.BlueBinUserID
			left join bluebin.BlueBinUser b2 on a.[AssignedUserID] = b2.BlueBinUserID
			left join qcn.QCNStatus qs on a.[QCNStatusID] = qs.[QCNStatusID]
			left join qcn.QCNType qt on a.[QCNTypeID] = qt.[QCNTypeID]
			left join qcn.QCNComplexity qc on a.[QCNCID] = qc.[QCNCID]
		where a.QCNID=@QCNID

END
GO
grant exec on sp_SelectQCNFormEdit to appusers
GO

