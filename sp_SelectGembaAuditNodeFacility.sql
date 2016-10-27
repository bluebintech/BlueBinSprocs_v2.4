--*****************************************************
--**************************SPROC**********************

if exists (select * from dbo.sysobjects where id = object_id(N'sp_SelectGembaAuditNodeFacility') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_SelectGembaAuditNodeFacility
GO

--exec sp_SelectGembaAuditNodeFacility
CREATE PROCEDURE sp_SelectGembaAuditNodeFacility

--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON

select 
	distinct 
	q.[FacilityID],
    df.FacilityName as FacilityName
	from gemba.GembaAuditNode q
	left join [bluebin].[DimFacility] df on q.FacilityID = df.FacilityID 
	order by df.FacilityName
END
GO
grant exec on sp_SelectGembaAuditNodeFacility to appusers
GO





