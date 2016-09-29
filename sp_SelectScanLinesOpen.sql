
if exists (select * from dbo.sysobjects where id = object_id(N'sp_SelectScanLinesOpen') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_SelectScanLinesOpen
GO

--exec sp_SelectScanLinesOpen '','',''

CREATE PROCEDURE sp_SelectScanLinesOpen
@ScanDate varchar(20),
@Facility varchar(50),
@Location varchar(50)


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
sl.Qty,
sl.Line,
sb.ScanDateTime as [DateScanned],
case when se.ScanLineID is not null then 'Yes' else 'No' end as Extracted,
convert(int,(getdate() - sb.ScanDateTime)) as DaysOpen

from scan.ScanLine sl
inner join scan.ScanBatch sb on sl.ScanBatchID = sb.ScanBatchID
inner join bluebin.DimBin db on sb.LocationID = db.LocationID and sl.ItemID = db.ItemID
inner join bluebin.DimItem di on sl.ItemID = di.ItemID
inner join bluebin.DimLocation dl on sb.LocationID = dl.LocationID
inner join bluebin.DimFacility df on sb.FacilityID = df.FacilityID
left join (select distinct ScanLineID from scan.ScanExtract) se on sl.ScanLineID = se.ScanLineID
where sl.Active = 1 and sb.ScanType like '%Order' 

and sl.ScanLineID not in (select ScanLineOrderID from scan.ScanMatch)
and convert(varchar,(convert(Date,sb.ScanDateTime)),111) LIKE '%' + @ScanDate + '%'  
and sb.FacilityID like '%' + @Facility + '%' 
and sb.LocationID like '%' + @Location + '%'
order by DateScanned,LocationID,Line

END
GO
grant exec on sp_SelectScanLinesOpen to public
GO
