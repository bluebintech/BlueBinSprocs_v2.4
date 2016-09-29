if exists (select * from dbo.sysobjects where id = object_id(N'sp_CleanPeoplesoftTables') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_CleanPeoplesoftTables
GO

--exec sp_CleanPeoplesoftTables

CREATE PROCEDURE sp_CleanPeoplesoftTables
--WITH ENCRYPTION
AS
BEGIN

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

if exists (select * from sys.tables where name = 'CART_CF_INF_INV')
BEGIN
truncate table dbo.CART_CF_INF_INV
END

if exists (select * from sys.tables where name = 'DEMAND_INF_INV')
BEGIN
truncate table dbo.DEMAND_INF_INV
END

if exists (select * from sys.tables where name = 'CART_TEMP_INV')
BEGIN
truncate table dbo.CART_TEMP_INV
END

if exists (select * from sys.tables where name = 'IN_DEMAND')
BEGIN
truncate table dbo.IN_DEMAND
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

if exists (select * from sys.tables where name = 'PO_HDR')
BEGIN
truncate table dbo.PO_HDR
END

if exists (select * from sys.tables where name = 'PO_LINE')
BEGIN
truncate table dbo.PO_LINE
END

if exists (select * from sys.tables where name = 'PO_LINE_DISTRIB')
BEGIN
truncate table dbo.PO_LINE_DISTRIB
END

if exists (select * from sys.tables where name = 'PURCH_ITEM_ATTRIB')
BEGIN
truncate table dbo.PURCH_ITEM_ATTRIB
END

if exists (select * from sys.tables where name = 'PURCH_ITEM_BU')
BEGIN
truncate table dbo.PURCH_ITEM_BU
END

if exists (select * from sys.tables where name = 'RECV_HDR')
BEGIN
truncate table dbo.RECV_HDR
END

if exists (select * from sys.tables where name = 'RECV_LN_DISTRIB')
BEGIN
truncate table dbo.RECV_LN_DISTRIB
END

if exists (select * from sys.tables where name = 'RECV_LN_SHIP')
BEGIN
truncate table dbo.RECV_LN_SHIP
END

if exists (select * from sys.tables where name = 'REQ_HDR')
BEGIN
truncate table dbo.REQ_HDR
END

if exists (select * from sys.tables where name = 'REQ_LINE')
BEGIN
truncate table dbo.REQ_LINE
END

if exists (select * from sys.tables where name = 'REQ_LN_DISTRIB')
BEGIN
truncate table dbo.REQ_LN_DISTRIB
END

if exists (select * from sys.tables where name = 'VENDOR')
BEGIN
truncate table dbo.VENDOR
END



END

GO
grant exec on sp_CleanPeoplesoftTables to public
GO



