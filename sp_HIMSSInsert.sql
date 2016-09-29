
if exists (select * from dbo.sysobjects where id = object_id(N'sp_HIMSSInsert') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_HIMSSInsert
GO

/*
exec sp_HIMSSInsert 'BB001','chodge@bluebin.com'
exec sp_HIMSSInsert 'BB001','rswan@bluebin.com'
exec sp_HIMSSInsert 'BB001','gbutler@bluebin.com'
*/

CREATE PROCEDURE sp_HIMSSInsert
@Location char(10),
@Scanner varchar(255)


--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON
declare @FacilityID int
select @FacilityID = max(LocationFacility) from bluebin.DimLocation where rtrim(LocationID) = rtrim(@Location)--Only grab one FacilityID or else bad things will happen

insert into scan.ScanBatch (FacilityID,LocationID,BlueBinUserID,Active,ScanDateTime,Extracted,ScanType)
select 
@FacilityID,
@Location,
(select BlueBinUserID from bluebin.BlueBinUser where LOWER(UserLogin) = LOWER(@Scanner)),
1, --Default Active to Yes
getdate(),
0, --Default Extracted to No
'TrayOrder' --Default to TrayOrder for demo purposes

Declare @ScanBatchID int  = SCOPE_IDENTITY()

exec sp_InsertScanLine @ScanBatchID,'0001217','20',1
exec sp_InsertScanLine @ScanBatchID,'0001218','5',2
exec sp_InsertScanLine @ScanBatchID,'0002205','100',3

END
GO
grant exec on sp_HIMSSInsert to public
GO

