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
BEGIN
SET NOCOUNT ON

truncate table tableau.ConesDeployed
--Declare @A table (ConeDeployed int,Deployed datetime,ExpectedDelivery Datetime,ConeReturned int,Returned datetime,FacilityID int,FacilityName varchar(255),LocationID varchar(15),LocationName varchar(50),ItemID varchar(32),ItemDescription varchar(50),BinSequence varchar(20),SubProduct varchar(3),AllLocations varchar(max))
	
insert into tableau.ConesDeployed	
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



END

GO

grant exec on tb_ConesDeployedTable to appusers
GO


