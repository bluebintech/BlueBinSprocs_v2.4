--*****************************************************
--**************************SPROC**********************

if exists (select * from dbo.sysobjects where id = object_id(N'sp_SelectGembaAuditNodeLocation') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_SelectGembaAuditNodeLocation
GO

--exec sp_SelectGembaAuditNodeLocation
CREATE PROCEDURE sp_SelectGembaAuditNodeLocation

--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON

select 
	distinct 
	q.[LocationID],
	rtrim(dl.[LocationName]) + ' - ' + dl.LocationID  as LocationName
	--dl.LocationID + ' - ' + dl.[LocationName] as LocationName
	from gemba.GembaAuditNode q
	left join [bluebin].[DimLocation] dl on q.LocationID = dl.LocationID and dl.BlueBinFlag = 1
	order by LocationID
END
GO
grant exec on sp_SelectGembaAuditNodeLocation to appusers
GO





