--*********************************************************************************************
--Tableau Sproc  These load data into the datasources for Tableau
--*********************************************************************************************

IF EXISTS ( SELECT  *
            FROM    sys.objects
            WHERE   object_id = OBJECT_ID(N'tb_BlueBinScorecard')
                    AND type IN ( N'P', N'PC' ) ) 

--exec tb_BlueBinScorecard
DROP PROCEDURE  tb_BlueBinScorecard
GO

CREATE PROCEDURE tb_BlueBinScorecard

AS

select 
[Date],
FacilityID,
FacilityName,
LocationID,
LocationName,
Sum(Scan) as Scans,
Sum(StockOut) as StockOuts,
sum((case when DaysSinceLastScan >=90 then 0 else 1 end)) as LessThan90LastScan,
(count(BinKey)) as TotalBins
from tableau.Kanban

where [Date] > getdate() -14
group by 
[Date],
FacilityID,
FacilityName,
LocationID,
LocationName



GO

grant exec on tb_BlueBinScorecard to public
GO