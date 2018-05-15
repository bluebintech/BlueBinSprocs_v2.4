--*****************************************************
--**************************SPROC**********************
--Updated 20180122 GB

if exists (select * from dbo.sysobjects where id = object_id(N'sp_SelectConesDeployed') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_SelectConesDeployed
GO

--exec sp_SelectConesDeployed '','',''

CREATE PROCEDURE sp_SelectConesDeployed
@Facility varchar(10),
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
		(df.FacilityName like '%' + @Facility + '%' or df.FacilityID like '%' + @Facility + '%')
	and
		(dl.LocationName like '%' + @Location + '%' or dl.LocationID like '%' + @Location + '%')
	and 
		(di.ItemID like '%' + @Item + '%' or di.ItemDescription like '%' + @Item + '%')
	order by cd.Deployed desc
	
END
GO
grant exec on sp_SelectConesDeployed to appusers
GO


--*****************************************************
--**************************SPROC**********************
--Updated 20180122 GB

if exists (select * from dbo.sysobjects where id = object_id(N'sp_SelectConesItem') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_SelectConesItem
GO

--exec sp_SelectConesItem
CREATE PROCEDURE sp_SelectConesItem

--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON
Select distinct a.LocationID,rTrim(a.ItemID) as ItemID,COALESCE(b.ItemClinicalDescription,b.ItemDescription,'No Description'),rTrim(a.ItemID)+ ' - ' + COALESCE(b.ItemClinicalDescription,b.ItemDescription,'No Description') as ExtendedDescription 
from [bluebin].[DimBin] a 
                                inner join [bluebin].[DimItem] b on rtrim(a.ItemID) = rtrim(b.ItemID)  
								UNION 
								select distinct LocationID,'' as ItemID,'' as ItemClinicalDescription, '--Select--'  as ExtendedDescription from [bluebin].[DimBin]
                                       
								--UNION 
								--select distinct q.LocationID,rTrim(q.ItemID) as ItemID,COALESCE(di.ItemClinicalDescription,di.ItemDescription,'No Description'),rTrim(q.ItemID)+ ' - ' + COALESCE(di.ItemClinicalDescription,di.ItemDescription,'No Description') as ExtendedDescription  
								--from qcn.QCN q
								--inner join bluebin.DimItem di on q.ItemID = di.ItemID
								--inner join bluebin.DimLocation dl on q.LocationID = dl.LocationID
                                       order by 4 asc

END
GO
grant exec on sp_SelectConesItem to appusers
GO

--*****************************************************
--**************************SPROC**********************
--Updated 20180122 GB

if exists (select * from dbo.sysobjects where id = object_id(N'sp_SelectConesLocation') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_SelectConesLocation
GO

--exec sp_SelectConesLocation
CREATE PROCEDURE sp_SelectConesLocation

--WITH ENCRYPTION
AS
BEGIN

SET NOCOUNT ON

select 
	distinct 
	q.[LocationID],
    rtrim(dl.[LocationName]) + ' - ' + dl.LocationID as LocationName
	from bluebin.ConesDeployed q
	left join [bluebin].[DimLocation] dl on q.LocationID = dl.LocationID and dl.BlueBinFlag = 1
	order by LocationID
END
GO
grant exec on sp_SelectConesLocation to appusers
GO


--*****************************************************
--**************************SPROC**********************
--Updated 20180122 GB

if exists (select * from dbo.sysobjects where id = object_id(N'sp_SelectConesFacility') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_SelectConesFacility
GO

--exec sp_SelectConesFacility
CREATE PROCEDURE sp_SelectConesFacility

--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON

select 
	distinct 
	cd.[FacilityID],
    df.FacilityName as FacilityName
	from bluebin.ConesDeployed cd
	inner join [bluebin].[DimFacility] df on cd.FacilityID = df.FacilityID 
	order by df.FacilityName
END
GO
grant exec on sp_SelectConesFacility to appusers
GO



declare @version varchar(50) = '2.4.20180122' --Update Version Number here


if not exists (select * from bluebin.Config where ConfigName = 'Version')
BEGIN
insert into bluebin.Config (ConfigName,ConfigValue,ConfigType,Active,LastUpdated) VALUES ('Version',@version,'DMS',1,getdate())
END
ELSE
Update bluebin.Config set ConfigValue = @version where ConfigName = 'Version'

Print 'Version Updated to ' + @version
Print 'DB: ' + DB_NAME() + ' updated'
GO








