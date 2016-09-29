if exists (select * from dbo.sysobjects where id = object_id(N'ssp_CleanDB') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure ssp_CleanDB
GO

--exec ssp_Versions

CREATE PROCEDURE ssp_CleanDB
--WITH ENCRYPTION
AS
BEGIN
truncate table bluebin.MasterLog
truncate table bluebin.Image
truncate table gemba.GembaAuditNode

truncate table qcn.QCN
truncate table bluebin.Training
update bluebin.BlueBinResource set Active = 0
delete from bluebin.BlueBinUser where UserLogin not like '%@bluebin.com%'
truncate table bluebin.BlueBinParMaster
truncate table scan.ScanLine
truncate table scan.ScanBatch


truncate table bluebin.DimBin
truncate table bluebin.DimFacility
truncate table bluebin.DimBinStatus
truncate table bluebin.DimDate
truncate table bluebin.DimItem
truncate table bluebin.DimLocation
truncate table bluebin.DimSnapshotDate
truncate table bluebin.FactBinSnapshot
truncate table bluebin.DimWarehouseItem
truncate table bluebin.FactBinSnapshot
truncate table bluebin.FactIssue
truncate table bluebin.FactScan
truncate table bluebin.FactWarehouseSnapshot

truncate table dbo.APCOMPANY
truncate table dbo.APVENMAST
truncate table dbo.BUYER
truncate table dbo.GLCHARTDTL
truncate table dbo.GLNAMES
truncate table dbo.GLTRANS
truncate table dbo.ICCATEGORY
truncate table dbo.ICMANFCODE
truncate table dbo.ICLOCATION
truncate table dbo.ICTRANS
truncate table dbo.ITEMLOC
truncate table dbo.ITEMMAST
truncate table dbo.ITEMSRC
truncate table dbo.MAINVDTL
truncate table dbo.MAINVMSG
truncate table dbo.MMDIST
truncate table dbo.POCODE
truncate table dbo.POLINE
truncate table dbo.POLINESRC
truncate table dbo.PORECLINE
truncate table dbo.POVAGRMTLN
truncate table dbo.PURCHORDER
truncate table dbo.REQHEADER
truncate table dbo.REQLINE
truncate table dbo.REQUESTER
truncate table dbo.RQLOC

truncate table etl.JobHeader
truncate table etl.JobDetails

truncate table tableau.Kanban
truncate table tableau.Contracts
truncate table tableau.Sourcing

update scan.ScanBatch set Active =0
END 
GO
grant exec on ssp_CleanDB to public
GO
