
if exists (select * from dbo.sysobjects where id = object_id(N'sp_InsertScanLineReceive') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_InsertScanLineReceive
GO

/* 
exec sp_InsertScanBatch 'BB013','gbutler@bluebin.com','Receive'
exec sp_InsertScanLineReceive 17,'0000014','1'
exec sp_InsertScanLineReceive 17,'0000017','1'
exec sp_InsertScanLineReceive 16,'0000018','1'

select * from scan.ScanLine where Line = 0
select * from scan.ScanMatch
delete from scan.ScanLine where ScanBatchID in (select ScanBatchID from scan.ScanBatch where ScanType = 'Receive')
*/

CREATE PROCEDURE sp_InsertScanLineReceive
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
declare @ScanMatchLocationID varchar(10) 
declare @ScanMatchFacilityID int 
declare @ScanMatchItemID varchar(32) = @Item
declare @ScanMatchScanLineOrderID int
declare @ScanMatchScanLineReceiveID int
declare @ScanMatch table (ScanBatchID int,ScanLineOrderID int,FaciltyID int,LocationID varchar(7),ItemID varchar(32),Qty int)

select @ScanMatchFacilityID = FacilityID from scan.ScanBatch where ScanBatchID = @ScanBatchID
select @ScanMatchLocationID = LocationID from scan.ScanBatch where ScanBatchID = @ScanBatchID
select @ScanMatchScanLineOrderID = 
min(ScanLineID)
from scan.ScanBatch sb
inner join scan.ScanLine sl on sb.ScanBatchID = sl.ScanBatchID
where
sb.FacilityID = @ScanMatchFacilityID and
sb.LocationID = @ScanMatchLocationID and
sl.ItemID = @Item and 
sb.ScanType like '%Order' and
sl.ScanLineID not in (select ScanLineOrderID from scan.ScanMatch)

		if @ScanMatchScanLineOrderID is not null 
		BEGIN
		insert into scan.ScanLine (ScanBatchID,Line,ItemID,Qty,Active,ScanDateTime,Extract)
			select 
			@ScanBatchID,
			0,--Default Received Line to 0 for identification purposes
			@Item,
			@Qty,
			1,--Active Default to Yes
			getdate(),
			0 --Extract default to No, will not extract this.

		set @ScanMatchScanLineReceiveID = SCOPE_IDENTITY()

		insert into scan.ScanMatch (ScanLineOrderID,ScanLineReceiveID,Qty,ScanDateTime) VALUES
		(@ScanMatchScanLineOrderID,@ScanMatchScanLineReceiveID,@Qty,getdate())
		END
			ELSE
			BEGIN
			SELECT -2 -- Backout if there is no existing item waiting to be scanned in
			delete from scan.ScanMatch where ScanLineReceiveID in (select ScanLineID from scan.ScanLine where ScanBatchID = @ScanBatchID)
			delete from scan.ScanLine where ScanBatchID = @ScanBatchID
			delete from scan.ScanBatch where ScanBatchID = @ScanBatchID
			END

END
	ELSE
	BEGIN
	SELECT -1 -- Back out scan if there is an issue with the Item existing
	delete from scan.ScanLine where ScanBatchID = @ScanBatchID
	delete from scan.ScanBatch where ScanBatchID = @ScanBatchID
	END

END
GO
grant exec on sp_InsertScanLineReceive to public
GO


