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

--Managed
select
s.Company,
s.PONumber,
s.POLineNumber,
--s.PurchaseLocation,
s.ItemNumber as ItemID,
di.ItemClinicalDescription,
COALESCE(convert(varchar(15),g2.ACCT_UNIT),convert(varchar(15),g3.ACCT_UNIT),s.AcctUnit,'Unknown') as AcctUnit,
--COALESCE(g2.DESCRIPTION,g3.DESCRIPTION,g.DESCRIPTION,'Unknown') as AcctUnitName,
s.POAmt,
'Managed' as Category,
1 as POs
from tableau.Sourcing s
inner join bluebin.DimBin db on s.Company = db.BinFacility and s.PurchaseLocation = db.LocationID and s.ItemNumber = db.ItemID
inner join bluebin.DimItem di on s.ItemNumber = di.ItemID
left join GLNAMES g on s.Company = g.COMPANY and ltrim(rtrim(s.AcctUnit)) = ltrim(rtrim(g.ACCT_UNIT))
left join (
		select 
		max(rh.ACCT_UNIT) as ACCT_UNIT,
		rl.COMPANY,
		rl.REQ_LOCATION,
		rl.ITEM,
		gl.DESCRIPTION
		 from REQHEADER rh
		 inner join REQLINE rl on rh.COMPANY = rl.COMPANY and rh.REQ_NUMBER = rl.REQ_NUMBER
		 inner join bluebin.DimLocation dl on rl.REQ_LOCATION = dl.LocationID and dl.BlueBinFlag = 1
		 left join GLNAMES gl on rh.COMPANY = gl.COMPANY and rh.ACCT_UNIT = gl.ACCT_UNIT and gl.ACTIVE_STATUS = 'A'
		 group by
		rl.COMPANY,
		rl.REQ_LOCATION,
		rl.ITEM,
		gl.DESCRIPTION ) g2 on db.BinFacility = g2.COMPANY and db.LocationID = g2.REQ_LOCATION and db.ItemID = g2.ITEM
left join (
		select 
		max(rh.ACCT_UNIT) as ACCT_UNIT,
		rl.COMPANY,
		rl.REQ_LOCATION,
		gl.DESCRIPTION
		 from REQHEADER rh
		 inner join REQLINE rl on rh.COMPANY = rl.COMPANY and rh.REQ_NUMBER = rl.REQ_NUMBER
		 inner join bluebin.DimLocation dl on rl.REQ_LOCATION = dl.LocationID and dl.BlueBinFlag = 1
		 left join GLNAMES gl on rh.COMPANY = gl.COMPANY and rh.ACCT_UNIT = gl.ACCT_UNIT and gl.ACTIVE_STATUS = 'A'
		 group by
		rl.COMPANY,
		rl.REQ_LOCATION,
		gl.DESCRIPTION ) g3 on db.BinFacility = g3.COMPANY and db.LocationID = g3.REQ_LOCATION

where PODate > getdate() -365 and (s.ItemNumber <> '' or s.ItemNumber is not null or s.POItemType <> 'X')
group by 
s.Company,
s.PONumber,
s.POLineNumber,
--s.PurchaseLocation,
s.ItemNumber,
di.ItemClinicalDescription,
COALESCE(convert(varchar(15),g2.ACCT_UNIT),convert(varchar(15),g3.ACCT_UNIT),s.AcctUnit,'Unknown'),
--COALESCE(g2.DESCRIPTION,g3.DESCRIPTION,g.DESCRIPTION,'Unknown'),
s.POAmt

UNION  

select
db.BinFacility as Company,
'' as PONumber,
'' as POLineNumber,
--s.PurchaseLocation,
db.ItemID,
di.ItemClinicalDescription,
COALESCE(g2.ACCT_UNIT,g3.ACCT_UNIT,'Unknown') as AcctUnit,
--COALESCE(g2.DESCRIPTION,g3.DESCRIPTION,'Unknown') as AcctUnitName,
0 as POAmt,
'Managed' as Category,
0 as POs
from bluebin.DimBin db 
inner join bluebin.DimItem di on di.ItemID = db.ItemID
left join (
		select 
		max(rh.ACCT_UNIT) as ACCT_UNIT,
		rl.COMPANY,
		rl.REQ_LOCATION,
		rl.ITEM,
		gl.DESCRIPTION
		 from REQHEADER rh
		 inner join REQLINE rl on rh.COMPANY = rl.COMPANY and rh.REQ_NUMBER = rl.REQ_NUMBER
		 inner join bluebin.DimLocation dl on rl.REQ_LOCATION = dl.LocationID and dl.BlueBinFlag = 1
		 left join GLNAMES gl on rh.COMPANY = gl.COMPANY and rh.ACCT_UNIT = gl.ACCT_UNIT and gl.ACTIVE_STATUS = 'A'
		 group by
		rl.COMPANY,
		rl.REQ_LOCATION,
		rl.ITEM,
		gl.DESCRIPTION ) g2 on db.BinFacility = g2.COMPANY and db.LocationID = g2.REQ_LOCATION and db.ItemID = g2.ITEM
left join (
		select 
		max(rh.ACCT_UNIT) as ACCT_UNIT,
		rl.COMPANY,
		rl.REQ_LOCATION,
		gl.DESCRIPTION
		 from REQHEADER rh
		 inner join REQLINE rl on rh.COMPANY = rl.COMPANY and rh.REQ_NUMBER = rl.REQ_NUMBER
		 inner join bluebin.DimLocation dl on rl.REQ_LOCATION = dl.LocationID and dl.BlueBinFlag = 1
		 left join GLNAMES gl on rh.COMPANY = gl.COMPANY and rh.ACCT_UNIT = gl.ACCT_UNIT and gl.ACTIVE_STATUS = 'A'
		 group by
		rl.COMPANY,
		rl.REQ_LOCATION,
		gl.DESCRIPTION ) g3 on db.BinFacility = g3.COMPANY and db.LocationID = g3.REQ_LOCATION

group by 
db.BinFacility,
db.ItemID,
di.ItemClinicalDescription,
COALESCE(g2.ACCT_UNIT,g3.ACCT_UNIT,'Unknown')
--,COALESCE(g2.DESCRIPTION,g3.DESCRIPTION,'Unknown')



--Not Managed Standard  
UNION
select
s.Company,
s.PONumber,
s.POLineNumber,
--s.PurchaseLocation,
s.ItemNumber as ItemID,
di.ItemClinicalDescription,
COALESCE(s.AcctUnit,convert(varchar(15),g2.ACCT_UNIT),convert(varchar(15),g3.ACCT_UNIT),'Unknown') as AcctUnit,
--COALESCE(g.DESCRIPTION,g2.DESCRIPTION,g3.DESCRIPTION,'Unknown') as AcctUnitName,
s.POAmt,
'Not Managed Standard' as Category,
1 as POs
from tableau.Sourcing s
inner join bluebin.DimBinNotManaged db on s.Company = db.FacilityID and s.PurchaseLocation = db.LocationID and s.ItemNumber = db.ItemID
left join bluebin.DimItem di on s.ItemNumber = di.ItemID
left join GLNAMES g on s.Company = g.COMPANY and ltrim(rtrim(s.AcctUnit)) = ltrim(rtrim(g.ACCT_UNIT))
left join (
		select 
		max(rh.ACCT_UNIT) as ACCT_UNIT,
		rl.COMPANY,
		rl.REQ_LOCATION,
		rl.ITEM,
		gl.DESCRIPTION
		 from REQHEADER rh
		 inner join REQLINE rl on rh.COMPANY = rl.COMPANY and rh.REQ_NUMBER = rl.REQ_NUMBER
		 inner join bluebin.DimLocation dl on rl.REQ_LOCATION = dl.LocationID and dl.BlueBinFlag = 1
		 left join GLNAMES gl on rh.COMPANY = gl.COMPANY and rh.ACCT_UNIT = gl.ACCT_UNIT and gl.ACTIVE_STATUS = 'A'
		 group by
		rl.COMPANY,
		rl.REQ_LOCATION,
		rl.ITEM,
		gl.DESCRIPTION ) g2 on db.FacilityID = g2.COMPANY and db.LocationID = g2.REQ_LOCATION and db.ItemID = g2.ITEM
left join (
		select 
		max(rh.ACCT_UNIT) as ACCT_UNIT,
		rl.COMPANY,
		rl.REQ_LOCATION,
		gl.DESCRIPTION
		 from REQHEADER rh
		 inner join REQLINE rl on rh.COMPANY = rl.COMPANY and rh.REQ_NUMBER = rl.REQ_NUMBER
		 inner join bluebin.DimLocation dl on rl.REQ_LOCATION = dl.LocationID and dl.BlueBinFlag = 1
		 left join GLNAMES gl on rh.COMPANY = gl.COMPANY and rh.ACCT_UNIT = gl.ACCT_UNIT and gl.ACTIVE_STATUS = 'A'
		 group by
		rl.COMPANY,
		rl.REQ_LOCATION,
		gl.DESCRIPTION ) g3 on db.FacilityID = g3.COMPANY and db.LocationID = g3.REQ_LOCATION
where PODate > getdate() -365 and (s.ItemNumber <> '' or s.ItemNumber is not null or s.POItemType <> 'X')
group by 
s.Company,
s.PONumber,
s.POLineNumber,
--s.PurchaseLocation,
s.ItemNumber,
di.ItemClinicalDescription,
COALESCE(s.AcctUnit,convert(varchar(15),g2.ACCT_UNIT),convert(varchar(15),g3.ACCT_UNIT),'Unknown'),
--COALESCE(g.DESCRIPTION,g2.DESCRIPTION,g3.DESCRIPTION,'Unknown'),
s.POAmt

--Not Managed Special
UNION
select
s.Company,
s.PONumber,
s.POLineNumber,
--s.PurchaseLocation,
case when s.ItemNumber = '' or s.ItemNumber is null then s.PODescr else s.ItemNumber end as ItemID,
s.PODescr as ItemClinicalDescription,
COALESCE(s.AcctUnit,'Unknown') as AcctUnit,
--COALESCE(s.AcctUnitName,'Unknown') as AcctUnitName,
s.POAmt,
'Not Managed Special' as Category,
1 as POs
from tableau.Sourcing s
where (s.ItemNumber not in (select distinct ItemID from bluebin.DimBin) or s.ItemNumber not in (select distinct ItemID from bluebin.DimBinNotManaged)) and PODate > getdate() -365 and (s.ItemNumber = '' or s.ItemNumber is null or s.POItemType = 'X') 
group by
s.Company,
s.PONumber,
s.POLineNumber,
--s.PurchaseLocation,
case when s.ItemNumber = '' or s.ItemNumber is null then s.PODescr else s.ItemNumber end,
s.PODescr,
COALESCE(s.AcctUnit,'Unknown'),
--COALESCE(s.AcctUnitName,'Unknown'),
s.POAmt

)



select 
A.Company as FacilityID,
df.FacilityName,
ltrim(A.PONumber) as PONumber,
A.AcctUnit,
gl.DESCRIPTION as AcctUnitName,
--A.AcctUnitName,
case when A.Category = 'Not Managed Special' and A.ItemID = A.ItemClinicalDescription then 'N/A' else A.ItemID end as ItemID,
A.ItemClinicalDescription,
A.Category,
A.POAmt,
A.POs

 from A
 left Join bluebin.DimFacility df on A.Company = df.FacilityID
 left join GLNAMES gl on A.Company = gl.COMPANY and A.AcctUnit = gl.ACCT_UNIT
order by 
A.Company,
A.AcctUnit,
6
/* Below query could be used for Summed value checking
,
B as (
select 
A.Company as FacilityID,
df.FacilityName,
A.AcctUnit,
A.AcctUnitName,
--A.PurchaseLocation as LocationID,
--dl.LocationName,
A.Category,
COUNT ( Distinct ItemID ) as ItemCount,
SUM(POs) as TotalPOs,
Sum(POAmt) as Value 

from A
left Join bluebin.DimFacility df on A.Company = df.FacilityID
--left join bluebin.DimLocation dl on A.Company = dl.LocationFacility and A.PurchaseLocation = dl.LocationID

Group By 
A.Company,
df.FacilityName,
A.AcctUnit,
A.AcctUnitName,
--A.PurchaseLocation,
--dl.LocationName,
A.Category)

select 
*
from B
order by 
FacilityID,
FacilityName,
AcctUnit,
AcctUnitName
--LocationID,
--LocationName
*/


END
GO
grant exec on tb_SupplyStandards to public
GO

