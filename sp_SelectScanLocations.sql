
if exists (select * from dbo.sysobjects where id = object_id(N'sp_SelectScanLocations') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_SelectScanLocations
GO

--exec sp_SelectScanLocations 
CREATE PROCEDURE sp_SelectScanLocations


--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON

SELECT DISTINCT 
convert(varchar(7),dl.LocationID) +' - '+ dl.LocationName as LocationLongName,
sb.LocationID
from scan.ScanBatch sb
inner join bluebin.DimLocation dl on sb.LocationID = dl.LocationID
WHERE Active = 1 --and convert(Date,ScanDateTime) = @ScanDate 
order by sb.LocationID asc

END 
GO
grant exec on sp_SelectScanLocations to public
GO