
if exists (select * from dbo.sysobjects where id = object_id(N'sp_SelectScanLines') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_SelectScanLines
GO

--exec sp_SelectScanLines 38  select * from scan.ScanBatch

CREATE PROCEDURE sp_SelectScanLines
@ScanBatchID int

--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON
select 
sb.ScanBatchID,
db.BinKey,
db.BinSequence,
rtrim(sb.LocationID) as LocationID,
dl.LocationName as LocationName,
sl.ItemID,
di.ItemDescription,
sl.Bin,
sl.Qty,
sl.Line,
sb.ScanDateTime as [DateScanned],
bbu.LastName + ', ' + bbu.FirstName as ScannedBy,
case when sb.ScanType like '%Tray%' then 'Tray' else 'Scan' end as Origin,
sl.Extract,
case when se.ScanLineID is not null then 'Yes' else 'No' end as Extracted

from scan.ScanLine sl
inner join scan.ScanBatch sb on sl.ScanBatchID = sb.ScanBatchID
inner join bluebin.DimBin db on sb.LocationID = db.LocationID and sl.ItemID = db.ItemID
inner join bluebin.DimItem di on sl.ItemID = di.ItemID
inner join bluebin.DimLocation dl on sb.LocationID = dl.LocationID
left join bluebin.BlueBinUser bbu on sb.BlueBinUserID = bbu.BlueBinUserID
left join (select distinct ScanLineID from scan.ScanExtract) se on sl.ScanLineID = se.ScanLineID
where sl.ScanBatchID = @ScanBatchID and sl.Active = 1 and sb.ScanType like '%Order'
order by sl.Line


END
GO
grant exec on sp_SelectScanLines to public
GO
