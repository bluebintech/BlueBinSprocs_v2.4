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
BEGIN
SET NOCOUNT ON

/* CTE Table */
Declare @StriderActivityTimes TABLE ( Activity varchar(100),FacilityID int,BlueBinResourceID int, ResourceName varchar(50),AvgS DECIMAL(10,2), AvgM DECIMAL(10,2), AvgH DECIMAL(10,2), LastUpdated date)

/* Bin Fill */
INSERT INTO @StriderActivityTimes
select 
'Bin Fill' as Activity,
c.FacilityID,
c.BlueBinResourceID,
df.LastName + ', ' + df.FirstName as ResourceName,
CAST(AVG(AllSecItem) AS DECIMAL(10,2)) as AvgS,
CAST(AVG(AllSecItem)/60 AS DECIMAL(10,2)) as AvgM,
CAST(AVG(AllSecItem)/360 AS DECIMAL(10,2)) as AvgH,
convert(Date,getdate()) as LastUpdated

from (
		select FacilityID,BlueBinResourceID,CAST(AVG(SecItem) AS DECIMAL(10,2)) as AllSecItem from (
			select FacilityID,BlueBinResourceID,DATEDIFF(s,StartTime,StopTime)/SKUS as SecItem from bluebin.TimeStudyBinFill where MostRecent = 1) as a
			group by FacilityID,BlueBinResourceID
		UNION 
		select FacilityID,BlueBinResourceID,CAST(AVG(SecItem) AS DECIMAL(10,2)) from (
			select FacilityID,BlueBinResourceID,DATEDIFF(s,StartTime,StopTime)/SKUS as SecItem from bluebin.TimeStudyBinFill where MostRecent = 0) as b
			group by FacilityID,BlueBinResourceID
		) as c 
		inner join bluebin.BlueBinResource df on c.BlueBinResourceID = df.BlueBinResourceID 
		group by c.FacilityID,c.BlueBinResourceID,df.LastName + ', ' + df.FirstName
		
/* Node Service */
INSERT INTO @StriderActivityTimes
select 
'NodeService' as Activity,
c.FacilityID,
c.BlueBinResourceID,
df.LastName + ', ' + df.FirstName as ResourceName,
CAST(AVG(AllSecItem) AS DECIMAL(10,2)) as AvgS,
CAST(AVG(AllSecItem)/60 AS DECIMAL(10,2)) as AvgM,
CAST(AVG(AllSecItem)/360 AS DECIMAL(10,2)) as AvgH,
convert(Date,getdate()) as LastUpdated
from (
		select FacilityID,BlueBinResourceID,CAST(AVG(SecItem) AS DECIMAL(10,2)) as AllSecItem from (
			select FacilityID,BlueBinResourceID,DATEDIFF(s,StartTime,StopTime)/SKUS as SecItem 
			from bluebin.TimeStudyNodeService 
			where TimeStudyProcessID = (Select ConfigID from bluebin.Config where ConfigName = 'Node Service' and ConfigValue = 'Node service time') 
			and MostRecent = 1) as a
			group by FacilityID,BlueBinResourceID
		UNION 
		select FacilityID,BlueBinResourceID,CAST(AVG(SecItem) AS DECIMAL(10,2)) from (
			select FacilityID,BlueBinResourceID,DATEDIFF(s,StartTime,StopTime)/SKUS as SecItem 
			from bluebin.TimeStudyNodeService 
			where  TimeStudyProcessID = (Select ConfigID from bluebin.Config where ConfigName = 'Node Service' and ConfigValue = 'Node service time')
			and MostRecent = 0) as b
			group by FacilityID,BlueBinResourceID
		) as c 
		inner join bluebin.BlueBinResource df on c.BlueBinResourceID = df.BlueBinResourceID 
		group by c.FacilityID,c.BlueBinResourceID,df.LastName + ', ' + df.FirstName

/* Travel Times All */
INSERT INTO @StriderActivityTimes
select 
'TravelTimeAll' as Activity,
c.FacilityID,
c.BlueBinResourceID,
df.LastName + ', ' + df.FirstName as ResourceName,
CAST(AVG(AllSecItem) AS DECIMAL(10,2)) as AvgS,
CAST(AVG(AllSecItem)/60 AS DECIMAL(10,2)) as AvgM,
CAST(AVG(AllSecItem)/360 AS DECIMAL(10,2)) as AvgH,
convert(Date,getdate()) as LastUpdated
from (
		select FacilityID,BlueBinResourceID,CAST(AVG(SecItem) AS DECIMAL(10,2)) as AllSecItem from (
			select FacilityID,BlueBinResourceID,DATEDIFF(s,StartTime,StopTime) as SecItem 
			from bluebin.TimeStudyNodeService 
			where TimeStudyProcessID in (Select ConfigID from bluebin.Config where ConfigName = 'Node Service' and ConfigValue in ('Travel Back to Stage','Travel time to next node','Leave Stage to enter node')) 
			and MostRecent = 1) as a
			group by FacilityID,BlueBinResourceID
		UNION 
		select FacilityID,BlueBinResourceID,CAST(AVG(SecItem) AS DECIMAL(10,2)) from (
			select FacilityID,BlueBinResourceID,DATEDIFF(s,StartTime,StopTime) as SecItem 
			from bluebin.TimeStudyNodeService 
			where  TimeStudyProcessID in (Select ConfigID from bluebin.Config where ConfigName = 'Node Service' and ConfigValue in ('Travel Back to Stage','Travel time to next node','Leave Stage to enter node'))
			and MostRecent = 0) as b
			group by FacilityID,BlueBinResourceID
		) as c 
		inner join bluebin.BlueBinResource df on c.BlueBinResourceID = df.BlueBinResourceID 
		group by c.FacilityID,c.BlueBinResourceID,df.LastName + ', ' + df.FirstName

/* Travel Times To Stage */
INSERT INTO @StriderActivityTimes
select 
'TravelTimeToStage' as Activity,
c.FacilityID,
c.BlueBinResourceID,
df.LastName + ', ' + df.FirstName as ResourceName,
CAST(AVG(AllSecItem) AS DECIMAL(10,2)) as AvgS,
CAST(AVG(AllSecItem)/60 AS DECIMAL(10,2)) as AvgM,
CAST(AVG(AllSecItem)/360 AS DECIMAL(10,2)) as AvgH,
convert(Date,getdate()) as LastUpdated
from (
		select FacilityID,BlueBinResourceID,CAST(AVG(SecItem) AS DECIMAL(10,2)) as AllSecItem from (
			select FacilityID,BlueBinResourceID,DATEDIFF(s,StartTime,StopTime) as SecItem 
			from bluebin.TimeStudyNodeService 
			where TimeStudyProcessID in (Select ConfigID from bluebin.Config where ConfigName = 'Node Service' and ConfigValue in ('Travel Back to Stage')) 
			and MostRecent = 1) as a
			group by FacilityID,BlueBinResourceID
		UNION 
		select FacilityID,BlueBinResourceID,CAST(AVG(SecItem) AS DECIMAL(10,2)) from (
			select FacilityID,BlueBinResourceID,DATEDIFF(s,StartTime,StopTime) as SecItem 
			from bluebin.TimeStudyNodeService 
			where  TimeStudyProcessID in (Select ConfigID from bluebin.Config where ConfigName = 'Node Service' and ConfigValue in ('Travel Back to Stage'))
			and MostRecent = 0) as b
			group by FacilityID,BlueBinResourceID
		) as c 
		inner join bluebin.BlueBinResource df on c.BlueBinResourceID = df.BlueBinResourceID 
		group by c.FacilityID,c.BlueBinResourceID,df.LastName + ', ' + df.FirstName


/* Travel Times Next Node */
INSERT INTO @StriderActivityTimes
select 
'TravelTimeNextNode' as Activity,
c.FacilityID,
c.BlueBinResourceID,
df.LastName + ', ' + df.FirstName as ResourceName,
CAST(AVG(AllSecItem) AS DECIMAL(10,2)) as AvgS,
CAST(AVG(AllSecItem)/60 AS DECIMAL(10,2)) as AvgM,
CAST(AVG(AllSecItem)/360 AS DECIMAL(10,2)) as AvgH,
convert(Date,getdate()) as LastUpdated
from (
		select FacilityID,BlueBinResourceID,CAST(AVG(SecItem) AS DECIMAL(10,2)) as AllSecItem from (
			select FacilityID,BlueBinResourceID,DATEDIFF(s,StartTime,StopTime) as SecItem 
			from bluebin.TimeStudyNodeService 
			where TimeStudyProcessID in (Select ConfigID from bluebin.Config where ConfigName = 'Node Service' and ConfigValue in ('Travel time to next node')) 
			and MostRecent = 1) as a
			group by FacilityID,BlueBinResourceID
		UNION 
		select FacilityID,BlueBinResourceID,CAST(AVG(SecItem) AS DECIMAL(10,2)) from (
			select FacilityID,BlueBinResourceID,DATEDIFF(s,StartTime,StopTime) as SecItem 
			from bluebin.TimeStudyNodeService 
			where  TimeStudyProcessID in (Select ConfigID from bluebin.Config where ConfigName = 'Node Service' and ConfigValue in ('Travel time to next node'))
			and MostRecent = 0) as b
			group by FacilityID,BlueBinResourceID
		) as c 
		inner join bluebin.BlueBinResource df on c.BlueBinResourceID = df.BlueBinResourceID 
		group by c.FacilityID,c.BlueBinResourceID,df.LastName + ', ' + df.FirstName

/* Travel Times From Stage */
INSERT INTO @StriderActivityTimes
select 
'TravelTimeFromStage' as Activity,
c.FacilityID,
c.BlueBinResourceID,
df.LastName + ', ' + df.FirstName as ResourceName,
CAST(AVG(AllSecItem) AS DECIMAL(10,2)) as AvgS,
CAST(AVG(AllSecItem)/60 AS DECIMAL(10,2)) as AvgM,
CAST(AVG(AllSecItem)/360 AS DECIMAL(10,2)) as AvgH,
convert(Date,getdate()) as LastUpdated
from (
		select FacilityID,BlueBinResourceID,CAST(AVG(SecItem) AS DECIMAL(10,2)) as AllSecItem from (
			select FacilityID,BlueBinResourceID,DATEDIFF(s,StartTime,StopTime) as SecItem 
			from bluebin.TimeStudyNodeService 
			where TimeStudyProcessID in (Select ConfigID from bluebin.Config where ConfigName = 'Node Service' and ConfigValue in ('Leave Stage to enter node')) 
			and MostRecent = 1) as a
			group by FacilityID,BlueBinResourceID
		UNION 
		select FacilityID,BlueBinResourceID,CAST(AVG(SecItem) AS DECIMAL(10,2)) from (
			select FacilityID,BlueBinResourceID,DATEDIFF(s,StartTime,StopTime) as SecItem 
			from bluebin.TimeStudyNodeService 
			where  TimeStudyProcessID in (Select ConfigID from bluebin.Config where ConfigName = 'Node Service' and ConfigValue in ('Leave Stage to enter node'))
			and MostRecent = 0) as b
			group by FacilityID,BlueBinResourceID
		) as c
		inner join bluebin.BlueBinResource df on c.BlueBinResourceID = df.BlueBinResourceID 
		group by c.FacilityID,c.BlueBinResourceID,df.LastName + ', ' + df.FirstName




declare @ReturnsBinTH DECIMAL(10,2) = (select max(ConfigValue) from bluebin.Config where ConfigName = 'Returns Bins Threshhold')--default is Bin #s





/* Returns Bins Small */
INSERT INTO @StriderActivityTimes
select 
'Returns Bins Small' as Activity,
c.FacilityID,df.BlueBinResourceID,
df.LastName + ', ' + df.FirstName as ResourceName,
CAST(AVG(AllSecItem) AS DECIMAL(10,2)) as AvgS,
CAST(AVG(AllSecItem)/60 AS DECIMAL(10,2)) as AvgM,
CAST(AVG(AllSecItem)/360 AS DECIMAL(10,2)) as AvgH,
convert(Date,getdate()) as LastUpdated
from (
		select FacilityID,BlueBinResourceID,CAST(AVG(SecItem) AS DECIMAL(10,2)) as AllSecItem from (
			select FacilityID,BlueBinResourceID,DATEDIFF(s,StartTime,StopTime) as SecItem 
			from bluebin.TimeStudyNodeService 
			where TimeStudyProcessID in (Select ConfigID from bluebin.Config where ConfigName = 'Node Service' and ConfigValue in ('Returns bin time')) 
			and MostRecent = 1
			and SKUS <= @ReturnsBinTH) as a
			group by FacilityID,BlueBinResourceID
		UNION 
		select FacilityID,BlueBinResourceID,CAST(AVG(SecItem) AS DECIMAL(10,2)) from (
			select FacilityID,BlueBinResourceID,DATEDIFF(s,StartTime,StopTime) as SecItem 
			from bluebin.TimeStudyNodeService 
			where  TimeStudyProcessID in (Select ConfigID from bluebin.Config where ConfigName = 'Node Service' and ConfigValue in ('Returns bin time'))
			and MostRecent = 0
			and SKUS <=@ReturnsBinTH) as b
			group by FacilityID,BlueBinResourceID
		) as c 
		right join bluebin.BlueBinResource df on c.BlueBinResourceID = df.BlueBinResourceID
		 
		group by c.FacilityID,df.BlueBinResourceID,df.LastName + ', ' + df.FirstName
		 
/* Returns Bins Large */

INSERT INTO @StriderActivityTimes
select 
'Returns Bins Large' as Activity,
c.FacilityID,
df.BlueBinResourceID,
df.LastName + ', ' + df.FirstName as ResourceName,
CAST(AVG(AllSecItem) AS DECIMAL(10,2)) as AvgS,
CAST(AVG(AllSecItem)/60 AS DECIMAL(10,2)) as AvgM,
CAST(AVG(AllSecItem)/360 AS DECIMAL(10,2)) as AvgH,
convert(Date,getdate()) as LastUpdated
from (
		select FacilityID,BlueBinResourceID,CAST(AVG(SecItem) AS DECIMAL(10,2)) as AllSecItem from (
			select FacilityID,BlueBinResourceID,DATEDIFF(s,StartTime,StopTime) as SecItem 
			from bluebin.TimeStudyNodeService 
			where TimeStudyProcessID in (Select ConfigID from bluebin.Config where ConfigName = 'Node Service' and ConfigValue in ('Returns bin time')) 
			and MostRecent = 1
			and SKUS > @ReturnsBinTH) as a
			group by FacilityID,BlueBinResourceID
		UNION 
		select FacilityID,BlueBinResourceID,CAST(AVG(SecItem) AS DECIMAL(10,2)) from (
			select FacilityID,BlueBinResourceID,DATEDIFF(s,StartTime,StopTime) as SecItem 
			from bluebin.TimeStudyNodeService 
			where  TimeStudyProcessID in (Select ConfigID from bluebin.Config where ConfigName = 'Node Service' and ConfigValue in ('Returns bin time'))
			and MostRecent = 0
			and SKUS > @ReturnsBinTH) as b
			group by FacilityID,BlueBinResourceID
		) as c 
		right join bluebin.BlueBinResource df on c.BlueBinResourceID = df.BlueBinResourceID
		 
		group by c.FacilityID,df.BlueBinResourceID,df.LastName + ', ' + df.FirstName



/* Double Bin StockOut Sweep*/

INSERT INTO @StriderActivityTimes
select 
'Double Bin StockOut Sweep' as Activity,
c.FacilityID,
c.BlueBinResourceID,
df.LastName + ', ' + df.FirstName as ResourceName,
CAST(AVG(AllSecItem) AS DECIMAL(10,2)) as AvgS,
CAST(AVG(AllSecItem)/60 AS DECIMAL(10,2)) as AvgM,
CAST(AVG(AllSecItem)/360 AS DECIMAL(10,2)) as AvgH,
convert(Date,getdate()) as LastUpdated
from (
		select FacilityID,BlueBinResourceID,CAST(AVG(SecItem) AS DECIMAL(10,2)) as AllSecItem from (
			select FacilityID,BlueBinResourceID,DATEDIFF(s,StartTime,StopTime)/SKUS as SecItem 
			from bluebin.TimeStudyStockOut 
			where TimeStudyProcessID in (Select ConfigID from bluebin.Config where ConfigName = 'Double Bin StockOut' 
			and ConfigValue in ('Write down Item numbers and sweep Stage')) 
			and MostRecent = 1) as a
			group by FacilityID,BlueBinResourceID
		UNION 
		select FacilityID,BlueBinResourceID,CAST(AVG(SecItem) AS DECIMAL(10,2)) from (
			select FacilityID,BlueBinResourceID,DATEDIFF(s,StartTime,StopTime)/SKUS as SecItem 
			from bluebin.TimeStudyStockOut 
			where  TimeStudyProcessID in (Select ConfigID from bluebin.Config where ConfigName = 'Double Bin StockOut' 
			and ConfigValue in ('Write down Item numbers and sweep Stage'))
			and MostRecent = 0) as b
			group by FacilityID,BlueBinResourceID
		) as c 
		inner join bluebin.BlueBinResource df on c.BlueBinResourceID = df.BlueBinResourceID 
		group by c.FacilityID,c.BlueBinResourceID,df.LastName + ', ' + df.FirstName

/* Double Bin StockOut Key out */

INSERT INTO @StriderActivityTimes
select 
'Double Bin StockOut Key out' as Activity,
c.FacilityID,
c.BlueBinResourceID,
df.LastName + ', ' + df.FirstName as ResourceName,
CAST(AVG(AllSecItem) AS DECIMAL(10,2)) as AvgS,
CAST(AVG(AllSecItem)/60 AS DECIMAL(10,2)) as AvgM,
CAST(AVG(AllSecItem)/360 AS DECIMAL(10,2)) as AvgH,
convert(Date,getdate()) as LastUpdated
from (
		select FacilityID,BlueBinResourceID,CAST(AVG(SecItem) AS DECIMAL(10,2)) as AllSecItem from (
			select FacilityID,BlueBinResourceID,DATEDIFF(s,StartTime,StopTime)/SKUS as SecItem 
			from bluebin.TimeStudyStockOut 
			where TimeStudyProcessID in (Select ConfigID from bluebin.Config where ConfigName = 'Double Bin StockOut' 
			and ConfigValue in ('Key out MSR')) 
			and MostRecent = 1) as a
			group by FacilityID,BlueBinResourceID
		UNION 
		select FacilityID,BlueBinResourceID,CAST(AVG(SecItem) AS DECIMAL(10,2)) from (
			select FacilityID,BlueBinResourceID,DATEDIFF(s,StartTime,StopTime)/SKUS as SecItem 
			from bluebin.TimeStudyStockOut 
			where  TimeStudyProcessID in (Select ConfigID from bluebin.Config where ConfigName = 'Double Bin StockOut' 
			and ConfigValue in ('Key out MSR'))
			and MostRecent = 0) as b
			group by FacilityID,BlueBinResourceID
		) as c 
		inner join bluebin.BlueBinResource df on c.BlueBinResourceID = df.BlueBinResourceID 
		group by c.FacilityID,c.BlueBinResourceID,df.LastName + ', ' + df.FirstName


/* Double Bin StockOut Pick Items */

INSERT INTO @StriderActivityTimes
select 
'Double Bin StockOut Pick Items' as Activity,
c.FacilityID,
c.BlueBinResourceID,
df.LastName + ', ' + df.FirstName as ResourceName,
CAST(AVG(AllSecItem) AS DECIMAL(10,2)) as AvgS,
CAST(AVG(AllSecItem)/60 AS DECIMAL(10,2)) as AvgM,
CAST(AVG(AllSecItem)/360 AS DECIMAL(10,2)) as AvgH,
convert(Date,getdate()) as LastUpdated
from (
		select FacilityID,BlueBinResourceID,CAST(AVG(SecItem) AS DECIMAL(10,2)) as AllSecItem from (
			select FacilityID,BlueBinResourceID,DATEDIFF(s,StartTime,StopTime)/SKUS as SecItem 
			from bluebin.TimeStudyStockOut 
			where TimeStudyProcessID in (Select ConfigID from bluebin.Config where ConfigName = 'Double Bin StockOut' 
			and ConfigValue in ('Pick Items')) 
			and MostRecent = 1) as a
			group by FacilityID,BlueBinResourceID
		UNION 
		select FacilityID,BlueBinResourceID,CAST(AVG(SecItem) AS DECIMAL(10,2)) from (
			select FacilityID,BlueBinResourceID,DATEDIFF(s,StartTime,StopTime)/SKUS as SecItem 
			from bluebin.TimeStudyStockOut 
			where  TimeStudyProcessID in (Select ConfigID from bluebin.Config where ConfigName = 'Double Bin StockOut' 
			and ConfigValue in ('Pick Items'))
			and MostRecent = 0) as b
			group by FacilityID,BlueBinResourceID
		) as c 
		inner join bluebin.BlueBinResource df on c.BlueBinResourceID = df.BlueBinResourceID 
		group by c.FacilityID,c.BlueBinResourceID,df.LastName + ', ' + df.FirstName


/* Double Bin StockOut Deliver Items */

INSERT INTO @StriderActivityTimes
select 
'Double Bin StockOut Deliver Items' as Activity,
c.FacilityID,
c.BlueBinResourceID,
df.LastName + ', ' + df.FirstName as ResourceName,
CAST(AVG(AllSecItem) AS DECIMAL(10,2)) as AvgS,
CAST(AVG(AllSecItem)/60 AS DECIMAL(10,2)) as AvgM,
CAST(AVG(AllSecItem)/360 AS DECIMAL(10,2)) as AvgH,
convert(Date,getdate()) as LastUpdated
from (
		select FacilityID,BlueBinResourceID,CAST(AVG(SecItem) AS DECIMAL(10,2)) as AllSecItem from (
			select FacilityID,BlueBinResourceID,DATEDIFF(s,StartTime,StopTime)/SKUS as SecItem 
			from bluebin.TimeStudyStockOut 
			where TimeStudyProcessID in (Select ConfigID from bluebin.Config where ConfigName = 'Double Bin StockOut' 
			and ConfigValue in ('Deliver Items')) 
			and MostRecent = 1
			) as a
			group by FacilityID,BlueBinResourceID
		UNION 
		select FacilityID,BlueBinResourceID,CAST(AVG(SecItem) AS DECIMAL(10,2)) from (
			select FacilityID,BlueBinResourceID,DATEDIFF(s,StartTime,StopTime)/SKUS as SecItem 
			from bluebin.TimeStudyStockOut 
			where  TimeStudyProcessID in (Select ConfigID from bluebin.Config where ConfigName = 'Double Bin StockOut' 
			and ConfigValue in ('Deliver Items'))
			and MostRecent = 0) as b
			group by FacilityID,BlueBinResourceID
		) as c 
		inner join bluebin.BlueBinResource df on c.BlueBinResourceID = df.BlueBinResourceID 
		group by c.FacilityID,c.BlueBinResourceID,df.LastName + ', ' + df.FirstName
/* Double Bin StockOut All */

INSERT INTO @StriderActivityTimes
select 
'Double Bin StockOut All' as Activity,
FacilityID,
BlueBinResourceID,
ResourceName,
SUM(AvgS) as AvgS,
SUM(AvgM) as AvgS,
SUM(AvgH) as AvgS,
convert(Date,getdate()) as LastUpdated
from @StriderActivityTimes
where Activity like 'Double Bin%'
group by
FacilityID,
BlueBinResourceID,
ResourceName

select 
sat.Activity,
sat.FacilityID,
df.FacilityName,
sat.BlueBinResourceID,
sat.ResourceName,
sat.AvgS as ResourceAvgS,
fat.AvgS as OverallAvgS,
sat.AvgS - fat.AvgS as DifferenceAvgS,

sat.AvgM as ResourceAvgM,
fat.AvgM as OverallAvgM,
sat.AvgM - fat.AvgM as DifferenceAvgM,

sat.AvgH as ResourceAvgH,
fat.AvgH as OverallAvgH,
sat.AvgH - fat.AvgH as DifferenceAvgH,
sat.LastUpdated
 
from @StriderActivityTimes sat
inner join bluebin.FactActivityTimes fat on sat.Activity = fat.Activity and sat.FacilityID = fat.FacilityID
inner join bluebin.DimFacility df on sat.FacilityID = df.FacilityID
where sat.AvgS is not null
order by sat.ResourceName,fat.Activity

END
GO

grant exec on tb_TimeStudyStrider to public
GO