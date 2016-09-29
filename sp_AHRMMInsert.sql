
if exists (select * from dbo.sysobjects where id = object_id(N'sp_AHRMMInsert') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_AHRMMInsert
GO


/*
exec sp_AHRMMInsert 6,'BB001','0008673','A','1'
exec sp_AHRMMInsert 6,'BB001','0008675','A','2'
exec sp_AHRMMInsert 6,'BB001','0008720','A','1'
exec sp_AHRMMInsert 6,'BB001','0008776','A','12'
exec sp_AHRMMInsert 6,'BB001','0008673','B','1'
exec sp_AHRMMDelete
select * from scan.ScanBatch where ScanType = 'TrayOrder'
select * from scan.ScanLine where ScanBatchID in (select ScanBatchID from scan.ScanBatch where ScanType = 'TrayOrder')
select * from scan.ScanBatch where Extract = 1
select * from scan.ScanLine where Extract = 1
delete from scan.ScanLine where ScanBatchID in (select ScanBatchID from scan.ScanBatch where ScanType = 'TrayOrder')
delete from scan.ScanBatch where ScanType = 'TrayOrder'
*/

CREATE PROCEDURE sp_AHRMMInsert
@FacilityID int,
@Location char(10),
@Item varchar(30),
@Bin varchar(2),
@Qty int

--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON
declare @ScanBatchID int, @Line int, @AutoExtractTrayScans int
select @AutoExtractTrayScans = ConfigValue from bluebin.Config where ConfigName = 'AutoExtractTrayScans'
select @Bin = case when @Bin = 'A' or @Bin = '1' then 'A' else 'B' end

if not exists (select * from scan.ScanBatch where ScanType = 'TrayOrder' and FacilityID = @FacilityID and LocationID = @Location and convert(varchar,(convert(Date,ScanDateTime)),111) = convert(varchar,(convert(Date,getdate())),111))
BEGIN
	insert into scan.ScanBatch (FacilityID,LocationID,BlueBinUserID,Active,ScanDateTime,Extract,ScanType)
	select 
	@FacilityID,
	@Location,
	NULL,
	1, --Default Active to Yes
	getdate(),
	@AutoExtractTrayScans, --Default Extract the value of AutoExtractTrayScans.  If that value is yes, Extract = 1, else it will only do it when someone flags it ready
	'TrayOrder' --Default to TrayOrder for demo purposes

	set @ScanBatchID = SCOPE_IDENTITY()
	set @Line = 1

	if not exists (select * from scan.ScanLine where ScanBatchID = @ScanBatchID and ItemID = @Item and Bin = @Bin)
		BEGIN
		insert into scan.ScanLine (ScanBatchID,Line,ItemID,Bin,Qty,Active,ScanDateTime,Extract)
			select 
			@ScanBatchID,
			@Line,
			@Item,
			@Bin,
			@Qty,
			1,--Active Default to Yes
			getdate(),
			@AutoExtractTrayScans --Default Extract the value of AutoExtractTrayScans.  If that value is yes, Extract = 1, else it will only do it when someone flags it ready
	END

	GOTO THEEND
END
ELSE

	select @ScanBatchID = ScanBatchID from scan.ScanBatch where ScanType = 'TrayOrder' and FacilityID = @FacilityID and LocationID = @Location and convert(varchar,(convert(Date,ScanDateTime)),111) = convert(varchar,(convert(Date,getdate())),111)
	select @Line = max(Line) + 1 from scan.ScanLine where ScanBatchID = @ScanBatchID

	if not exists (select * from scan.ScanLine where ScanBatchID = @ScanBatchID and ItemID = @Item and Bin = @Bin)
		BEGIN
		insert into scan.ScanLine (ScanBatchID,Line,ItemID,Bin,Qty,Active,ScanDateTime,Extract)
			select 
			@ScanBatchID,
			@Line,
			@Item,
			@Bin,
			@Qty,
			1,--Active Default to Yes
			getdate(),
			@AutoExtractTrayScans --Default Extract the value of AutoExtractTrayScans.  If that value is yes, Extract = 1, else it will only do it when someone flags it ready
		END


THEEND:
END
GO
grant exec on sp_AHRMMInsert to public
GO




