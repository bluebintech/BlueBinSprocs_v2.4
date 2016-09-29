
if exists (select * from dbo.sysobjects where id = object_id(N'sp_SelectFacilities') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_SelectFacilities
GO

--exec sp_SelectFacilities 
CREATE PROCEDURE sp_SelectFacilities


--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON

SELECT DISTINCT rtrim(df.[FacilityID]) as FacilityID,df.[FacilityName] 
FROM bluebin.[DimFacility] df

inner join bluebin.DimLocation dl on df.FacilityID = dl.LocationFacility and dl.BlueBinFlag = 1
order by df.[FacilityName] asc

END 
GO
grant exec on sp_SelectFacilities to public
GO