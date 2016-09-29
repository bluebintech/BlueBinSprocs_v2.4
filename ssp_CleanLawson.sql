if exists (select * from dbo.sysobjects where id = object_id(N'ssp_CleanLawson') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure ssp_CleanLawson
GO

--exec ssp_Versions

CREATE PROCEDURE ssp_CleanLawson
--WITH ENCRYPTION
AS
BEGIN

truncate table bluebin.DimBin
truncate table bluebin.FactIssue
truncate table bluebin.FactScan
truncate table tableau.Kanban
truncate table tableau.Sourcing
truncate table ICCATEGORY 
truncate table ICLOCATION  
truncate table ITEMLOC 
truncate table MAINVDTL  
truncate table POLINE  
truncate table PURCHORDER  
truncate table PORECLINE  
truncate table REQLINE  
truncate table RQLOC
truncate table REQHEADER  
truncate table REQUESTER  
truncate table POLINESRC  
truncate table POLINESRC 
truncate table GLNAMES  
truncate table GLTRANS  
truncate table ICTRANS  
truncate table MMDIST

END 
GO
grant exec on ssp_CleanLawson to public
GO



