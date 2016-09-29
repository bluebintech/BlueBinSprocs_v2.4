--*********************************************************************************************
--Tableau Sproc  These load data into the datasources for Tableau
--*********************************************************************************************

IF EXISTS ( SELECT  *
            FROM    sys.objects
            WHERE   object_id = OBJECT_ID(N'tb_HealthTrends')
                    AND type IN ( N'P', N'PC' ) ) 

--exec tb_HealthTrends
DROP PROCEDURE  tb_HealthTrends
GO

CREATE PROCEDURE tb_HealthTrends

AS




WITH A as (
select
[Date],
BinKey,
BinStatus
from tableau.Kanban
where [Date] > getdate() -90
group by
[Date],
BinKey,
BinStatus )


select 
A.[Date],
df.FacilityID,
df.FacilityName,
dl.LocationID,
dl.LocationName,
A.BinStatus,
count(A.BinStatus) as Count

from A
inner join bluebin.DimBin db on A.BinKey = db.BinKey
inner join bluebin.DimLocation dl on db.LocationID = dl.LocationID 
inner join bluebin.DimFacility df on db.BinFacility = df.FacilityID
group by
A.[Date],
df.FacilityID,
df.FacilityName,
dl.LocationID,
dl.LocationName,
A.BinStatus

order by
A.[Date],
df.FacilityID,
df.FacilityName,
dl.LocationID,
dl.LocationName,
A.BinStatus 

GO

grant exec on tb_HealthTrends to public
GO

