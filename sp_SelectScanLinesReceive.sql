
if exists (select * from dbo.sysobjects where id = object_id(N'sp_SelectScanLinesReceive') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_SelectScanLinesReceive
GO

--exec sp_SelectScanLinesReceive 1

/*
select * from scan.ScanMatch
select * from scan.ScanLine where ScanLineID = 25


*/
CREATE PROCEDURE sp_SelectScanLinesReceive
@ScanBatchID int

--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON
select 
sbr.ScanBatchID,
db.BinKey,
db.BinSequence,
rtrim(sbr.LocationID) as LocationID,
dl.LocationName as LocationName,
slr.ItemID,
di.ItemDescription,
slr.Qty,
slo.Line,
sbr.ScanDateTime as [DateScanned],
bbu.LastName + ', ' + bbu.FirstName as ScannedBy

from scan.ScanMatch sm
inner join scan.ScanLine slr on sm.ScanLineReceiveID = slr.ScanLineID
inner join scan.ScanLine slo on sm.ScanLineOrderID = slo.ScanLineID
inner join scan.ScanBatch sbr on slr.ScanBatchID = sbr.ScanBatchID 
inner join scan.ScanBatch sbo on slo.ScanBatchID = sbo.ScanBatchID 
inner join bluebin.DimBin db on sbr.LocationID = db.LocationID and slr.ItemID = db.ItemID
inner join bluebin.DimItem di on slr.ItemID = di.ItemID
inner join bluebin.DimLocation dl on sbr.LocationID = dl.LocationID
inner join bluebin.BlueBinUser bbu on sbr.BlueBinUserID = bbu.BlueBinUserID
 
where slo.ScanBatchID = @ScanBatchID and slo.Active = 1
order by slo.Line

--11 --

END
GO
grant exec on sp_SelectScanLinesReceive to public
GO


