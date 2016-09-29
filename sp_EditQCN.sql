if exists (select * from dbo.sysobjects where id = object_id(N'sp_EditQCN') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_EditQCN
GO

--exec sp_EditQCN 

CREATE PROCEDURE sp_EditQCN
@QCNID int,
@FacilityID int,
@LocationID varchar(10),
@ItemID varchar(32),
@ClinicalDescription varchar(30),
@Sequence varchar(30),
@Requester varchar(255),
@ApprovedBy varchar(255),
@Assigned int,
@QCNComplexity varchar(255),
@QCNType varchar(255),
@Details varchar(max),
@Updates varchar(max),
@QCNStatus varchar(255),
@InternalReference varchar(50),
@ManuNumName varchar(60),
@Par int,
@UOM varchar(10)


--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON
	
update [qcn].[QCN] set
FacilityID = @FacilityID,
[LocationID] = @LocationID,
[ItemID] = @ItemID,
ClinicalDescription = @ClinicalDescription,
[Sequence] = @Sequence,
[RequesterUserID] = @Requester,
ApprovedBy = @ApprovedBy,
[AssignedUserID] = @Assigned,
[QCNCID] =  @QCNComplexity,
[QCNTypeID] = (select max([QCNTypeID]) from [qcn].[QCNType] where [Name] = @QCNType),
[Details] = @Details,
[Updates] = @Updates,
[DateCompleted] = Case when @QCNStatus in ('Rejected','Completed') and DateCompleted is null then getdate() 
                        when @QCNStatus in ('Rejected','Completed') and DateCompleted is not null then DateCompleted
                            else NULL end,
[QCNStatusID] = (select max([QCNStatusID]) from [qcn].[QCNStatus] where [Status] = @QCNStatus),
[LastUpdated] = getdate(),
InternalReference = @InternalReference,
ManuNumName = @ManuNumName,
Par = @Par,
UOM = @UOM
WHERE QCNID = @QCNID



END

GO
grant exec on sp_EditQCN to appusers
GO
