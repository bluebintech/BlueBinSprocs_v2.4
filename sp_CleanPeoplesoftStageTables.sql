--*****************************************************
--**************************SPROC**********************

if exists (select * from dbo.sysobjects where id = object_id(N'sp_CleanPeoplesoftStageTables') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_CleanPeoplesoftStageTables
GO

--exec sp_CleanPeoplesoftStageTables

CREATE PROCEDURE sp_CleanPeoplesoftStageTables
--WITH ENCRYPTION
AS
BEGIN


--*****************Remove Stage Tables Data**************************
if exists (select * from sys.tables where name = 'REQ_LINE_SHIPstage')
BEGIN
truncate table dbo.REQ_LINE_SHIPstage
END



if exists (select * from sys.tables where name = 'BRAND_NAMES_INVstage')
BEGIN
truncate table dbo.BRAND_NAMES_INVstage
END

if exists (select * from sys.tables where name = 'BU_ATTRIB_INVstage')
BEGIN
truncate table dbo.BU_ATTRIB_INVstage
END

if exists (select * from sys.tables where name = 'BU_ITEMS_INVstage')
BEGIN
truncate table dbo.BU_ITEMS_INVstage
END

if exists (select * from sys.tables where name = 'CART_ATTRIB_INVstage')
BEGIN
truncate table dbo.CART_ATTRIB_INVstage
END

if exists (select * from sys.tables where name = 'CART_CT_INF_INVstage')
BEGIN
truncate table dbo.CART_CT_INF_INVstage
END

if exists (select * from sys.tables where name = 'DEMAND_INF_INVstage')
BEGIN
truncate table dbo.DEMAND_INF_INVstage
END

if exists (select * from sys.tables where name = 'CART_TEMPL_INVstage')
BEGIN
truncate table dbo.CART_TEMPL_INVstage
END

if exists (select * from sys.tables where name = 'IN_DEMANDstage')
BEGIN
truncate table dbo.IN_DEMANDstage
END

if exists (select * from sys.tables where name = 'ITEM_MFGstage')
BEGIN
truncate table dbo.ITEM_MFGstage
END

if exists (select * from sys.tables where name = 'ITM_VENDORstage')
BEGIN
truncate table dbo.ITM_VENDORstage
END

if exists (select * from sys.tables where name = 'LOCATION_TBLstage')
BEGIN
truncate table dbo.LOCATION_TBLstage
END

if exists (select * from sys.tables where name = 'MANUFACTURERstage')
BEGIN
truncate table dbo.MANUFACTURERstage
END

if exists (select * from sys.tables where name = 'MASTER_ITEM_TBLstage')
BEGIN
truncate table dbo.MASTER_ITEM_TBLstage
END

if exists (select * from sys.tables where name = 'PO_HDRstage')
BEGIN
truncate table dbo.PO_HDRstage
END

if exists (select * from sys.tables where name = 'PO_LINEstage')
BEGIN
truncate table dbo.PO_LINEstage
END

if exists (select * from sys.tables where name = 'PO_LINE_DISTRIBstage')
BEGIN
truncate table dbo.PO_LINE_DISTRIBstage
END

if exists (select * from sys.tables where name = 'PURCH_ITEM_ATTRstage')
BEGIN
truncate table dbo.PURCH_ITEM_ATTRstage
END

if exists (select * from sys.tables where name = 'PURCH_ITEM_BUstage')
BEGIN
truncate table dbo.PURCH_ITEM_BUstage
END

if exists (select * from sys.tables where name = 'RECV_HDRstage')
BEGIN
truncate table dbo.RECV_HDRstage
END

if exists (select * from sys.tables where name = 'RECV_LN_DISTRIBstage')
BEGIN
truncate table dbo.RECV_LN_DISTRIBstage
END

if exists (select * from sys.tables where name = 'RECV_LN_SHIPstage')
BEGIN
truncate table dbo.RECV_LN_SHIPstage
END

if exists (select * from sys.tables where name = 'REQ_HDRstage')
BEGIN
truncate table dbo.REQ_HDRstage
END

if exists (select * from sys.tables where name = 'REQ_LINEstage')
BEGIN
truncate table dbo.REQ_LINEstage
END

if exists (select * from sys.tables where name = 'REQ_LN_DISTRIBstage')
BEGIN
truncate table dbo.REQ_LN_DISTRIBstage
END

if exists (select * from sys.tables where name = 'VENDORstage')
BEGIN
truncate table dbo.VENDORstage
END


if exists (select * from sys.tables where name = 'REQ_LINE_SHIPstage')
BEGIN
truncate table dbo.REQ_LINE_SHIPstage
END

if exists (select * from sys.tables where name = 'DEPT_TBLstage')
BEGIN
truncate table dbo.DEPT_TBLstage
END

if exists (select * from sys.tables where name = 'GL_ACCOUNT_TBLstage')
BEGIN
truncate table dbo.GL_ACCOUNT_TBLstage
END

if exists (select * from sys.tables where name = 'JRNL_HEADERstage')
BEGIN
truncate table dbo.JRNL_HEADERstage
END

if exists (select * from sys.tables where name = 'JRNL_LNstage')
BEGIN
truncate table dbo.JRNL_LNstage
END

if exists (select * from sys.tables where name = 'CM_ACCTG_LINEstage')
BEGIN
truncate table dbo.CM_ACCTG_LINEstage
END

if exists (select * from sys.tables where name = 'RECV_LN_ACCTGstage')
BEGIN
truncate table dbo.RECV_LN_ACCTGstage
END

if exists (select * from sys.tables where name = 'VCHR_ACCTG_LINEstage')
BEGIN
truncate table dbo.VCHR_ACCTG_LINEstage
END


--*****************END Remove Stage Tables Data**************************




--*****************Remove Main Tables Data (Non Transactional)**************************
if exists (select * from sys.tables where name = 'BRAND_NAMES_INV')
BEGIN
truncate table dbo.BRAND_NAMES_INV
END

if exists (select * from sys.tables where name = 'BU_ATTRIB_INV')
BEGIN
truncate table dbo.BU_ATTRIB_INV
END

if exists (select * from sys.tables where name = 'BU_ITEMS_INV')
BEGIN
truncate table dbo.BU_ITEMS_INV
END

if exists (select * from sys.tables where name = 'CART_ATTRIB_INV')
BEGIN
truncate table dbo.CART_ATTRIB_INV
END

if exists (select * from sys.tables where name = 'CART_TEMPL_INV')
BEGIN
truncate table dbo.CART_TEMPL_INV
END

if exists (select * from sys.tables where name = 'CART_CT_INF_INV')
BEGIN
truncate table dbo.CART_CT_INF_INV
END

if exists (select * from sys.tables where name = 'ITEM_MFG')
BEGIN
truncate table dbo.ITEM_MFG
END

if exists (select * from sys.tables where name = 'ITM_VENDOR')
BEGIN
truncate table dbo.ITM_VENDOR
END

if exists (select * from sys.tables where name = 'LOCATION_TBL')
BEGIN
truncate table dbo.LOCATION_TBL
END

if exists (select * from sys.tables where name = 'MANUFACTURER')
BEGIN
truncate table dbo.MANUFACTURER
END

if exists (select * from sys.tables where name = 'MASTER_ITEM_TBL')
BEGIN
truncate table dbo.MASTER_ITEM_TBL
END

if exists (select * from sys.tables where name = 'PURCH_ITEM_BU')
BEGIN
truncate table dbo.PURCH_ITEM_BU
END

if exists (select * from sys.tables where name = 'VENDOR')
BEGIN
truncate table dbo.VENDOR
END
--*****************END Remove MainTables Data**************************

END

GO
grant exec on sp_CleanPeoplesoftStageTables to public
GO



