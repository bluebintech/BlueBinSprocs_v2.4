if exists (select * from dbo.sysobjects where id = object_id(N'sp_SelectConesDeployed') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_SelectConesDeployed
GO

--exec sp_SelectConesDeployed '',''

CREATE PROCEDURE sp_SelectConesDeployed
@Location varchar(10),
@Item varchar(32)

--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON
	SELECT 
	cd.ConesDeployedID,
	cd.Deployed,
	cd.ExpectedDelivery,
	df.FacilityID,
	df.FacilityName,
	dl.LocationID,
	dl.LocationName,
	di.ItemID,
	di.ItemDescription,
	cd.SubProduct,
	db.BinSequence,
	case when so.ItemID is not null then 'Yes' else 'No' end as DashboardStockout,
	cd.Details as DetailsText,
	case when Details is null or Details = '' then 'No' else 'Yes' end as Details
	
	FROM bluebin.[ConesDeployed] cd
	inner join bluebin.DimFacility df on cd.FacilityID = df.FacilityID
	inner join bluebin.DimLocation dl on cd.LocationID = dl.LocationID
	inner join bluebin.DimItem di on cd.ItemID = di.ItemID
	inner join bluebin.DimBin db on df.FacilityID = db.BinFacility and dl.LocationID = db.LocationID and di.ItemID = db.ItemID
	left outer join (select distinct FacilityID,LocationID,ItemID from tableau.Kanban where StockOut = 1 and [Date] = (select max([Date]) from tableau.Kanban)) so 
		on cd.FacilityID = so.FacilityID and cd.LocationID = so.LocationID and cd.ItemID = so.ItemID
	where cd.Deleted = 0 and cd.ConeReturned = 0
	and
		(dl.LocationName like '%' + @Location + '%' or dl.LocationID like '%' + @Location + '%')
	and 
		(di.ItemID like '%' + @Item + '%' or di.ItemDescription like '%' + @Item + '%')
	order by cd.Deployed desc
	
END
GO
grant exec on sp_SelectConesDeployed to appusers
GO
