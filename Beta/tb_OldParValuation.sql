
--*********************************************************************************************
--Tableau Sproc  These load data into the datasources for Tableau
--*********************************************************************************************

IF EXISTS ( SELECT  *
            FROM    sys.objects
            WHERE   object_id = OBJECT_ID(N'tb_OldParValuation')
                    AND type IN ( N'P', N'PC' ) ) 

--exec tb_OldParValuation
DROP PROCEDURE  tb_OldParValuation
GO

CREATE PROCEDURE tb_OldParValuation

AS

/*
select top 100* from bluebin.HistoricalDimBin
select top 100* from bluebin.DimBin
select * from bluebin.HistoricalDimBinJoin
*/

With A as
(
select 
COALESCE(i.FacilityID,i2.FacilityID,NULL) as FacilityID,
--NEW
case when i.NewLocationID is NULL then i2.NewLocationID else ISNULL(i.NewLocationID,'') end as NewLocationID,
case when i.NewLocationName is NULL then i2.NewLocationName else ISNULL(i.NewLocationName,'') end as NewLocationName,
ISNULL(i.ItemID,'') as NewItem,
(ISNULL(i.BinQty,0)*2)*ISNULL(i.AvgCost,0) as NewCost,
--OLD
case when i2.OldLocationID is NULL then i.OldLocationID else ISNULL(i2.OldLocationID,'') end as OldLocationID,
case when i2.OldLocationName is NULL then i.OldLocationName else ISNULL(i2.OldLocationName,'') end as OldLocationName,
ISNULL(i2.ItemID,'') as OldItem,
(ISNULL(i2.BinQty,0)*2)*ISNULL(i2.AvgCost,0) as OldCost,

--Generic counter/Identifiers
ISNULL(i2.OldCt,0) as OldCt,
ISNULL(i.NewCt,0) as NewCt,
case when i.ItemID is null and i2.ItemID is not null then 1 else 0 end as RemovedCt,
case when i2.ItemID is null and i.ItemID is not null then 1 else 0 end as AddedCt,
case when i.ItemID is not null and i2.ItemID is not null then 1 else 0 end as StayedCt




from		(
			select i.BinFacility as FacilityID,i.LocationID as NewLocationID,lj.NewLocationName,i.ItemID,i.BinQty,i.BinUOM,
			--p.AvgCost,
			ISNULL(i.BinCurrentCost,0) as BinCurrentCost,
			case when ISNULL(p.AvgCost,0) = 0 then ISNULL(i.BinCurrentCost,0) else ISNULL(p.AvgCost,0) end as AvgCost,
			lj.OldLocationID,lj.OldLocationName,1 as NewCt 
			from bluebin.DimBin i
			left join (
						select Company,PurchaseLocation,ItemNumber,BuyUOM,Avg(UnitCost) AvgCost from tableau.Sourcing
						where PurchaseLocation is not null
						group by Company,PurchaseLocation,ItemNumber,BuyUOM) p on i.BinFacility = p.Company and i.LocationID = p.PurchaseLocation and i.ItemID = p.ItemNumber and i.BinUOM = p.BuyUOM
			right join (select hdbj.*,dl.LocationName as NewLocationName from bluebin.HistoricalDimBinJoin hdbj left join bluebin.DimLocation dl on hdbj.NewLocationID = dl.LocationID) lj on i.LocationID = lj.NewLocationID
			) i
full outer join 
			( 
			select i.FacilityID,i.LocationID as OldLocationID,lj.OldLocationName,i.ItemID,i.BinUOM,
			--p.AvgCost,
			ISNULL(i.BinCurrentCost,0) as BinCurrentCost,
			case when ISNULL(p.AvgCost,0) = 0 then ISNULL(i.BinCurrentCost,0) else ISNULL(p.AvgCost,0) end as AvgCost,
			i.BinQty,lj.NewLocationID,lj.NewLocationName,1 as OldCt 
			from bluebin.HistoricalDimBin i 
			left join (
						select Company,PurchaseLocation,ItemNumber,BuyUOM,Avg(UnitCost) AvgCost from tableau.Sourcing
						where PurchaseLocation is not null
						group by Company,PurchaseLocation,ItemNumber,BuyUOM) p on i.FacilityID = p.Company and i.LocationID = p.PurchaseLocation and i.ItemID  = p.ItemNumber and i.BinUOM = p.BuyUOM
			right join (select hdbj.*,dl.LocationName as NewLocationName from bluebin.HistoricalDimBinJoin hdbj left join bluebin.DimLocation dl on hdbj.NewLocationID = dl.LocationID) lj on i.LocationID = lj.OldLocationID
			) i2 on i.NewLocationID = i2.NewLocationID and i.ItemID = i2.ItemID

)


select 
A.FacilityID,
df.FacilityName,
A.NewLocationID,
A.NewLocationName,
A.OldLocationID,
A.OldLocationName as OldNodeHeader,
sum(A.NewCt) as NewCt,
sum(A.NewCt*A.NewCost) as NewCost,

sum(A.OldCt) as OldCt,
sum(A.OldCt*A.OldCost) as OldCost,

sum(A.RemovedCt) as RemovedCt,
sum(A.RemovedCt*A.OldCost) as RemovedCost,

sum(A.AddedCt) as AddedCt,
sum(A.AddedCt*A.NewCost) as AddedCost,

sum(A.StayedCt) as StayedCt,
sum(A.StayedCt*A.NewCost) as StayedCost

from A
inner join bluebin.DimFacility df on A.FacilityID = df.FacilityID
group by 
A.FacilityID,
df.FacilityName,
A.NewLocationID,
A.NewLocationName,
A.OldLocationID,
A.OldLocationName

order by 1



GO

grant exec on tb_OldParValuation to public
GO