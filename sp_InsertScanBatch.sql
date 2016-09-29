
if exists (select * from dbo.sysobjects where id = object_id(N'sp_InsertScanBatch') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_InsertScanBatch
GO

/*
declare @Location char(5),@Scanner varchar(255) = 'gbutler@bluebin.com'
select @Location = LocationID from bluebin.DimLocation where LocationName = 'DN NICU 1'
exec sp_InsertScanBatch 'BB013','gbutler@bluebin.com','Order'
exec sp_InsertScanBatch 'BB013','gbutler@bluebin.com','Receive'
*/

CREATE PROCEDURE sp_InsertScanBatch
@Location varchar(10),
@Scanner varchar(255),
@ScanType varchar(50)


--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON
declare @FacilityID int, @AutoExtractScans int
select @AutoExtractScans = ConfigValue from bluebin.Config where ConfigName = 'AutoExtractScans'
select @FacilityID = max(LocationFacility) from bluebin.DimLocation where rtrim(LocationID) = rtrim(@Location)--Only grab one FacilityID or else bad things will happen

insert into scan.ScanBatch (FacilityID,LocationID,BlueBinUserID,Active,ScanDateTime,Extract,ScanType)
select 
@FacilityID,
@Location,
(select BlueBinUserID from bluebin.BlueBinUser where LOWER(UserLogin) = LOWER(@Scanner)),
1, --Default Active to Yes
getdate(),
@AutoExtractScans, --Default Extract to value from ,
@ScanType

Declare @ScanBatchID int  = SCOPE_IDENTITY()

if @ScanType = 'ScanOrder'
BEGIN
exec sp_InsertMasterLog @Scanner,'Scan','New Scan Batch OrderEntered',@ScanBatchID
END ELSE
BEGIN
exec sp_InsertMasterLog @Scanner,'Scan','New Scan Batch Receipt Entered',@ScanBatchID
END

Select @ScanBatchID

END
GO
grant exec on sp_InsertScanBatch to public
GO

