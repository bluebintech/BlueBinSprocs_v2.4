if exists (select * from dbo.sysobjects where id = object_id(N'sp_InsertBlueBinParMaster') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_InsertBlueBinParMaster
GO

--exec sp_InsertBlueBinParMaster '','',''
CREATE PROCEDURE sp_InsertBlueBinParMaster
@FacilityID int
,@LocationID varchar(10)
,@ItemID varchar(32)
,@BinSequence varchar(50)
,@BinUOM varchar(10)
,@BinQuantity int
,@LeadTime int
,@ItemType varchar(10)
,@WHSequence varchar(50)
,@PatientCharge int

--& txtFacilityName & "','" & txtLocationName & "','" & txtItemDescription & "','" & txtItemDescription & "','" & txtBinSequence & "','" & txtBinUOM & "','" & txtBinQuantity & "','" & txtLeadTime & "','" & txtItemType & "','" & txtWHLocationID & "','" & txtWHSequence & "','" & txtPatientCharge & "'"
--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON
if not exists(select * from [bluebin].[BlueBinParMaster] WHERE rtrim(LocationID) = rtrim(@LocationID) and rtrim(ItemID) = rtrim(@ItemID) and FacilityID = @FacilityID)
BEGIN

declare @BinSize varchar(5) = right(@BinSequence,3)
insert [bluebin].[BlueBinParMaster] (FacilityID,LocationID,ItemID,BinSequence,BinSize,BinUOM,BinQuantity,LeadTime,ItemType,WHLocationID,WHSequence,PatientCharge,Updated,LastUpdated)
VALUES(
@FacilityID,
@LocationID,
@ItemID,
@BinSequence,
@BinSize,
@BinUOM,
@BinQuantity,
@LeadTime,
@ItemType,
'',
@WHSequence,
@PatientCharge,
0,
getdate()

) 
END


END
GO
grant exec on sp_InsertBlueBinParMaster to appusers
GO