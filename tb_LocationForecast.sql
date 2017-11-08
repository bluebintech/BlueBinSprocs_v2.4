--*********************************************************************************************
--Tableau Sproc  These load data into the datasources for Tableau
--*********************************************************************************************

if exists (select * from dbo.sysobjects where id = object_id(N'tb_LocationForecast') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure tb_LocationForecast
GO

--exec tb_LocationForecast
--select top 10* from tableau.Sourcing


CREATE PROCEDURE tb_LocationForecast

--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON

select 
FacilityName,
LocationName,
LocationID,
ItemID,
ItemClinicalDescription,
BinUOM,
ItemType,
--convert(int,TotalPar) as TotalPar,
--[Month],
FirstPODate,
--Sum(OrderQty)/365 as AvgDailyQty,
--Sum(OrderQty)/12 as AvgMonthlyQty,
Sum(OrderQty) as TotalOrderQty,
case when Denominator > 365 then Sum(OrderQty)/365 else Sum(OrderQty)/Denominator end as AvgDailyQty,
case when Denominator > 365 then Sum(OrderQty)/12 else Sum(OrderQty)/Denominator30 end as AvgMonthlyQty

--Sum(OrderQty*BinCurrentCost) as Cost
from (
	select
	k.FacilityName,
	dl.LocationName,
	dl.LocationID,
	k.ItemNumber as ItemID,
	di.ItemClinicalDescription,
	k.[PODate],
	dateadd(month,datediff(month,0,k.[PODate]),0) as [Month],
	k.BuyUOM as BinUOM,
	k.POItemType as ItemType,
	k.QtyOrdered as OrderQty,
	db.BinQty as TotalPar,
	db.BinCurrentCost,
	convert(Decimal(13,4),a.Denominator) as Denominator,
	convert(Decimal(13,4),a.Denominator)/30 as Denominator30,
	a.FirstPODate
	from tableau.Sourcing k
	left join bluebin.DimBin db on k.PurchaseFacility = db.BinFacility and k.PurchaseLocation = db.LocationID and k.ItemNumber = db.ItemID
	inner join bluebin.DimLocation dl on k.PurchaseLocation = dl.LocationID
	inner join bluebin.DimItem di on k.ItemNumber = di.ItemID
	inner join (
				select 
					Company,
					PurchaseLocation,
					ItemNumber,
					min(PODate) as FirstPODate,
					DATEDIFF(day,min(PODate),getdate()) as Denominator
					from tableau.Sourcing 
					where  (PurchaseLocation is not null or PurchaseLocation <> '') and getdate() -PODate > 1 
					group by
					Company,
					PurchaseLocation,
					ItemNumber
					--order by 5 asc
				) a on k.Company = a.Company and k.PurchaseLocation = a.PurchaseLocation and k.ItemNumber = a.ItemNumber

	where k.QtyOrdered is not null and k.BlueBinFlag = 'No' and PODate > getdate() -365
	--and k.PODate > getdate() -10
	) a

group by
FacilityName,
LocationName,
LocationID,
ItemID,
ItemClinicalDescription,
BinUOM,
ItemType,
FirstPODate,
Denominator,
Denominator30
--convert(int,TotalPar),
--[Month]
order by 1,2,4

END
GO
grant exec on tb_LocationForecast to public
GO

