
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


--select top 10* from bluebin.HistoricalDimBin
--select top 10* from bluebin.DimBin
--select * from bluebin.HistoricalDimBinJoin

With A as
(
select 
COALESCE(i.FacilityID,i2.FacilityID,NULL) as FacilityID,
case when i.NewLocationID is NULL then i2.NewLocationID else ISNULL(i.NewLocationID,'') end as NewLocationID,
case when i.NewLocationName is NULL then i2.NewLocationName else ISNULL(i.NewLocationName,'') end as NewLocationName,
case when i2.OldLocationID is NULL then i.OldLocationID else ISNULL(i2.OldLocationID,'') end as OldLocationID,
case when i2.OldLocationName is NULL then i.OldLocationName else ISNULL(i2.OldLocationName,'') end as OldLocationName,
ISNULL(i.ItemID,'') as NewItem,
ISNULL(i.BinQty,0) as NewParCount,
ISNULL(i.AvgCost,0) as NewCost,
ISNULL(i.NewCt,0) as NewCt,
ISNULL(i2.ItemID,'') as OldItem,
ISNULL(i2.BinQty,0) as OldParCount,
ISNULL(i2.AvgCost,0) as OldCost,
ISNULL(i2.OldCt,0) as OldCt
from		(
			select i.BinFacility as FacilityID,i.LocationID as NewLocationID,lj.NewLocationName,i.ItemID,i.BinQty,i.BinUOM,p.AvgCost,lj.OldLocationID,lj.OldLocationName,1 as NewCt from bluebin.DimBin i
			left join (
						select Company,PurchaseLocation,ItemNumber,BuyUOM,Avg(UnitCost) AvgCost from tableau.Sourcing
						where PurchaseLocation is not null
						group by Company,PurchaseLocation,ItemNumber,BuyUOM) p on i.BinFacility = p.Company and i.LocationID = p.PurchaseLocation and i.ItemID = p.ItemNumber and i.BinUOM = p.BuyUOM
			right join bluebin.HistoricalDimBinJoin lj on i.LocationID = lj.NewLocationID
			) i
full outer join 
			( 
			select i.FacilityID,i.LocationID as OldLocationID,lj.OldLocationName,i.ItemID,i.BinUOM,p.AvgCost,i.BinQty,lj.NewLocationID,lj.NewLocationName,1 as OldCt from bluebin.HistoricalDimBin i 
			left join (
						select Company,PurchaseLocation,ItemNumber,BuyUOM,Avg(UnitCost) AvgCost from tableau.Sourcing
						where PurchaseLocation is not null
						group by Company,PurchaseLocation,ItemNumber,BuyUOM) p on i.FacilityID = p.Company and i.LocationID = p.PurchaseLocation and i.ItemID = p.ItemNumber and i.BinUOM = p.BuyUOM
			right join bluebin.HistoricalDimBinJoin lj on i.LocationID = lj.OldLocationID
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
sum(A.OldCt) as OldCt,
sum(A.NewParCount*A.NewCost) as NewCost,
sum(A.OldParCount*A.OldCost) as OldCost

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