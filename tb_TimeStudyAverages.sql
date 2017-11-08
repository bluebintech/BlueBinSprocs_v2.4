--*********************************************************************************************
--Tableau Sproc  These load data into the datasources for Tableau
--*********************************************************************************************

IF EXISTS ( SELECT  *
            FROM    sys.objects
            WHERE   object_id = OBJECT_ID(N'tb_TimeStudyAverages')
                    AND type IN ( N'P', N'PC' ) ) 

--exec tb_TimeStudyAverages
DROP PROCEDURE  tb_TimeStudyAverages
GO

CREATE PROCEDURE tb_TimeStudyAverages

AS
BEGIN
SET NOCOUNT ON

declare @TodaysOrders TABLE ([Date] datetime,FacilityID int,FacilityName varchar(50),LocationID varchar(10),LocationName varchar(50),TodaysLines int)
declare @TodaysPicks TABLE ([Date] datetime,FacilityID int,FacilityName varchar(50),LocationID varchar(10),LocationName varchar(50),Picks int)
declare @StockOuts TABLE ([Date] datetime,FacilityID int,FacilityName varchar(50),LocationID varchar(10),LocationName varchar(50),StockOuts int)
declare @Groups TABLE (FacilityID int,LocationID varchar(10),GroupName varchar(50))
/*
--Alternate Todays Orders based on sproc and FactScan
declare @TodaysOrders TABLE ([Date] datetime,FacilityID int,FacilityName varchar(50),LocationID varchar(10),LocationName varchar(50),TodaysLines int,YesLines int,Trend varchar(10))
insert into @TodaysOrders
EXEC tb_TodaysOrders
*/
/* Todays Orders Table */
insert into @TodaysOrders
--EXEC tb_TodaysOrders
select
[Date],
FacilityID,
FacilityName,
LocationID,
LocationName,
ISNULL(SUM(Scan),0) as TodaysLines 
from tableau.Kanban
where [Date] = (select max(Date) from tableau.Kanban where Scan = 1) 
group by 
[Date],
FacilityID,
FacilityName,
LocationID,
LocationName


/* Todays Picks Table */
insert into @TodaysPicks
select
[Date],
FacilityID,
FacilityName,
LocationID,
LocationName,
ISNULL(SUM(Scan),0) as Picks  
from tableau.Kanban
where [Date] = (select max(Date) from tableau.Kanban where Scan = 1) and ItemType in ('I','MSR')
group by 
[Date],
FacilityID,
FacilityName,
LocationID,
LocationName



/* Todays StockOuts Table */
insert into @StockOuts
select
[Date],
FacilityID,
FacilityName,
LocationID,
LocationName,
ISNULL(SUM(StockOut),0) as StockOuts  
from tableau.Kanban
where [Date] = (select max(Date) from tableau.Kanban where Scan = 1)
group by 
[Date],
FacilityID,
FacilityName,
LocationID,
LocationName

/* Todays StockOuts Table */
insert into @Groups
select
FacilityID,
LocationID,
GroupName 
from bluebin.TimeStudyGroup


/*
--Parameter based entries that were based on no FacilityID
Declare @BinFill DECIMAL(10,2) = (select FacilityID,AvgM from bluebin.FactActivityTimes where Activity = 'Bin Fill')
Declare @NodeService DECIMAL(10,2) = (select FacilityID,AvgM from bluebin.FactActivityTimes where Activity = 'NodeService')
Declare @TravelTimeAll DECIMAL(10,2) = (select FacilityID,AvgM from bluebin.FactActivityTimes where Activity = 'TravelTimeAll')
Declare @ScanningBin DECIMAL(10,2) = (select FacilityID,AvgM from bluebin.FactActivityTimes where Activity = 'Scanning Bin')
Declare @ReturnsBinsSmall DECIMAL(10,2) = (select FacilityID,AvgM from bluebin.FactActivityTimes where Activity = 'Returns Bins Small')
Declare @ReturnsBinsLarge DECIMAL(10,2) = (select FacilityID,AvgM from bluebin.FactActivityTimes where Activity = 'Returns Bins Large')
Declare @DoubleBinStockOutAll DECIMAL(10,2) = (select FacilityID,AvgM from bluebin.FactActivityTimes where Activity = 'Double Bin StockOut All')
Declare @ScanningTime DECIMAL(10,2) = (select FacilityID,AvgM from bluebin.FactActivityTimes where Activity = 'Scanning Time')
Declare @ScanningNew DECIMAL(10,2) = (select FacilityID,AvgM from bluebin.FactActivityTimes where Activity = 'Scanning New')
Declare @ScanningMove DECIMAL(10,2) = (select FacilityID,AvgM from bluebin.FactActivityTimes where Activity = 'Scanning Move')
Declare @StoreroomPickLines DECIMAL(10,2) = (select FacilityID,AvgM from bluebin.FactActivityTimes where Activity = 'Storeroom Pick Lines')
*/
declare @ReturnsBinTH DECIMAL(10,2) = (select max(ConfigValue) from bluebin.Config where ConfigName = 'Returns Bins Threshhold')--default is Bin #s

select 
*
,case when TodaysLines = 0 then 0 else (BinFill + TravelTime + NodeService + ReturnsBins + StockOutTime + Scanning + PickTime) end as TotalTimeM
,case when TodaysLines = 0 then 0 else (BinFill + TravelTime + NodeService + ReturnsBins + StockOutTime + Scanning + PickTime)/60 end  as TotalTimeH
from 
(
select 
t.[Date],
t.FacilityID,
t.FacilityName,
t.LocationID,
t.LocationName,
ISNULL(g.GroupName,'None') as GroupName,
ISNULL(t.TodaysLines,0) as TodaysLines,
ISNULL(t.TodaysLines * (select AvgM from bluebin.FactActivityTimes where Activity = 'Bin Fill' and FacilityID = t.FacilityID),0) as BinFill,
ISNULL((select AvgM from bluebin.FactActivityTimes where Activity = 'TravelTimeAll' and FacilityID = t.FacilityID),0)  as TravelTime,
ISNULL(t.TodaysLines * (select AvgM from bluebin.FactActivityTimes where Activity = 'NodeService' and FacilityID = t.FacilityID),0)  as NodeService,
case when t.TodaysLines > @ReturnsBinTH then ISNULL((select AvgM from bluebin.FactActivityTimes where Activity = 'Returns Bins Large' and FacilityID = t.FacilityID),0)  else ISNULL((select AvgM from bluebin.FactActivityTimes where Activity = 'Returns Bins Small' and FacilityID = t.FacilityID),0) end as ReturnsBins,
ISNULL(s.StockOuts,0) as StockOuts,
ISNULL(s.StockOuts * (select AvgM from bluebin.FactActivityTimes where Activity = 'Double Bin StockOut All' and FacilityID = t.FacilityID),0) as StockOutTime,
ISNULL((t.TodaysLines * (select AvgM from bluebin.FactActivityTimes where Activity = 'Scanning Bin' and FacilityID = t.FacilityID))+ (select AvgM from bluebin.FactActivityTimes where Activity = 'Scanning Move' and FacilityID = t.FacilityID),0) as Scanning,
ISNULL(p.Picks,0) as StoreroomPickLines,
ISNULL(p.Picks,0) * (select AvgM from bluebin.FactActivityTimes where Activity = 'Storeroom Pick Lines' and FacilityID = t.FacilityID) as PickTime

from @TodaysOrders t
left join @TodaysPicks p on t.FacilityID = p.FacilityID and t.LocationID = p.LocationID
left join @StockOuts s on t.FacilityID = s.FacilityID and t.LocationID = s.LocationID
left join @Groups g on t.FacilityID = g.FacilityID and t.LocationID = g.LocationID
--left join bluebin.FactActivityTimes fat on t.FacilityID = fat.FacilityID
) as  a

order by FacilityID,LocationID

END
GO

grant exec on tb_TimeStudyAverages to public
GO