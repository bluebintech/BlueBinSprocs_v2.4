
if exists (select * from dbo.sysobjects where id = object_id(N'sp_InsertScanLine') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_InsertScanLine
GO

/* 
exec sp_InsertScanLine 1,'0001217','20',1
exec sp_InsertScanLine 1,'0001218','5',2
exec sp_InsertScanLine 1,'0002205','100',3
*/

CREATE PROCEDURE sp_InsertScanLine
@ScanBatchID int,
@Item varchar(30),
@Qty int,
@Line int

--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON

if exists (select * from bluebin.DimItem where ItemID = @Item) 
BEGIN

declare @AutoExtractScans int
select @AutoExtractScans = ConfigValue from bluebin.Config where ConfigName = 'AutoExtractScans'


insert into scan.ScanLine (ScanBatchID,Line,ItemID,Qty,Active,ScanDateTime,Extract)
	select 
	@ScanBatchID,
	@Line,
	@Item,
	@Qty,
	1,--Active Default to Yes
	getdate(),
	@AutoExtractScans --Extract, based on Config value from ConfigName = 'AutoExtractTrayScans'
END
	ELSE
	BEGIN
	SELECT -1 -- Back out scan if there is an issue with the Item existing
	delete from scan.ScanLine where ScanBatchID = @ScanBatchID
	delete from scan.ScanBatch where ScanBatchID = @ScanBatchID
	END

END
GO
grant exec on sp_InsertScanLine to public
GO
