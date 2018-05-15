--*********************************************************************************************
--Tableau Table Sproc  These load data tables as alternate datasources for Tableau
--*********************************************************************************************


if exists (select * from dbo.sysobjects where id = object_id(N'tb_ConesDeployedTable') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure tb_ConesDeployedTable
GO

--exec tb_ConesDeployedTable 

CREATE PROCEDURE tb_ConesDeployedTable


--WITH ENCRYPTION
AS

/***************************		DROP DimBin		********************************/
BEGIN TRY
    DROP TABLE tableau.ConesDeployed	
END TRY

BEGIN CATCH
END CATCH


	SELECT 
	cd.ConeDeployed,
	cd.Deployed,
	cd.ExpectedDelivery,
	cd.ConeReturned,
	cd.Returned,
	df.FacilityID,
	df.FacilityName,
	dl.LocationID,
	dl.LocationName,
	di.ItemID,
	di.ItemDescription,
	db.BinSequence,
	cd.SubProduct,
	other.LocationID as AllLocations
	
into tableau.ConesDeployed	
	
	FROM bluebin.[ConesDeployed] cd
	inner join bluebin.DimFacility df on cd.FacilityID = df.FacilityID
	inner join bluebin.DimLocation dl on cd.LocationID = dl.LocationID
	inner join bluebin.DimItem di on cd.ItemID = di.ItemID
	inner join bluebin.DimBin db on df.FacilityID = db.BinFacility and dl.LocationID = db.LocationID and di.ItemID = db.ItemID
		inner join (
					SELECT 
				   il1.ItemID,
				   STUFF((SELECT  ', ' + rtrim(il2.LocationID) 
				  FROM bluebin.DimBin il2
				  where il2.ItemID = il1.ItemID 
				  order by il2.LocationID
				  FOR XML PATH('')), 1, 1, '') [LocationID]
						FROM bluebin.DimBin il1 
						GROUP BY il1.ItemID )other on cd.ItemID = other.ItemID
	where cd.Deleted = 0 and ConeReturned = 0



--if not exists (select * from @A)
--BEGIN
--select 
--	1 as ConeDeployed,
--	getdate() as Deployed,
--	getdate() as ExpectedDelivery,
--	0 as ConeReturned,
--	'' as Returned,
--	'' asFacilityID,
--	'' as FacilityName,
--	'None' as LocationID,
--	'None' as LocationName,
--	'' as ItemID,
--	'' as ItemDescription,
--	'' as BinSequence,
--	'' as SubProduct,
--	'' as AllLocations
	
--	END
--ELSE
--BEGIN
--select * from @A
--END


END
GO
grant exec on tb_ConesDeployedTable to appusers
GO


