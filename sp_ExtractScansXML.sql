if exists (select * from dbo.sysobjects where id = object_id(N'sp_ExtractScansXML') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_ExtractScansXML
GO

--exec sp_ExtractScansXML

CREATE PROCEDURE sp_ExtractScansXML

--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON

select
sb.ScanBatchID as '@ID',
ltrim(rtrim(sb.LocationID)) as LocationID,
sl.Line as Line,
ltrim(rtrim(sl.ItemID)) as ItemID,
sl.Qty as Qty,
sb.ScanDateTime as ScanDateTime
from 
scan.ScanBatch sb
inner join scan.ScanLine sl on sb.ScanBatchID = sl.ScanBatchID
where sl.Extract = 1

FOR XML PATH('ScanBatch'), ROOT('Scans')

END
GO
grant exec on sp_ExtractScansXML to appusers
GO
