if exists (select * from dbo.sysobjects where id = object_id(N'sp_CleanLawsonTables') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_CleanLawsonTables
GO

--exec sp_CleanLawsonTables

CREATE PROCEDURE sp_CleanLawsonTables
--WITH ENCRYPTION
AS
BEGIN

if exists (select * from sys.tables where name = 'APCOMPANY')
BEGIN
truncate table dbo.APCOMPANY
END

if exists (select * from sys.tables where name = 'APVENMAST')
BEGIN
truncate table dbo.APVENMAST
END

if exists (select * from sys.tables where name = 'BUYER')
BEGIN
truncate table dbo.BUYER
END

if exists (select * from sys.tables where name = 'GLCHARTDTL')
BEGIN
truncate table dbo.GLCHARTDTL
END

if exists (select * from sys.tables where name = 'GLNAMES')
BEGIN
truncate table dbo.GLNAMES
END

if exists (select * from sys.tables where name = 'GLTRANS')
BEGIN
truncate table dbo.GLTRANS
END

if exists (select * from sys.tables where name = 'ICCATEGORY')
BEGIN
truncate table dbo.ICCATEGORY
END

if exists (select * from sys.tables where name = 'ICMANFCODE')
BEGIN
truncate table dbo.ICMANFCODE
END

if exists (select * from sys.tables where name = 'ICLOCATION')
BEGIN
truncate table dbo.ICLOCATION
END

if exists (select * from sys.tables where name = 'ICTRANS')
BEGIN
truncate table dbo.ICTRANS
END

if exists (select * from sys.tables where name = 'ITEMLOC')
BEGIN
truncate table dbo.ITEMLOC
END

if exists (select * from sys.tables where name = 'ITEMMAST')
BEGIN
truncate table dbo.ITEMMAST
END

if exists (select * from sys.tables where name = 'ITEMSRC')
BEGIN
truncate table dbo.ITEMSRC
END

if exists (select * from sys.tables where name = 'MAINVDTL')
BEGIN
truncate table dbo.MAINVDTL
END

if exists (select * from sys.tables where name = 'MAINVMSG')
BEGIN
truncate table dbo.MAINVMSG
END

if exists (select * from sys.tables where name = 'MMDIST')
BEGIN
truncate table dbo.MMDIST
END

if exists (select * from sys.tables where name = 'POCODE')
BEGIN
truncate table dbo.POCODE
END

if exists (select * from sys.tables where name = 'POLINE')
BEGIN
truncate table dbo.POLINE
END

if exists (select * from sys.tables where name = 'POLINESRC')
BEGIN
truncate table dbo.POLINESRC
END

if exists (select * from sys.tables where name = 'PORECLINE')
BEGIN
truncate table dbo.PORECLINE
END

if exists (select * from sys.tables where name = 'POVAGRMTLN')
BEGIN
truncate table dbo.POVAGRMTLN
END

if exists (select * from sys.tables where name = 'PURCHORDER')
BEGIN
truncate table dbo.PURCHORDER
END

if exists (select * from sys.tables where name = 'REQHEADER')
BEGIN
truncate table dbo.REQHEADER
END

if exists (select * from sys.tables where name = 'REQLINE')
BEGIN
truncate table dbo.REQLINE
END

if exists (select * from sys.tables where name = 'REQUESTER')
BEGIN
truncate table dbo.REQUESTER
END

if exists (select * from sys.tables where name = 'RQLOC')
BEGIN
truncate table dbo.RQLOC
END

if exists (select * from sys.tables where name = 'RQLMXVAL')
BEGIN
truncate table dbo.RQLMXVAL
END

END

GO
grant exec on sp_CleanLawsonTables to public
GO



