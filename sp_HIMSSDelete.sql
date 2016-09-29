
if exists (select * from dbo.sysobjects where id = object_id(N'sp_HIMSSDelete') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_HIMSSDelete
GO


--exec sp_HIMSSDelete

CREATE PROCEDURE sp_HIMSSDelete


--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON
delete from scan.ScanLine where ScanDate > getdate() - 1
delete from scan.ScanBatch where ScanDate > getdate() - 1

END
GO
grant exec on sp_InsertScanBatch to public
GO

