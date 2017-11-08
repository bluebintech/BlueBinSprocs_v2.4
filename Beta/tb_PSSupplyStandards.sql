--*********************************************************************************************
--Tableau Sproc  These load data into the datasources for Tableau
--*********************************************************************************************

if exists (select * from dbo.sysobjects where id = object_id(N'tb_SupplyStandards') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure tb_SupplyStandards
GO

--exec tb_SupplyStandards

CREATE PROCEDURE tb_SupplyStandards

--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON

;

With A as
(
select
s.PONumber,
s.ItemNumber as ItemID,
di.ItemClinicalDescription,
s.POAmt,
case when dl.BlueBinFlag = '1' then 'Managed' else 'Not Managed Standard' end as Category,
1 as POs
from tableau.Sourcing s
left join bluebin.DimLocation dl on s.PurchaseLocation = dl.LocationID
left join bluebin.DimItem di on s.ItemNumber = di.ItemID
where PODate > getdate() -365 and (s.ItemNumber <> '' or s.ItemNumber is not null or s.POItemType <> 'X')
UNION
select
s.PONumber,
s.PODescr as ItemID,
s.PODescr as ItemClinicalDescription,
s.POAmt,
'Not Managed Special' as Category,
1 as POs
from tableau.Sourcing s
left join bluebin.DimLocation dl on s.PurchaseLocation = dl.LocationID
where PODate > getdate() -365 and (s.ItemNumber = '' or s.ItemNumber is null or s.POItemType = 'X') 
)
select 
Category,
COUNT ( Distinct ItemID ) as ItemCount,
SUM(POs) as TotalPOs,
Sum(POAmt) as Value 
from A
Group By Category

END
GO
grant exec on tb_SupplyStandards to public
GO

--select top 1000* from tableau.Sourcing where POItemType = 'X'