/*********************************************************************

FactFactActivityTimes

--update etl.JobSteps set ActiveFlag = 1 where StepName = 'FactActivityTimes'

*********************************************************************/

IF EXISTS ( SELECT  *
            FROM    sys.objects
            WHERE   object_id = OBJECT_ID(N'etl_FactActivityTimes')
                    AND type IN ( N'P', N'PC' ) ) 

DROP PROCEDURE  etl_FactActivityTimes
GO
--exec etl_FactActivityTimes
--select * from bluebin.FactActivityTimes

CREATE PROCEDURE etl_FactActivityTimes

AS

/****************************		DROP FactActivityTimes ***********************************/
 BEGIN TRY
 DROP TABLE bluebin.FactActivityTimes
 END TRY
 BEGIN CATCH
 END CATCH

 /*******************************	CREATE FactActivityTimes	*********************************/
 SET NOCOUNT ON

/* CTE Table */
Declare @FactActivityTimes TABLE ( Activity varchar(100),FacilityID int, FacilityName varchar(50),AvgS DECIMAL(10,2), AvgM DECIMAL(10,2), AvgH DECIMAL(10,2), LastUpdated date)

/* Bin Fill */
INSERT INTO @FactActivityTimes
select 
'Bin Fill' as Activity,
c.FacilityID,
df.FacilityName,
CAST(AVG(AllSecItem) AS DECIMAL(10,2)) as AvgS,
CAST(AVG(AllSecItem)/60 AS DECIMAL(10,2)) as AvgM,
CAST(AVG(AllSecItem)/360 AS DECIMAL(10,2)) as AvgH,
convert(Date,getdate()) as LastUpdated

from (
		select FacilityID,CAST(AVG(SecItem) AS DECIMAL(10,2)) as AllSecItem from (
			select FacilityID,DATEDIFF(s,StartTime,StopTime)/SKUS as SecItem from bluebin.TimeStudyBinFill where MostRecent = 1) as a
			group by FacilityID
		UNION 
		select FacilityID,CAST(AVG(SecItem) AS DECIMAL(10,2)) from (
			select FacilityID,DATEDIFF(s,StartTime,StopTime)/SKUS as SecItem from bluebin.TimeStudyBinFill where MostRecent = 0) as b
			group by FacilityID
		) as c 
		inner join bluebin.DimFacility df on c.FacilityID = df.FacilityID 
		group by c.FacilityID,df.FacilityName
		
/* Node Service */
INSERT INTO @FactActivityTimes
select 
'NodeService' as Activity,
c.FacilityID,
df.FacilityName,
CAST(AVG(AllSecItem) AS DECIMAL(10,2)) as AvgS,
CAST(AVG(AllSecItem)/60 AS DECIMAL(10,2)) as AvgM,
CAST(AVG(AllSecItem)/360 AS DECIMAL(10,2)) as AvgH,
convert(Date,getdate()) as LastUpdated
from (
		select FacilityID,CAST(AVG(SecItem) AS DECIMAL(10,2)) as AllSecItem from (
			select FacilityID,DATEDIFF(s,StartTime,StopTime)/SKUS as SecItem 
			from bluebin.TimeStudyNodeService 
			where TimeStudyProcessID = (Select ConfigID from bluebin.Config where ConfigName = 'Node Service' and ConfigValue = 'Node service time') 
			and MostRecent = 1) as a
			group by FacilityID
		UNION 
		select FacilityID,CAST(AVG(SecItem) AS DECIMAL(10,2)) from (
			select FacilityID,DATEDIFF(s,StartTime,StopTime)/SKUS as SecItem 
			from bluebin.TimeStudyNodeService 
			where  TimeStudyProcessID = (Select ConfigID from bluebin.Config where ConfigName = 'Node Service' and ConfigValue = 'Node service time')
			and MostRecent = 0) as b
			group by FacilityID
		) as c 
		inner join bluebin.DimFacility df on c.FacilityID = df.FacilityID 
		group by c.FacilityID,df.FacilityName

/* Travel Times All */
INSERT INTO @FactActivityTimes
select 
'TravelTimeAll' as Activity,
c.FacilityID,
df.FacilityName,
CAST(AVG(AllSecItem) AS DECIMAL(10,2)) as AvgS,
CAST(AVG(AllSecItem)/60 AS DECIMAL(10,2)) as AvgM,
CAST(AVG(AllSecItem)/360 AS DECIMAL(10,2)) as AvgH,
convert(Date,getdate()) as LastUpdated
from (
		select FacilityID,CAST(AVG(SecItem) AS DECIMAL(10,2)) as AllSecItem from (
			select FacilityID,DATEDIFF(s,StartTime,StopTime) as SecItem 
			from bluebin.TimeStudyNodeService 
			where TimeStudyProcessID in (Select ConfigID from bluebin.Config where ConfigName = 'Node Service' and ConfigValue in ('Travel Back to Stage','Travel time to next node','Leave Stage to enter node')) 
			and MostRecent = 1) as a
			group by FacilityID
		UNION 
		select FacilityID,CAST(AVG(SecItem) AS DECIMAL(10,2)) from (
			select FacilityID,DATEDIFF(s,StartTime,StopTime) as SecItem 
			from bluebin.TimeStudyNodeService 
			where  TimeStudyProcessID in (Select ConfigID from bluebin.Config where ConfigName = 'Node Service' and ConfigValue in ('Travel Back to Stage','Travel time to next node','Leave Stage to enter node'))
			and MostRecent = 0) as b
			group by FacilityID
		) as c 
		inner join bluebin.DimFacility df on c.FacilityID = df.FacilityID 
		group by c.FacilityID,df.FacilityName

/* Travel Times To Stage */
INSERT INTO @FactActivityTimes
select 
'TravelTimeToStage' as Activity,
c.FacilityID,
df.FacilityName,
CAST(AVG(AllSecItem) AS DECIMAL(10,2)) as AvgS,
CAST(AVG(AllSecItem)/60 AS DECIMAL(10,2)) as AvgM,
CAST(AVG(AllSecItem)/360 AS DECIMAL(10,2)) as AvgH,
convert(Date,getdate()) as LastUpdated
from (
		select FacilityID,CAST(AVG(SecItem) AS DECIMAL(10,2)) as AllSecItem from (
			select FacilityID,DATEDIFF(s,StartTime,StopTime) as SecItem 
			from bluebin.TimeStudyNodeService 
			where TimeStudyProcessID in (Select ConfigID from bluebin.Config where ConfigName = 'Node Service' and ConfigValue in ('Travel Back to Stage')) 
			and MostRecent = 1) as a
			group by FacilityID
		UNION 
		select FacilityID,CAST(AVG(SecItem) AS DECIMAL(10,2)) from (
			select FacilityID,DATEDIFF(s,StartTime,StopTime) as SecItem 
			from bluebin.TimeStudyNodeService 
			where  TimeStudyProcessID in (Select ConfigID from bluebin.Config where ConfigName = 'Node Service' and ConfigValue in ('Travel Back to Stage'))
			and MostRecent = 0) as b
			group by FacilityID
		) as c 
		inner join bluebin.DimFacility df on c.FacilityID = df.FacilityID 
		group by c.FacilityID,df.FacilityName


/* Travel Times Next Node */
INSERT INTO @FactActivityTimes
select 
'TravelTimeNextNode' as Activity,
c.FacilityID,
df.FacilityName,
CAST(AVG(AllSecItem) AS DECIMAL(10,2)) as AvgS,
CAST(AVG(AllSecItem)/60 AS DECIMAL(10,2)) as AvgM,
CAST(AVG(AllSecItem)/360 AS DECIMAL(10,2)) as AvgH,
convert(Date,getdate()) as LastUpdated
from (
		select FacilityID,CAST(AVG(SecItem) AS DECIMAL(10,2)) as AllSecItem from (
			select FacilityID,DATEDIFF(s,StartTime,StopTime) as SecItem 
			from bluebin.TimeStudyNodeService 
			where TimeStudyProcessID in (Select ConfigID from bluebin.Config where ConfigName = 'Node Service' and ConfigValue in ('Travel time to next node')) 
			and MostRecent = 1) as a
			group by FacilityID
		UNION 
		select FacilityID,CAST(AVG(SecItem) AS DECIMAL(10,2)) from (
			select FacilityID,DATEDIFF(s,StartTime,StopTime) as SecItem 
			from bluebin.TimeStudyNodeService 
			where  TimeStudyProcessID in (Select ConfigID from bluebin.Config where ConfigName = 'Node Service' and ConfigValue in ('Travel time to next node'))
			and MostRecent = 0) as b
			group by FacilityID
		) as c 
		inner join bluebin.DimFacility df on c.FacilityID = df.FacilityID 
		group by c.FacilityID,df.FacilityName

/* Travel Times From Stage */
INSERT INTO @FactActivityTimes
select 
'TravelTimeFromStage' as Activity,
c.FacilityID,
df.FacilityName,
CAST(AVG(AllSecItem) AS DECIMAL(10,2)) as AvgS,
CAST(AVG(AllSecItem)/60 AS DECIMAL(10,2)) as AvgM,
CAST(AVG(AllSecItem)/360 AS DECIMAL(10,2)) as AvgH,
convert(Date,getdate()) as LastUpdated
from (
		select FacilityID,CAST(AVG(SecItem) AS DECIMAL(10,2)) as AllSecItem from (
			select FacilityID,DATEDIFF(s,StartTime,StopTime) as SecItem 
			from bluebin.TimeStudyNodeService 
			where TimeStudyProcessID in (Select ConfigID from bluebin.Config where ConfigName = 'Node Service' and ConfigValue in ('Leave Stage to enter node')) 
			and MostRecent = 1) as a
			group by FacilityID
		UNION 
		select FacilityID,CAST(AVG(SecItem) AS DECIMAL(10,2)) from (
			select FacilityID,DATEDIFF(s,StartTime,StopTime) as SecItem 
			from bluebin.TimeStudyNodeService 
			where  TimeStudyProcessID in (Select ConfigID from bluebin.Config where ConfigName = 'Node Service' and ConfigValue in ('Leave Stage to enter node'))
			and MostRecent = 0) as b
			group by FacilityID
		) as c
		inner join bluebin.DimFacility df on c.FacilityID = df.FacilityID 
		group by c.FacilityID,df.FacilityName




declare @StoreroomPL DECIMAL(10,2) = (select max(ConfigValue) from bluebin.Config where ConfigName = 'Storeroom Pick Lines')  --default is seconds in Config
declare @ScanningBin DECIMAL(10,2) = (select max(ConfigValue) from bluebin.Config where ConfigName = 'Scanning Bin')  --default is seconds in Config
declare @ScanningTime DECIMAL(10,2) = (select max(ConfigValue) from bluebin.Config where ConfigName = 'Scanning Time')--default is minutes in Config
declare @ScanningNew DECIMAL(10,2) = (select max(ConfigValue) from bluebin.Config where ConfigName = 'Scan New Node')--default is minutes in Config
declare @ScanningMove DECIMAL(10,2) = (select max(ConfigValue) from bluebin.Config where ConfigName = 'Scanning Move')--default is minutes in Config
declare @ReturnsBinLg DECIMAL(10,2) = (select max(ConfigValue) from bluebin.Config where ConfigName = 'Returns Bins Large')--default is minutes in Config
declare @ReturnsBinSm DECIMAL(10,2) = (select max(ConfigValue) from bluebin.Config where ConfigName = 'Returns Bins Small') --default is minutes in Config
declare @ReturnsBinTH DECIMAL(10,2) = (select max(ConfigValue) from bluebin.Config where ConfigName = 'Returns Bins Threshhold')--default is Bin #s

--select @ScanningTime 
--select @ScanningNew 
--select @ScanningMove 
--select @ReturnsBinLg 
--select @ReturnsBinSm 
--select @ReturnsBinTH

/* Storeroom Pick Lines */
INSERT INTO @FactActivityTimes
select 
'Storeroom Pick Lines' as Activity,
df.FacilityID,
df.FacilityName,
CAST(AVG(@StoreroomPL) AS DECIMAL(10,2)) as AvgS,
CAST(AVG(@StoreroomPL)/60 AS DECIMAL(10,2)) as AvgM,
CAST(AVG(@StoreroomPL)/360 AS DECIMAL(10,2)) as AvgH,
convert(Date,getdate()) as LastUpdated
from bluebin.DimFacility df
inner join bluebin.DimLocation dl on df.FacilityID = dl.LocationFacility and dl.BlueBinFlag = 1
group by 
df.FacilityID,
df.FacilityName

/* Scanning Bin */
INSERT INTO @FactActivityTimes
select 
'Scanning Bin' as Activity,
df.FacilityID,
df.FacilityName,
CAST(AVG(@ScanningBin) AS DECIMAL(10,2)) as AvgS,
CAST(AVG(@ScanningBin)/60 AS DECIMAL(10,2)) as AvgM,
CAST(AVG(@ScanningBin)/360 AS DECIMAL(10,2)) as AvgH,
convert(Date,getdate()) as LastUpdated
from bluebin.DimFacility df
inner join bluebin.DimLocation dl on df.FacilityID = dl.LocationFacility and dl.BlueBinFlag = 1
group by 
df.FacilityID,
df.FacilityName

/* Scanning Time */
INSERT INTO @FactActivityTimes
select 
'Scanning Time' as Activity,
df.FacilityID,
df.FacilityName,
CAST(AVG(@ScanningTime)*60 AS DECIMAL(10,2)) as AvgS,
CAST(AVG(@ScanningTime) AS DECIMAL(10,2)) as AvgM,
CAST(AVG(@ScanningTime)/60 AS DECIMAL(10,2)) as AvgH,
convert(Date,getdate()) as LastUpdated
from bluebin.DimFacility df
inner join bluebin.DimLocation dl on df.FacilityID = dl.LocationFacility and dl.BlueBinFlag = 1
group by 
df.FacilityID,
df.FacilityName

/* Scanning Time for a New Node */
INSERT INTO @FactActivityTimes
select 
'Scanning New' as Activity,
df.FacilityID,
df.FacilityName,
CAST(AVG(@ScanningNew)*60 AS DECIMAL(10,2)) as AvgS,
CAST(AVG(@ScanningNew) AS DECIMAL(10,2)) as AvgM,
CAST(AVG(@ScanningNew)/60 AS DECIMAL(10,2)) as AvgH,
convert(Date,getdate()) as LastUpdated
from bluebin.DimFacility df
inner join bluebin.DimLocation dl on df.FacilityID = dl.LocationFacility and dl.BlueBinFlag = 1
group by 
df.FacilityID,
df.FacilityName

/* Scanning Move Computer between Nodes */
INSERT INTO @FactActivityTimes
select 
'Scanning Move' as Activity,
df.FacilityID,
df.FacilityName,
CAST(AVG(@ScanningMove)*60 AS DECIMAL(10,2)) as AvgS,
CAST(AVG(@ScanningMove) AS DECIMAL(10,2)) as AvgM,
CAST(AVG(@ScanningMove)/60 AS DECIMAL(10,2)) as AvgH,
convert(Date,getdate()) as LastUpdated
from bluebin.DimFacility df
inner join bluebin.DimLocation dl on df.FacilityID = dl.LocationFacility and dl.BlueBinFlag = 1
group by 
df.FacilityID,
df.FacilityName

/* Returns Bins Large */
INSERT INTO @FactActivityTimes
select 
'Returns Bins Large DEFAULT' as Activity,
df.FacilityID,
df.FacilityName,
CAST(AVG(@ReturnsBinLg)*60 AS DECIMAL(10,2)) as AvgS,
CAST(AVG(@ReturnsBinLg) AS DECIMAL(10,2)) as AvgM,
CAST(AVG(@ReturnsBinLg)/60 AS DECIMAL(10,2)) as AvgH,
convert(Date,getdate()) as LastUpdated
from bluebin.DimFacility df
inner join bluebin.DimLocation dl on df.FacilityID = dl.LocationFacility and dl.BlueBinFlag = 1
group by 
df.FacilityID,
df.FacilityName

/* Returns Bins Small */

INSERT INTO @FactActivityTimes
select 
'Returns Bins Small DEFAULT' as Activity,
df.FacilityID,
df.FacilityName,
CAST(AVG(@ReturnsBinSm)*60 AS DECIMAL(10,2)) as AvgS,
CAST(AVG(@ReturnsBinSm) AS DECIMAL(10,2)) as AvgM,
CAST(AVG(@ReturnsBinSm)/60 AS DECIMAL(10,2)) as AvgH,
convert(Date,getdate()) as LastUpdated
from bluebin.DimFacility df
inner join bluebin.DimLocation dl on df.FacilityID = dl.LocationFacility and dl.BlueBinFlag = 1
group by 
df.FacilityID,
df.FacilityName

/* Returns Bins Threshhold */
INSERT INTO @FactActivityTimes
select 
'Returns Bins Threshhold' as Activity,
df.FacilityID,
df.FacilityName,
CAST(AVG(@ReturnsBinTH)*60 AS DECIMAL(10,2)) as AvgS,
CAST(AVG(@ReturnsBinTH) AS DECIMAL(10,2)) as AvgM,
CAST(AVG(@ReturnsBinTH)/60 AS DECIMAL(10,2)) as AvgH,
convert(Date,getdate()) as LastUpdated
from bluebin.DimFacility df
inner join bluebin.DimLocation dl on df.FacilityID = dl.LocationFacility and dl.BlueBinFlag = 1
group by 
df.FacilityID,
df.FacilityName


/* Returns Bins Small */
INSERT INTO @FactActivityTimes
select 
'Returns Bins Small' as Activity,
df.FacilityID,
df.FacilityName,
case when CAST(AVG(AllSecItem) AS DECIMAL(10,2)) = 0 or CAST(AVG(AllSecItem) AS DECIMAL(10,2)) is null then CAST(AVG(@ReturnsBinSm)*60 AS DECIMAL(10,2)) else CAST(AVG(AllSecItem) AS DECIMAL(10,2)) end as AvgS,
case when CAST(AVG(AllSecItem)/60 AS DECIMAL(10,2)) = 0 or CAST(AVG(AllSecItem) AS DECIMAL(10,2)) is null then CAST(AVG(@ReturnsBinSm) AS DECIMAL(10,2)) else CAST(AVG(AllSecItem)/60 AS DECIMAL(10,2)) end as AvgM,
case when CAST(AVG(AllSecItem)/360 AS DECIMAL(10,2)) = 0 or CAST(AVG(AllSecItem) AS DECIMAL(10,2)) is null then CAST(AVG(@ReturnsBinSm)/60 AS DECIMAL(10,2)) else CAST(AVG(AllSecItem)/360 AS DECIMAL(10,2)) end as AvgH,
convert(Date,getdate()) as LastUpdated
from (
		select FacilityID,CAST(AVG(SecItem) AS DECIMAL(10,2)) as AllSecItem from (
			select FacilityID,DATEDIFF(s,StartTime,StopTime) as SecItem 
			from bluebin.TimeStudyNodeService 
			where TimeStudyProcessID in (Select ConfigID from bluebin.Config where ConfigName = 'Node Service' and ConfigValue in ('Returns bin time')) 
			and MostRecent = 1
			and SKUS <= @ReturnsBinTH) as a
			group by FacilityID
		UNION 
		select FacilityID,CAST(AVG(SecItem) AS DECIMAL(10,2)) from (
			select FacilityID,DATEDIFF(s,StartTime,StopTime) as SecItem 
			from bluebin.TimeStudyNodeService 
			where  TimeStudyProcessID in (Select ConfigID from bluebin.Config where ConfigName = 'Node Service' and ConfigValue in ('Returns bin time'))
			and MostRecent = 0
			and SKUS <=@ReturnsBinTH) as b
			group by FacilityID
		) as c 
		right join bluebin.DimFacility df on c.FacilityID = df.FacilityID
		inner join bluebin.DimLocation dl on df.FacilityID = dl.LocationFacility and dl.BlueBinFlag = 1 
		group by df.FacilityID,df.FacilityName
		 
/* Returns Bins Large */

INSERT INTO @FactActivityTimes
select 
'Returns Bins Large' as Activity,
df.FacilityID,
df.FacilityName,
case when CAST(AVG(AllSecItem) AS DECIMAL(10,2)) = 0 or CAST(AVG(AllSecItem) AS DECIMAL(10,2)) is null then CAST(AVG(@ReturnsBinLg)*60 AS DECIMAL(10,2)) else CAST(AVG(AllSecItem) AS DECIMAL(10,2)) end as AvgS,
case when CAST(AVG(AllSecItem)/60 AS DECIMAL(10,2)) = 0 or CAST(AVG(AllSecItem) AS DECIMAL(10,2)) is null then CAST(AVG(@ReturnsBinLg) AS DECIMAL(10,2)) else CAST(AVG(AllSecItem)/60 AS DECIMAL(10,2)) end as AvgM,
case when CAST(AVG(AllSecItem)/360 AS DECIMAL(10,2)) = 0 or CAST(AVG(AllSecItem) AS DECIMAL(10,2)) is null then CAST(AVG(@ReturnsBinLg)/60 AS DECIMAL(10,2)) else CAST(AVG(AllSecItem)/360 AS DECIMAL(10,2)) end as AvgH,
convert(Date,getdate()) as LastUpdated
from (
		select FacilityID,CAST(AVG(SecItem) AS DECIMAL(10,2)) as AllSecItem from (
			select FacilityID,DATEDIFF(s,StartTime,StopTime) as SecItem 
			from bluebin.TimeStudyNodeService 
			where TimeStudyProcessID in (Select ConfigID from bluebin.Config where ConfigName = 'Node Service' and ConfigValue in ('Returns bin time')) 
			and MostRecent = 1
			and SKUS > @ReturnsBinTH) as a
			group by FacilityID
		UNION 
		select FacilityID,CAST(AVG(SecItem) AS DECIMAL(10,2)) from (
			select FacilityID,DATEDIFF(s,StartTime,StopTime) as SecItem 
			from bluebin.TimeStudyNodeService 
			where  TimeStudyProcessID in (Select ConfigID from bluebin.Config where ConfigName = 'Node Service' and ConfigValue in ('Returns bin time'))
			and MostRecent = 0
			and SKUS > @ReturnsBinTH) as b
			group by FacilityID
		) as c 
		right join bluebin.DimFacility df on c.FacilityID = df.FacilityID
		inner join bluebin.DimLocation dl on df.FacilityID = dl.LocationFacility and dl.BlueBinFlag = 1 
		group by df.FacilityID,df.FacilityName



/* Double Bin StockOut Sweep*/

INSERT INTO @FactActivityTimes
select 
'Double Bin StockOut Sweep' as Activity,
c.FacilityID,
df.FacilityName,
CAST(AVG(AllSecItem) AS DECIMAL(10,2)) as AvgS,
CAST(AVG(AllSecItem)/60 AS DECIMAL(10,2)) as AvgM,
CAST(AVG(AllSecItem)/360 AS DECIMAL(10,2)) as AvgH,
convert(Date,getdate()) as LastUpdated
from (
		select FacilityID,CAST(AVG(SecItem) AS DECIMAL(10,2)) as AllSecItem from (
			select FacilityID,DATEDIFF(s,StartTime,StopTime)/SKUS as SecItem 
			from bluebin.TimeStudyStockOut 
			where TimeStudyProcessID in (Select ConfigID from bluebin.Config where ConfigName = 'Double Bin StockOut' 
			and ConfigValue in ('Write down Item numbers and sweep Stage')) 
			and MostRecent = 1) as a
			group by FacilityID
		UNION 
		select FacilityID,CAST(AVG(SecItem) AS DECIMAL(10,2)) from (
			select FacilityID,DATEDIFF(s,StartTime,StopTime)/SKUS as SecItem 
			from bluebin.TimeStudyStockOut 
			where  TimeStudyProcessID in (Select ConfigID from bluebin.Config where ConfigName = 'Double Bin StockOut' 
			and ConfigValue in ('Write down Item numbers and sweep Stage'))
			and MostRecent = 0) as b
			group by FacilityID
		) as c 
		inner join bluebin.DimFacility df on c.FacilityID = df.FacilityID 
		group by c.FacilityID,df.FacilityName

/* Double Bin StockOut Key out */

INSERT INTO @FactActivityTimes
select 
'Double Bin StockOut Key out' as Activity,
c.FacilityID,
df.FacilityName,
CAST(AVG(AllSecItem) AS DECIMAL(10,2)) as AvgS,
CAST(AVG(AllSecItem)/60 AS DECIMAL(10,2)) as AvgM,
CAST(AVG(AllSecItem)/360 AS DECIMAL(10,2)) as AvgH,
convert(Date,getdate()) as LastUpdated
from (
		select FacilityID,CAST(AVG(SecItem) AS DECIMAL(10,2)) as AllSecItem from (
			select FacilityID,DATEDIFF(s,StartTime,StopTime)/SKUS as SecItem 
			from bluebin.TimeStudyStockOut 
			where TimeStudyProcessID in (Select ConfigID from bluebin.Config where ConfigName = 'Double Bin StockOut' 
			and ConfigValue in ('Key out MSR')) 
			and MostRecent = 1) as a
			group by FacilityID
		UNION 
		select FacilityID,CAST(AVG(SecItem) AS DECIMAL(10,2)) from (
			select FacilityID,DATEDIFF(s,StartTime,StopTime)/SKUS as SecItem 
			from bluebin.TimeStudyStockOut 
			where  TimeStudyProcessID in (Select ConfigID from bluebin.Config where ConfigName = 'Double Bin StockOut' 
			and ConfigValue in ('Key out MSR'))
			and MostRecent = 0) as b
			group by FacilityID
		) as c 
		inner join bluebin.DimFacility df on c.FacilityID = df.FacilityID 
		group by c.FacilityID,df.FacilityName


/* Double Bin StockOut Pick Items */

INSERT INTO @FactActivityTimes
select 
'Double Bin StockOut Pick Items' as Activity,
c.FacilityID,
df.FacilityName,
CAST(AVG(AllSecItem) AS DECIMAL(10,2)) as AvgS,
CAST(AVG(AllSecItem)/60 AS DECIMAL(10,2)) as AvgM,
CAST(AVG(AllSecItem)/360 AS DECIMAL(10,2)) as AvgH,
convert(Date,getdate()) as LastUpdated
from (
		select FacilityID,CAST(AVG(SecItem) AS DECIMAL(10,2)) as AllSecItem from (
			select FacilityID,DATEDIFF(s,StartTime,StopTime)/SKUS as SecItem 
			from bluebin.TimeStudyStockOut 
			where TimeStudyProcessID in (Select ConfigID from bluebin.Config where ConfigName = 'Double Bin StockOut' 
			and ConfigValue in ('Pick Items')) 
			and MostRecent = 1) as a
			group by FacilityID
		UNION 
		select FacilityID,CAST(AVG(SecItem) AS DECIMAL(10,2)) from (
			select FacilityID,DATEDIFF(s,StartTime,StopTime)/SKUS as SecItem 
			from bluebin.TimeStudyStockOut 
			where  TimeStudyProcessID in (Select ConfigID from bluebin.Config where ConfigName = 'Double Bin StockOut' 
			and ConfigValue in ('Pick Items'))
			and MostRecent = 0) as b
			group by FacilityID
		) as c 
		inner join bluebin.DimFacility df on c.FacilityID = df.FacilityID 
		group by c.FacilityID,df.FacilityName


/* Double Bin StockOut Deliver Items */

INSERT INTO @FactActivityTimes
select 
'Double Bin StockOut Deliver Items' as Activity,
c.FacilityID,
df.FacilityName,
CAST(AVG(AllSecItem) AS DECIMAL(10,2)) as AvgS,
CAST(AVG(AllSecItem)/60 AS DECIMAL(10,2)) as AvgM,
CAST(AVG(AllSecItem)/360 AS DECIMAL(10,2)) as AvgH,
convert(Date,getdate()) as LastUpdated
from (
		select FacilityID,CAST(AVG(SecItem) AS DECIMAL(10,2)) as AllSecItem from (
			select FacilityID,DATEDIFF(s,StartTime,StopTime)/SKUS as SecItem 
			from bluebin.TimeStudyStockOut 
			where TimeStudyProcessID in (Select ConfigID from bluebin.Config where ConfigName = 'Double Bin StockOut' 
			and ConfigValue in ('Deliver Items')) 
			and MostRecent = 1
			) as a
			group by FacilityID
		UNION 
		select FacilityID,CAST(AVG(SecItem) AS DECIMAL(10,2)) from (
			select FacilityID,DATEDIFF(s,StartTime,StopTime)/SKUS as SecItem 
			from bluebin.TimeStudyStockOut 
			where  TimeStudyProcessID in (Select ConfigID from bluebin.Config where ConfigName = 'Double Bin StockOut' 
			and ConfigValue in ('Deliver Items'))
			and MostRecent = 0) as b
			group by FacilityID
		) as c 
		inner join bluebin.DimFacility df on c.FacilityID = df.FacilityID 
		group by c.FacilityID,df.FacilityName
/* Double Bin StockOut All */

INSERT INTO @FactActivityTimes
select 
'Double Bin StockOut All' as Activity,
FacilityID,
FacilityName,
SUM(AvgS) as AvgS,
SUM(AvgM) as AvgS,
SUM(AvgH) as AvgS,
convert(Date,getdate()) as LastUpdated
from @FactActivityTimes
where Activity like 'Double Bin%'
group by
FacilityID,
FacilityName

select * 
into bluebin.FactActivityTimes
from @FactActivityTimes

UPDATE etl.JobSteps
SET LastModifiedDate = GETDATE()
WHERE StepName = 'FactActivityTimes'

GO