--*********************************************************************************************
--Tableau Sproc  These load data into the datasources for Tableau
--*********************************************************************************************

IF EXISTS ( SELECT  *
            FROM    sys.objects
            WHERE   object_id = OBJECT_ID(N'tb_TimeStudyStrider')
                    AND type IN ( N'P', N'PC' ) ) 

--exec tb_TimeStudyStrider
DROP PROCEDURE  tb_TimeStudyStrider
GO

CREATE PROCEDURE tb_TimeStudyStrider

AS

/* CTE Table */
Declare @StriderActivityTimes TABLE ( Activity varchar(100),BlueBinResourceID int, ResourceName varchar(50),AvgS DECIMAL(10,2), AvgM DECIMAL(10,2), AvgH DECIMAL(10,2), LastUpdated date)

/* Bin Fill */
INSERT INTO @StriderActivityTimes
select 
'Bin Fill' as Activity,
c.BlueBinResourceID,
df.LastName + ', ' + df.FirstName as ResourceName,
CAST(AVG(AllSecItem) AS DECIMAL(10,2)) as AvgS,
CAST(AVG(AllSecItem)/60 AS DECIMAL(10,2)) as AvgM,
CAST(AVG(AllSecItem)/360 AS DECIMAL(10,2)) as AvgH,
convert(Date,getdate()) as LastUpdated

from (
		select BlueBinResourceID,CAST(AVG(SecItem) AS DECIMAL(10,2)) as AllSecItem from (
			select BlueBinResourceID,DATEDIFF(s,StartTime,StopTime)/SKUS as SecItem from bluebin.TimeStudyBinFill where MostRecent = 1) as a
			group by BlueBinResourceID
		UNION 
		select BlueBinResourceID,CAST(AVG(SecItem) AS DECIMAL(10,2)) from (
			select BlueBinResourceID,DATEDIFF(s,StartTime,StopTime)/SKUS as SecItem from bluebin.TimeStudyBinFill where MostRecent = 0) as b
			group by BlueBinResourceID
		) as c 
		inner join bluebin.BlueBinResource df on c.BlueBinResourceID = df.BlueBinResourceID 
		group by c.BlueBinResourceID,df.LastName + ', ' + df.FirstName
		
/* Node Service */
INSERT INTO @StriderActivityTimes
select 
'NodeService' as Activity,
c.BlueBinResourceID,
df.LastName + ', ' + df.FirstName as ResourceName,
CAST(AVG(AllSecItem) AS DECIMAL(10,2)) as AvgS,
CAST(AVG(AllSecItem)/60 AS DECIMAL(10,2)) as AvgM,
CAST(AVG(AllSecItem)/360 AS DECIMAL(10,2)) as AvgH,
convert(Date,getdate()) as LastUpdated
from (
		select BlueBinResourceID,CAST(AVG(SecItem) AS DECIMAL(10,2)) as AllSecItem from (
			select BlueBinResourceID,DATEDIFF(s,StartTime,StopTime)/SKUS as SecItem 
			from bluebin.TimeStudyNodeService 
			where TimeStudyProcessID = (Select ConfigID from bluebin.Config where ConfigName = 'Node Service' and ConfigValue = 'Node service time') 
			and MostRecent = 1) as a
			group by BlueBinResourceID
		UNION 
		select BlueBinResourceID,CAST(AVG(SecItem) AS DECIMAL(10,2)) from (
			select BlueBinResourceID,DATEDIFF(s,StartTime,StopTime)/SKUS as SecItem 
			from bluebin.TimeStudyNodeService 
			where  TimeStudyProcessID = (Select ConfigID from bluebin.Config where ConfigName = 'Node Service' and ConfigValue = 'Node service time')
			and MostRecent = 0) as b
			group by BlueBinResourceID
		) as c 
		inner join bluebin.BlueBinResource df on c.BlueBinResourceID = df.BlueBinResourceID 
		group by c.BlueBinResourceID,df.LastName + ', ' + df.FirstName

/* Travel Times All */
INSERT INTO @StriderActivityTimes
select 
'TravelTimeAll' as Activity,
c.BlueBinResourceID,
df.LastName + ', ' + df.FirstName as ResourceName,
CAST(AVG(AllSecItem) AS DECIMAL(10,2)) as AvgS,
CAST(AVG(AllSecItem)/60 AS DECIMAL(10,2)) as AvgM,
CAST(AVG(AllSecItem)/360 AS DECIMAL(10,2)) as AvgH,
convert(Date,getdate()) as LastUpdated
from (
		select BlueBinResourceID,CAST(AVG(SecItem) AS DECIMAL(10,2)) as AllSecItem from (
			select BlueBinResourceID,DATEDIFF(s,StartTime,StopTime) as SecItem 
			from bluebin.TimeStudyNodeService 
			where TimeStudyProcessID in (Select ConfigID from bluebin.Config where ConfigName = 'Node Service' and ConfigValue in ('Travel Back to Stage','Travel time to next node','Leave Stage to enter node')) 
			and MostRecent = 1) as a
			group by BlueBinResourceID
		UNION 
		select BlueBinResourceID,CAST(AVG(SecItem) AS DECIMAL(10,2)) from (
			select BlueBinResourceID,DATEDIFF(s,StartTime,StopTime) as SecItem 
			from bluebin.TimeStudyNodeService 
			where  TimeStudyProcessID in (Select ConfigID from bluebin.Config where ConfigName = 'Node Service' and ConfigValue in ('Travel Back to Stage','Travel time to next node','Leave Stage to enter node'))
			and MostRecent = 0) as b
			group by BlueBinResourceID
		) as c 
		inner join bluebin.BlueBinResource df on c.BlueBinResourceID = df.BlueBinResourceID 
		group by c.BlueBinResourceID,df.LastName + ', ' + df.FirstName

/* Travel Times To Stage */
INSERT INTO @StriderActivityTimes
select 
'TravelTimeToStage' as Activity,
c.BlueBinResourceID,
df.LastName + ', ' + df.FirstName as ResourceName,
CAST(AVG(AllSecItem) AS DECIMAL(10,2)) as AvgS,
CAST(AVG(AllSecItem)/60 AS DECIMAL(10,2)) as AvgM,
CAST(AVG(AllSecItem)/360 AS DECIMAL(10,2)) as AvgH,
convert(Date,getdate()) as LastUpdated
from (
		select BlueBinResourceID,CAST(AVG(SecItem) AS DECIMAL(10,2)) as AllSecItem from (
			select BlueBinResourceID,DATEDIFF(s,StartTime,StopTime) as SecItem 
			from bluebin.TimeStudyNodeService 
			where TimeStudyProcessID in (Select ConfigID from bluebin.Config where ConfigName = 'Node Service' and ConfigValue in ('Travel Back to Stage')) 
			and MostRecent = 1) as a
			group by BlueBinResourceID
		UNION 
		select BlueBinResourceID,CAST(AVG(SecItem) AS DECIMAL(10,2)) from (
			select BlueBinResourceID,DATEDIFF(s,StartTime,StopTime) as SecItem 
			from bluebin.TimeStudyNodeService 
			where  TimeStudyProcessID in (Select ConfigID from bluebin.Config where ConfigName = 'Node Service' and ConfigValue in ('Travel Back to Stage'))
			and MostRecent = 0) as b
			group by BlueBinResourceID
		) as c 
		inner join bluebin.BlueBinResource df on c.BlueBinResourceID = df.BlueBinResourceID 
		group by c.BlueBinResourceID,df.LastName + ', ' + df.FirstName


/* Travel Times Next Node */
INSERT INTO @StriderActivityTimes
select 
'TravelTimeNextNode' as Activity,
c.BlueBinResourceID,
df.LastName + ', ' + df.FirstName as ResourceName,
CAST(AVG(AllSecItem) AS DECIMAL(10,2)) as AvgS,
CAST(AVG(AllSecItem)/60 AS DECIMAL(10,2)) as AvgM,
CAST(AVG(AllSecItem)/360 AS DECIMAL(10,2)) as AvgH,
convert(Date,getdate()) as LastUpdated
from (
		select BlueBinResourceID,CAST(AVG(SecItem) AS DECIMAL(10,2)) as AllSecItem from (
			select BlueBinResourceID,DATEDIFF(s,StartTime,StopTime) as SecItem 
			from bluebin.TimeStudyNodeService 
			where TimeStudyProcessID in (Select ConfigID from bluebin.Config where ConfigName = 'Node Service' and ConfigValue in ('Travel time to next node')) 
			and MostRecent = 1) as a
			group by BlueBinResourceID
		UNION 
		select BlueBinResourceID,CAST(AVG(SecItem) AS DECIMAL(10,2)) from (
			select BlueBinResourceID,DATEDIFF(s,StartTime,StopTime) as SecItem 
			from bluebin.TimeStudyNodeService 
			where  TimeStudyProcessID in (Select ConfigID from bluebin.Config where ConfigName = 'Node Service' and ConfigValue in ('Travel time to next node'))
			and MostRecent = 0) as b
			group by BlueBinResourceID
		) as c 
		inner join bluebin.BlueBinResource df on c.BlueBinResourceID = df.BlueBinResourceID 
		group by c.BlueBinResourceID,df.LastName + ', ' + df.FirstName

/* Travel Times From Stage */
INSERT INTO @StriderActivityTimes
select 
'TravelTimeFromStage' as Activity,
c.BlueBinResourceID,
df.LastName + ', ' + df.FirstName as ResourceName,
CAST(AVG(AllSecItem) AS DECIMAL(10,2)) as AvgS,
CAST(AVG(AllSecItem)/60 AS DECIMAL(10,2)) as AvgM,
CAST(AVG(AllSecItem)/360 AS DECIMAL(10,2)) as AvgH,
convert(Date,getdate()) as LastUpdated
from (
		select BlueBinResourceID,CAST(AVG(SecItem) AS DECIMAL(10,2)) as AllSecItem from (
			select BlueBinResourceID,DATEDIFF(s,StartTime,StopTime) as SecItem 
			from bluebin.TimeStudyNodeService 
			where TimeStudyProcessID in (Select ConfigID from bluebin.Config where ConfigName = 'Node Service' and ConfigValue in ('Leave Stage to enter node')) 
			and MostRecent = 1) as a
			group by BlueBinResourceID
		UNION 
		select BlueBinResourceID,CAST(AVG(SecItem) AS DECIMAL(10,2)) from (
			select BlueBinResourceID,DATEDIFF(s,StartTime,StopTime) as SecItem 
			from bluebin.TimeStudyNodeService 
			where  TimeStudyProcessID in (Select ConfigID from bluebin.Config where ConfigName = 'Node Service' and ConfigValue in ('Leave Stage to enter node'))
			and MostRecent = 0) as b
			group by BlueBinResourceID
		) as c
		inner join bluebin.BlueBinResource df on c.BlueBinResourceID = df.BlueBinResourceID 
		group by c.BlueBinResourceID,df.LastName + ', ' + df.FirstName




declare @ReturnsBinTH DECIMAL(10,2) = (select max(ConfigValue) from bluebin.Config where ConfigName = 'Returns Bins Threshhold')--default is Bin #s



/* Returns Bins Threshhold */
INSERT INTO @StriderActivityTimes
select 
'Returns Bins Threshhold' as Activity,
df.BlueBinResourceID,
df.LastName + ', ' + df.FirstName as ResourceName,
CAST(AVG(@ReturnsBinTH)*60 AS DECIMAL(10,2)) as AvgS,
CAST(AVG(@ReturnsBinTH) AS DECIMAL(10,2)) as AvgM,
CAST(AVG(@ReturnsBinTH)/60 AS DECIMAL(10,2)) as AvgH,
convert(Date,getdate()) as LastUpdated
from bluebin.BlueBinResource df

group by 
df.BlueBinResourceID,
df.LastName + ', ' + df.FirstName


/* Returns Bins Small */
INSERT INTO @StriderActivityTimes
select 
'Returns Bins Small' as Activity,
df.BlueBinResourceID,
df.LastName + ', ' + df.FirstName as ResourceName,
case when CAST(AVG(AllSecItem) AS DECIMAL(10,2)) = 0 or CAST(AVG(AllSecItem) AS DECIMAL(10,2)) is null then CAST(AVG(@ReturnsBinSm)*60 AS DECIMAL(10,2)) else CAST(AVG(AllSecItem) AS DECIMAL(10,2)) end as AvgS,
case when CAST(AVG(AllSecItem)/60 AS DECIMAL(10,2)) = 0 or CAST(AVG(AllSecItem) AS DECIMAL(10,2)) is null then CAST(AVG(@ReturnsBinSm) AS DECIMAL(10,2)) else CAST(AVG(AllSecItem)/60 AS DECIMAL(10,2)) end as AvgM,
case when CAST(AVG(AllSecItem)/360 AS DECIMAL(10,2)) = 0 or CAST(AVG(AllSecItem) AS DECIMAL(10,2)) is null then CAST(AVG(@ReturnsBinSm)/60 AS DECIMAL(10,2)) else CAST(AVG(AllSecItem)/360 AS DECIMAL(10,2)) end as AvgH,
convert(Date,getdate()) as LastUpdated
from (
		select BlueBinResourceID,CAST(AVG(SecItem) AS DECIMAL(10,2)) as AllSecItem from (
			select BlueBinResourceID,DATEDIFF(s,StartTime,StopTime) as SecItem 
			from bluebin.TimeStudyNodeService 
			where TimeStudyProcessID in (Select ConfigID from bluebin.Config where ConfigName = 'Node Service' and ConfigValue in ('Returns bin time')) 
			and MostRecent = 1
			and SKUS <= @ReturnsBinTH) as a
			group by BlueBinResourceID
		UNION 
		select BlueBinResourceID,CAST(AVG(SecItem) AS DECIMAL(10,2)) from (
			select BlueBinResourceID,DATEDIFF(s,StartTime,StopTime) as SecItem 
			from bluebin.TimeStudyNodeService 
			where  TimeStudyProcessID in (Select ConfigID from bluebin.Config where ConfigName = 'Node Service' and ConfigValue in ('Returns bin time'))
			and MostRecent = 0
			and SKUS <=@ReturnsBinTH) as b
			group by BlueBinResourceID
		) as c 
		right join bluebin.BlueBinResource df on c.BlueBinResourceID = df.BlueBinResourceID
		 
		group by df.BlueBinResourceID,df.LastName + ', ' + df.FirstName
		 
/* Returns Bins Large */

INSERT INTO @StriderActivityTimes
select 
'Returns Bins Large' as Activity,
df.BlueBinResourceID,
df.LastName + ', ' + df.FirstName as ResourceName,
case when CAST(AVG(AllSecItem) AS DECIMAL(10,2)) = 0 or CAST(AVG(AllSecItem) AS DECIMAL(10,2)) is null then CAST(AVG(@ReturnsBinLg)*60 AS DECIMAL(10,2)) else CAST(AVG(AllSecItem) AS DECIMAL(10,2)) end as AvgS,
case when CAST(AVG(AllSecItem)/60 AS DECIMAL(10,2)) = 0 or CAST(AVG(AllSecItem) AS DECIMAL(10,2)) is null then CAST(AVG(@ReturnsBinLg) AS DECIMAL(10,2)) else CAST(AVG(AllSecItem)/60 AS DECIMAL(10,2)) end as AvgM,
case when CAST(AVG(AllSecItem)/360 AS DECIMAL(10,2)) = 0 or CAST(AVG(AllSecItem) AS DECIMAL(10,2)) is null then CAST(AVG(@ReturnsBinLg)/60 AS DECIMAL(10,2)) else CAST(AVG(AllSecItem)/360 AS DECIMAL(10,2)) end as AvgH,
convert(Date,getdate()) as LastUpdated
from (
		select BlueBinResourceID,CAST(AVG(SecItem) AS DECIMAL(10,2)) as AllSecItem from (
			select BlueBinResourceID,DATEDIFF(s,StartTime,StopTime) as SecItem 
			from bluebin.TimeStudyNodeService 
			where TimeStudyProcessID in (Select ConfigID from bluebin.Config where ConfigName = 'Node Service' and ConfigValue in ('Returns bin time')) 
			and MostRecent = 1
			and SKUS > @ReturnsBinTH) as a
			group by BlueBinResourceID
		UNION 
		select BlueBinResourceID,CAST(AVG(SecItem) AS DECIMAL(10,2)) from (
			select BlueBinResourceID,DATEDIFF(s,StartTime,StopTime) as SecItem 
			from bluebin.TimeStudyNodeService 
			where  TimeStudyProcessID in (Select ConfigID from bluebin.Config where ConfigName = 'Node Service' and ConfigValue in ('Returns bin time'))
			and MostRecent = 0
			and SKUS > @ReturnsBinTH) as b
			group by BlueBinResourceID
		) as c 
		right join bluebin.BlueBinResource df on c.BlueBinResourceID = df.BlueBinResourceID
		 
		group by df.BlueBinResourceID,df.LastName + ', ' + df.FirstName



/* Double Bin StockOut Sweep*/

INSERT INTO @StriderActivityTimes
select 
'Double Bin StockOut Sweep' as Activity,
c.BlueBinResourceID,
df.LastName + ', ' + df.FirstName as ResourceName,
CAST(AVG(AllSecItem) AS DECIMAL(10,2)) as AvgS,
CAST(AVG(AllSecItem)/60 AS DECIMAL(10,2)) as AvgM,
CAST(AVG(AllSecItem)/360 AS DECIMAL(10,2)) as AvgH,
convert(Date,getdate()) as LastUpdated
from (
		select BlueBinResourceID,CAST(AVG(SecItem) AS DECIMAL(10,2)) as AllSecItem from (
			select BlueBinResourceID,DATEDIFF(s,StartTime,StopTime)/SKUS as SecItem 
			from bluebin.TimeStudyStockOut 
			where TimeStudyProcessID in (Select ConfigID from bluebin.Config where ConfigName = 'Double Bin StockOut' 
			and ConfigValue in ('Write down Item numbers and sweep Stage')) 
			and MostRecent = 1) as a
			group by BlueBinResourceID
		UNION 
		select BlueBinResourceID,CAST(AVG(SecItem) AS DECIMAL(10,2)) from (
			select BlueBinResourceID,DATEDIFF(s,StartTime,StopTime)/SKUS as SecItem 
			from bluebin.TimeStudyStockOut 
			where  TimeStudyProcessID in (Select ConfigID from bluebin.Config where ConfigName = 'Double Bin StockOut' 
			and ConfigValue in ('Write down Item numbers and sweep Stage'))
			and MostRecent = 0) as b
			group by BlueBinResourceID
		) as c 
		inner join bluebin.BlueBinResource df on c.BlueBinResourceID = df.BlueBinResourceID 
		group by c.BlueBinResourceID,df.LastName + ', ' + df.FirstName

/* Double Bin StockOut Key out */

INSERT INTO @StriderActivityTimes
select 
'Double Bin StockOut Key out' as Activity,
c.BlueBinResourceID,
df.LastName + ', ' + df.FirstName as ResourceName,
CAST(AVG(AllSecItem) AS DECIMAL(10,2)) as AvgS,
CAST(AVG(AllSecItem)/60 AS DECIMAL(10,2)) as AvgM,
CAST(AVG(AllSecItem)/360 AS DECIMAL(10,2)) as AvgH,
convert(Date,getdate()) as LastUpdated
from (
		select BlueBinResourceID,CAST(AVG(SecItem) AS DECIMAL(10,2)) as AllSecItem from (
			select BlueBinResourceID,DATEDIFF(s,StartTime,StopTime)/SKUS as SecItem 
			from bluebin.TimeStudyStockOut 
			where TimeStudyProcessID in (Select ConfigID from bluebin.Config where ConfigName = 'Double Bin StockOut' 
			and ConfigValue in ('Key out MSR')) 
			and MostRecent = 1) as a
			group by BlueBinResourceID
		UNION 
		select BlueBinResourceID,CAST(AVG(SecItem) AS DECIMAL(10,2)) from (
			select BlueBinResourceID,DATEDIFF(s,StartTime,StopTime)/SKUS as SecItem 
			from bluebin.TimeStudyStockOut 
			where  TimeStudyProcessID in (Select ConfigID from bluebin.Config where ConfigName = 'Double Bin StockOut' 
			and ConfigValue in ('Key out MSR'))
			and MostRecent = 0) as b
			group by BlueBinResourceID
		) as c 
		inner join bluebin.BlueBinResource df on c.BlueBinResourceID = df.BlueBinResourceID 
		group by c.BlueBinResourceID,df.LastName + ', ' + df.FirstName


/* Double Bin StockOut Pick Items */

INSERT INTO @StriderActivityTimes
select 
'Double Bin StockOut Pick Items' as Activity,
c.BlueBinResourceID,
df.LastName + ', ' + df.FirstName as ResourceName,
CAST(AVG(AllSecItem) AS DECIMAL(10,2)) as AvgS,
CAST(AVG(AllSecItem)/60 AS DECIMAL(10,2)) as AvgM,
CAST(AVG(AllSecItem)/360 AS DECIMAL(10,2)) as AvgH,
convert(Date,getdate()) as LastUpdated
from (
		select BlueBinResourceID,CAST(AVG(SecItem) AS DECIMAL(10,2)) as AllSecItem from (
			select BlueBinResourceID,DATEDIFF(s,StartTime,StopTime)/SKUS as SecItem 
			from bluebin.TimeStudyStockOut 
			where TimeStudyProcessID in (Select ConfigID from bluebin.Config where ConfigName = 'Double Bin StockOut' 
			and ConfigValue in ('Pick Items')) 
			and MostRecent = 1) as a
			group by BlueBinResourceID
		UNION 
		select BlueBinResourceID,CAST(AVG(SecItem) AS DECIMAL(10,2)) from (
			select BlueBinResourceID,DATEDIFF(s,StartTime,StopTime)/SKUS as SecItem 
			from bluebin.TimeStudyStockOut 
			where  TimeStudyProcessID in (Select ConfigID from bluebin.Config where ConfigName = 'Double Bin StockOut' 
			and ConfigValue in ('Pick Items'))
			and MostRecent = 0) as b
			group by BlueBinResourceID
		) as c 
		inner join bluebin.BlueBinResource df on c.BlueBinResourceID = df.BlueBinResourceID 
		group by c.BlueBinResourceID,df.LastName + ', ' + df.FirstName


/* Double Bin StockOut Deliver Items */

INSERT INTO @StriderActivityTimes
select 
'Double Bin StockOut Deliver Items' as Activity,
c.BlueBinResourceID,
df.LastName + ', ' + df.FirstName as ResourceName,
CAST(AVG(AllSecItem) AS DECIMAL(10,2)) as AvgS,
CAST(AVG(AllSecItem)/60 AS DECIMAL(10,2)) as AvgM,
CAST(AVG(AllSecItem)/360 AS DECIMAL(10,2)) as AvgH,
convert(Date,getdate()) as LastUpdated
from (
		select BlueBinResourceID,CAST(AVG(SecItem) AS DECIMAL(10,2)) as AllSecItem from (
			select BlueBinResourceID,DATEDIFF(s,StartTime,StopTime)/SKUS as SecItem 
			from bluebin.TimeStudyStockOut 
			where TimeStudyProcessID in (Select ConfigID from bluebin.Config where ConfigName = 'Double Bin StockOut' 
			and ConfigValue in ('Deliver Items')) 
			and MostRecent = 1
			) as a
			group by BlueBinResourceID
		UNION 
		select BlueBinResourceID,CAST(AVG(SecItem) AS DECIMAL(10,2)) from (
			select BlueBinResourceID,DATEDIFF(s,StartTime,StopTime)/SKUS as SecItem 
			from bluebin.TimeStudyStockOut 
			where  TimeStudyProcessID in (Select ConfigID from bluebin.Config where ConfigName = 'Double Bin StockOut' 
			and ConfigValue in ('Deliver Items'))
			and MostRecent = 0) as b
			group by BlueBinResourceID
		) as c 
		inner join bluebin.BlueBinResource df on c.BlueBinResourceID = df.BlueBinResourceID 
		group by c.BlueBinResourceID,df.LastName + ', ' + df.FirstName
/* Double Bin StockOut All */

INSERT INTO @StriderActivityTimes
select 
'Double Bin StockOut All' as Activity,
BlueBinResourceID,
ResourceName,
SUM(AvgS) as AvgS,
SUM(AvgM) as AvgS,
SUM(AvgH) as AvgS,
convert(Date,getdate()) as LastUpdated
from @StriderActivityTimes
where Activity like 'Double Bin%'
group by
BlueBinResourceID,
ResourceName

select * 
from @StriderActivityTimes


GO

grant exec on tb_TimeStudyStrider to public
GO