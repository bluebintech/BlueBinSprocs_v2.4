
if exists (select * from dbo.sysobjects where id = object_id(N'sp_SelectScanDates') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_SelectScanDates
GO

--exec sp_SelectScanDates ''
CREATE PROCEDURE sp_SelectScanDates


--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON

SELECT DISTINCT 
convert(varchar,(convert(Date,ScanDateTime)),111) as ScanDate
from scan.ScanBatch
WHERE Active = 1 and ScanType = 'Order'--and convert(Date,ScanDateTime) = @ScanDate 
order by 1 desc

END 
GO
grant exec on sp_SelectScanDates to public
GO