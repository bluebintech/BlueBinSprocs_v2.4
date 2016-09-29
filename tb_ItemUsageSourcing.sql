if exists (select * from dbo.sysobjects where id = object_id(N'tb_ItemUsageSourcing') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure tb_ItemUsageSourcing
GO

--exec tb_ItemUsageSourcing

CREATE PROCEDURE tb_ItemUsageSourcing

--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON

select 
FacilityName,
LocationName,
ItemID,
ItemClinicalDescription,
BinUOM,
convert(int,TotalPar) as TotalPar,
[Month],
Sum(OrderQty) as OrderQty,
Sum(OrderQty*BinCurrentCost) as Cost
from (
	select
	k.FacilityName,
	dl.LocationName,
	k.ItemNumber as ItemID,
	di.ItemClinicalDescription,
	dateadd(month,datediff(month,0,k.[PODate]),0) as [Month],
	k.BuyUOM as BinUOM,
	k.QtyOrdered as OrderQty,
	db.BinQty as TotalPar,
	db.BinCurrentCost
	from tableau.Sourcing k
	inner join bluebin.DimBin db on k.PurchaseFacility = db.BinFacility and k.PurchaseLocation = db.LocationID and k.ItemNumber = db.ItemID
	inner join bluebin.DimLocation dl on k.PurchaseLocation = dl.LocationID
	inner join bluebin.DimItem di on k.ItemNumber = di.ItemID

	where k.QtyOrdered is not null and k.BlueBinFlag = 'Yes' 
	--and k.PODate > getdate() -10
	) a

group by
FacilityName,
LocationName,
ItemID,
ItemClinicalDescription,
BinUOM,
convert(int,TotalPar),
[Month]

END
GO
grant exec on tb_ItemUsageSourcing to public
GO

