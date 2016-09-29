if exists (select * from dbo.sysobjects where id = object_id(N'sp_InsertQCN') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_InsertQCN
GO

--exec sp_InsertQCN 

CREATE PROCEDURE sp_InsertQCN
@DateRequested datetime,
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
@UserLogin varchar (60),
@InternalReference varchar(50),
@ManuNumName varchar(60),
@Par int,
@UOM varchar(10)


--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON
set @UserLogin = LOWER(@UserLogin)
Declare @QCNID int, @LoggedUserID int
set @LoggedUserID = (select BlueBinUserID from bluebin.BlueBinUser where LOWER(UserLogin) = LOWER(@UserLogin))

insert into [qcn].[QCN] 
(FacilityID,
[LocationID],
	[ItemID],
		[ClinicalDescription],
		[Sequence],
		[RequesterUserID],
		[ApprovedBy],
			[AssignedUserID],
				[QCNCID],
				[QCNTypeID],
					[Details],
						[Updates],
							[DateRequested],
							[DateEntered],
								[DateCompleted],
									[QCNStatusID],
										[Active],
											[LastUpdated],
												[InternalReference],
												ManuNumName,
													[LoggedUserID],
													Par,
													UOM)

select 
@FacilityID,
@LocationID,
case when @ItemID = '' then NULL else @ItemID end,
@ClinicalDescription,
@Sequence,
@Requester,
@ApprovedBy,
case when @Assigned = '' then NULL else @Assigned end,
@QCNComplexity,
(select max([QCNTypeID]) from [qcn].[QCNType] where [Name] = @QCNType),
@Details,
@Updates,
@DateRequested,
getdate(),
Case when @QCNStatus in('Rejected','Completed') then getdate() else NULL end,
(select max([QCNStatusID]) from [qcn].[QCNStatus] where [Status] = @QCNStatus),
1, --Active
getdate(), --LastUpdated
@InternalReference,
@ManuNumName,
@LoggedUserID,
@Par,
@UOM


SET @QCNID = SCOPE_IDENTITY()
	exec sp_InsertMasterLog @UserLogin,'QCN','Submit QCN Form',@QCNID

END

GO
grant exec on sp_InsertQCN to appusers
GO