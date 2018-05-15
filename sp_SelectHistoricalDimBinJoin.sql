--*****************************************************
--**************************SPROC**********************
--Updated GB 201820 Added ServiceTimes

if exists (select * from dbo.sysobjects where id = object_id(N'sp_SelectHistoricalDimBinJoin') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_SelectHistoricalDimBinJoin
GO

--exec sp_SelectHistoricalDimBinJoin

CREATE PROCEDURE sp_SelectHistoricalDimBinJoin


--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON
	SELECT 
	hdb.HistoricalDimBinJoinID,
	hdb.FacilityID,
	df.FacilityName,
	hdb.OldLocationID,
	hdb.OldLocationName,
	hdb.OldLocationServiceTime,
	hdb.NewLocationID,
	dl.LocationName as NewLocationName,
	hdb.NewLocationServiceTime,
	LastUpdated 
FROM bluebin.[HistoricalDimBinJoin] hdb
	inner join bluebin.DimFacility df on hdb.FacilityID = df.FacilityID
	inner join bluebin.DimLocation dl on hdb.FacilityID = dl.LocationFacility and hdb.NewLocationID = dl.LocationID
	--where Active like '%' + @Active + '%'
order by 
	hdb.FacilityID,
	df.FacilityName,
	hdb.OldLocationID,
	hdb.OldLocationName,
	hdb.NewLocationID,
	dl.LocationName
	
	

END
GO
grant exec on sp_SelectHistoricalDimBinJoin to appusers
GO
