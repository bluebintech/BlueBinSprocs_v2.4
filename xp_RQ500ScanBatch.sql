if exists (select * from dbo.sysobjects where id = object_id(N'xp_RQ500ScanBatch') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure xp_RQ500ScanBatch
GO

--exec tb_ItemLocator

CREATE PROCEDURE xp_RQ500ScanBatch

--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON

if exists(select * from scan.ScanBatch where Extracted = 0)
BEGIN
GOTO THEEND
END

declare @ScanBatchID int 
select @ScanBatchID = min(ScanBatchID) from scan.ScanBatch where Active = 1 and Extracted = 0



END
THEEND:
select * from scan.ScanBatch
select * from scan.ScanLine
select * from bluebin.DimLocation

END
GO
grant exec on xp_RQ500ScanBatch to BlueBin_RQ500User
GO