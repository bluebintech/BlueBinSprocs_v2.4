--*********************************************************************************************
--Tableau Sproc  These load data into the datasources for Tableau
--*********************************************************************************************

IF EXISTS ( SELECT  *
            FROM    sys.objects
            WHERE   object_id = OBJECT_ID(N'tb_HealthTrendsHB')
                    AND type IN ( N'P', N'PC' ) ) 

--exec tb_HealthTrendsHB
DROP PROCEDURE  tb_HealthTrendsHB
GO

CREATE PROCEDURE tb_HealthTrendsHB

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
'' as LocationID,
'' as LocationName,
A.BinStatus,
count(A.BinStatus) as Count

from A
inner join bluebin.DimBin db on A.BinKey = db.BinKey
inner join bluebin.DimFacility df on db.BinFacility = df.FacilityID
group by
A.[Date],
df.FacilityID,
df.FacilityName,
A.BinStatus

order by
A.[Date],
df.FacilityID,
df.FacilityName,
A.BinStatus 

GO

grant exec on tb_HealthTrendsHB to public
GO

