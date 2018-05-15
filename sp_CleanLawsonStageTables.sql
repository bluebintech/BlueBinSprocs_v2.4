--*****************************************************
--**************************SPROC**********************

if exists (select * from dbo.sysobjects where id = object_id(N'sp_CleanLawsonStageTables') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_CleanLawsonStageTables
GO

--exec sp_CleanLawsonStageTables

CREATE PROCEDURE sp_CleanLawsonStageTables
--WITH ENCRYPTION
AS
BEGIN


--*****************Remove Stage Tables Data**************************
if exists (select * from sys.tables where name = 'APCOMPANYstage')
BEGIN
truncate table dbo.APCOMPANYstage
END

if exists (select * from sys.tables where name = 'APVENMASTstage')
BEGIN
truncate table dbo.APVENMASTstage
END

if exists (select * from sys.tables where name = 'BUYERstage')
BEGIN
truncate table dbo.BUYERstage
END

if exists (select * from sys.tables where name = 'GLCHARTDTLstage')
BEGIN
truncate table dbo.GLCHARTDTLstage
END

if exists (select * from sys.tables where name = 'GLNAMESstage')
BEGIN
truncate table dbo.GLNAMESstage
END

if exists (select * from sys.tables where name = 'GLTRANSstage')
BEGIN
truncate table dbo.GLTRANSstage
END

if exists (select * from sys.tables where name = 'ICCATEGORYstage')
BEGIN
truncate table dbo.ICCATEGORYstage
END

if exists (select * from sys.tables where name = 'ICMANFCODEstage')
BEGIN
truncate table dbo.ICMANFCODEstage
END

if exists (select * from sys.tables where name = 'ICLOCATIONstage')
BEGIN
truncate table dbo.ICLOCATIONstage
END

if exists (select * from sys.tables where name = 'ICTRANSstage')
BEGIN
truncate table dbo.ICTRANSstage
END

if exists (select * from sys.tables where name = 'ITEMLOCstage')
BEGIN
truncate table dbo.ITEMLOCstage
END

if exists (select * from sys.tables where name = 'ITEMMASTstage')
BEGIN
truncate table dbo.ITEMMASTstage
END

if exists (select * from sys.tables where name = 'ITEMSRCstage')
BEGIN
truncate table dbo.ITEMSRCstage
END

if exists (select * from sys.tables where name = 'MAINVDTLstage')
BEGIN
truncate table dbo.MAINVDTLstage
END

if exists (select * from sys.tables where name = 'MAINVMSGstage')
BEGIN
truncate table dbo.MAINVMSGstage
END

if exists (select * from sys.tables where name = 'MMDISTstage')
BEGIN
truncate table dbo.MMDISTstage
END

if exists (select * from sys.tables where name = 'POCODEstage')
BEGIN
truncate table dbo.POCODEstage
END

if exists (select * from sys.tables where name = 'POLINEstage')
BEGIN
truncate table dbo.POLINEstage
END

if exists (select * from sys.tables where name = 'POLINESRCstage')
BEGIN
truncate table dbo.POLINESRCstage
END

if exists (select * from sys.tables where name = 'PORECLINEstage')
BEGIN
truncate table dbo.PORECLINEstage
END

if exists (select * from sys.tables where name = 'POVAGRMTLNstage')
BEGIN
truncate table dbo.POVAGRMTLNstage
END

if exists (select * from sys.tables where name = 'PURCHORDERstage')
BEGIN
truncate table dbo.PURCHORDERstage
END

if exists (select * from sys.tables where name = 'REQHEADERstage')
BEGIN
truncate table dbo.REQHEADERstage
END

if exists (select * from sys.tables where name = 'REQLINEstage')
BEGIN
truncate table dbo.REQLINEstage
END

if exists (select * from sys.tables where name = 'REQUESTERstage')
BEGIN
truncate table dbo.REQUESTERstage
END

if exists (select * from sys.tables where name = 'RQLOCstage')
BEGIN
truncate table dbo.RQLOCstage
END

if exists (select * from sys.tables where name = 'RQLMXVALstage')
BEGIN
truncate table dbo.RQLMXVALstage
END


--*****************END Remove Stage Tables Data**************************




--*****************Remove Main Tables Data (Non Transactional)**************************
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

if exists (select * from sys.tables where name = 'ITEMLOC')
BEGIN
truncate table dbo.ITEMLOC
END

if exists (select * from sys.tables where name = 'ITEMSRC')
BEGIN
truncate table dbo.ITEMSRC
END

if exists (select * from sys.tables where name = 'ITEMMAST')
BEGIN
truncate table dbo.ITEMMAST
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
--*****************END Remove MainTables Data**************************

END

GO
grant exec on sp_CleanLawsonStageTables to public
GO



