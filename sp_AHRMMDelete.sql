
if exists (select * from dbo.sysobjects where id = object_id(N'sp_AHRMMDelete') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_AHRMMDelete
GO

CREATE PROCEDURE sp_AHRMMDelete

--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON
delete from scan.ScanLine where ScanBatchID in (select ScanBatchID from scan.ScanBatch where ScanType = 'TrayOrder' and ScanDateTime > getdate() -.25) 
delete from scan.ScanBatch where ScanType = 'TrayOrder' and ScanDateTime > getdate() -.25

END
GO
grant exec on sp_AHRMMDelete to public
GO




