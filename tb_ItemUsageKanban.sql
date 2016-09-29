if exists (select * from dbo.sysobjects where id = object_id(N'tb_ItemUsageKanban') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure tb_ItemUsageKanban
GO

--exec tb_ItemUsageKanban
/*
select distinct PODate from tableau.Sourcing
*/
CREATE PROCEDURE tb_ItemUsageKanban

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
	k.LocationName,
	k.ItemID,
	k.ItemClinicalDescription,
	dateadd(month,datediff(month,0,k.[Date]),0) as [Month],
	k.BinUOM,
	k.OrderQty,
	db.BinQty as TotalPar,
	db.BinCurrentCost
	from tableau.Kanban k
	inner join bluebin.DimBin db on k.BinKey = db.BinKey

	where k.OrderQty is not null) a

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
grant exec on tb_ItemUsageKanban to public
GO