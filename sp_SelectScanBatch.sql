
if exists (select * from dbo.sysobjects where id = object_id(N'sp_SelectScanBatch') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_SelectScanBatch
GO

--exec sp_SelectScanBatch '','',''

CREATE PROCEDURE sp_SelectScanBatch
@ScanDate varchar(20),
@Facility varchar(50),
@Location varchar(50)

--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON


select @ScanDate = case when @ScanDate = 'Today' then convert(varchar,(convert(Date,getdate())),111) else @ScanDate end

select 
sb.ScanBatchID,
rtrim(df.FacilityID) as FacilityID,
df.FacilityName as FacilityName,
rtrim(sb.LocationID) as LocationID,
dl.LocationName as LocationName,
max(sl.Line) as BinsScanned,
sb.ScanDateTime as [DateScanned],
--convert(Date,sb.ScanDateTime) as ScanDate,
bbu.LastName + ', ' + bbu.FirstName as ScannedBy,
case when sb.ScanType like '%Tray%' then 'Tray' else 'Scan' end as Origin,
case when max(sl.Line) - isnull(sm3.Ct,0) > 0 then  
		case when sm3.Ct > 1 then 'Partial' else 'No' end
	 else 'Yes' end as Extracted,
case when max(sl.Line) - isnull(sm2.Ct,0) > 0 then 
		case when sm2.Ct > 1 then 'Partial' else 'No' end 
	 else 'Yes' end as [Matched]

from scan.ScanBatch sb
inner join bluebin.DimLocation dl on sb.LocationID = dl.LocationID
inner join bluebin.DimFacility df on sb.FacilityID = df.FacilityID
inner join scan.ScanLine sl on sb.ScanBatchID = sl.ScanBatchID
left join bluebin.BlueBinUser bbu on sb.BlueBinUserID = bbu.BlueBinUserID
left join
	(select sl2.ScanBatchID,count(*) as Ct from scan.ScanMatch sm1 
		inner join scan.ScanLine sl2 on sm1.ScanLineOrderID = sl2.ScanLineID group by sl2.ScanBatchID) sm2 on sb.ScanBatchID = sm2.ScanBatchID
left join
	(select sl3.ScanBatchID,count(*) as Ct from scan.ScanExtract se1 
		inner join scan.ScanLine sl3 on se1.ScanLineID = sl3.ScanLineID group by sl3.ScanBatchID) sm3 on sb.ScanBatchID = sm3.ScanBatchID
where sb.Active = 1 and ScanType like '%Order' 
and convert(varchar,(convert(Date,sb.ScanDateTime)),111) LIKE '%' + @ScanDate + '%'  
--and convert(varchar(4),df.FacilityID) +' - '+ df.FacilityName like '%' + @Facility + '%' 
and sb.FacilityID like '%' + @Facility + '%' 
and sb.LocationID like '%' + @Location + '%'

group by 
sb.ScanBatchID,
df.FacilityID,
df.FacilityName,
sb.LocationID,
dl.LocationName,
sb.ScanDateTime,
bbu.LastName + ', ' + bbu.FirstName,
case when sb.ScanType like '%Tray%' then 'Tray' else 'Scan' end,
sm2.Ct,
sm3.Ct
order by sb.ScanDateTime desc

END
GO
grant exec on sp_SelectScanBatch to public
GO



