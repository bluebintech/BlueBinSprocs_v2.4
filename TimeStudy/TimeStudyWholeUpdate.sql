/*
drop table [bluebin].[TimeStudyStageScan]
drop table [bluebin].[TimeStudyStockOut]
drop table [bluebin].[TimeStudyNodeService]
drop table [bluebin].[TimeStudyBinFill]
drop table [bluebin].[TimeStudyGroup]
*/

if not exists(select * from etl.JobSteps where StepName = 'FactActivityTimes')  
BEGIN
insert into etl.JobSteps (StepNumber,StepName,StepProcedure,StepTable,ActiveFlag,LastModifiedDate) VALUES ((select max(StepNumber) +1 from etl.JobSteps),'FactActivityTimes','etl_FactActivityTimes','bluebin.FactActivityTimes','0',getdate())
END
GO

if not exists(select * from bluebin.BlueBinOperations where OpName ='MENU-TimeStudy')  
BEGIN
Insert into bluebin.BlueBinOperations (OpName,[Description]) VALUES
('MENU-TimeStudy','Give User ability to see Time Study Module and Subs Modules in Ops')
END
GO

if not exists(select * from bluebin.BlueBinOperations where OpName ='MENU-TimeStudy-EDIT')  
BEGIN
Insert into bluebin.BlueBinOperations (OpName,[Description]) VALUES
('MENU-TimeStudy-EDIT','Give User ability to see Time Study Module and Subs Modules in Ops and Edit')
END
GO

if not exists (select * from bluebin.BlueBinRoleOperations where OpID in (select OpID from bluebin.BlueBinOperations where OpName like 'MENU-TimeStudy%'))
BEGIN  
insert into bluebin.BlueBinRoleOperations select RoleID,(select OpID from bluebin.BlueBinOperations where OpName ='MENU-TimeStudy') from bluebin.BlueBinRoles where RoleName like 'BlueBin%'
insert into bluebin.BlueBinRoleOperations select RoleID,(select OpID from bluebin.BlueBinOperations where OpName ='MENU-TimeStudy-EDIT') from bluebin.BlueBinRoles where RoleName like 'BlueBin%'
END

if not exists(select * from bluebin.Config where ConfigName = 'MENU-TimeStudy')  
BEGIN
insert into bluebin.Config (ConfigName,ConfigValue,Active,LastUpdated,ConfigType,[Description])
select 'MENU-TimeStudy','0',1,getdate(),'DMS','Time Study Modules are available for this client. Default=0 (Boolean 0 is No, 1 is Yes)'
END
GO

if not exists(select * from bluebin.Config where ConfigType = 'Reports' and ConfigName like 'OP-Time Study%')  
BEGIN
insert into bluebin.Config (ConfigName,ConfigValue,Active,LastUpdated,ConfigType,[Description]) VALUES
('OP-Time Study Activity Times','0',1,getdate(),'Reports','Setting for whether to display the Time Study Activity Times'),
('OP-Time Study Averages','0',1,getdate(),'Reports','Setting for whether to display the Time Study Averages Times for Orders'),
('OP-Time Study Planner','0',1,getdate(),'Reports','Setting for whether to display the Time Study FTE Planner'),
('OP-Time Study Dashboard','0',1,getdate(),'Reports','Setting for whether to display the Time Study Dashboard (Detail)')
END


if not exists(select * from bluebin.Config where ConfigName like 'Double Bin StockOut')  
BEGIN
insert into bluebin.Config (ConfigName,ConfigValue,ConfigType,Active,LastUpdated,[Description]) VALUES
('Double Bin StockOut','Write down Item numbers and sweep Stage','TimeStudy',1,getdate(),'Write down Item numbers and sweep Stage')
insert into bluebin.Config (ConfigName,ConfigValue,ConfigType,Active,LastUpdated,[Description]) VALUES
('Double Bin StockOut','Key out MSR','TimeStudy',1,getdate(),'Key out MSR')
insert into bluebin.Config (ConfigName,ConfigValue,ConfigType,Active,LastUpdated,[Description]) VALUES
('Double Bin StockOut','Pick Items','TimeStudy',1,getdate(),'Pick Items')
insert into bluebin.Config (ConfigName,ConfigValue,ConfigType,Active,LastUpdated,[Description]) VALUES
('Double Bin StockOut','Deliver Items','TimeStudy',1,getdate(),'Deliver Items')
END
GO

if not exists(select * from bluebin.Config where ConfigName like 'Node Service')  
BEGIN
insert into bluebin.Config (ConfigName,ConfigValue,ConfigType,Active,LastUpdated,[Description]) VALUES
('Node Service','Travel Back to Stage','TimeStudy',1,getdate(),'Time to go from Node back to Stage Area')
insert into bluebin.Config (ConfigName,ConfigValue,ConfigType,Active,LastUpdated,[Description]) VALUES
('Node Service','Leave Stage to enter node','TimeStudy',1,getdate(),'Leave Stage to enter node')
insert into bluebin.Config (ConfigName,ConfigValue,ConfigType,Active,LastUpdated,[Description]) VALUES
('Node Service','Node service time','TimeStudy',1,getdate(),'Node service time')
insert into bluebin.Config (ConfigName,ConfigValue,ConfigType,Active,LastUpdated,[Description]) VALUES
('Node Service','Returns bin time','TimeStudy',1,getdate(),'Returns bin time')
insert into bluebin.Config (ConfigName,ConfigValue,ConfigType,Active,LastUpdated,[Description]) VALUES
('Node Service','Travel time to next node','TimeStudy',1,getdate(),'Travel time to next node')
END
GO

if not exists(select * from bluebin.Config where ConfigName like 'Stat Calls')  
BEGIN
insert into bluebin.Config (ConfigName,ConfigValue,ConfigType,Active,LastUpdated,[Description]) VALUES
('Stat Calls','Travel to WH','TimeStudy',1,getdate(),'Travel to WH')
insert into bluebin.Config (ConfigName,ConfigValue,ConfigType,Active,LastUpdated,[Description]) VALUES
('Stat Calls','Pick Product','TimeStudy',1,getdate(),'Pick Product')
insert into bluebin.Config (ConfigName,ConfigValue,ConfigType,Active,LastUpdated,[Description]) VALUES
('Stat Calls','Paperwork','TimeStudy',1,getdate(),'Paperwork')
insert into bluebin.Config (ConfigName,ConfigValue,ConfigType,Active,LastUpdated,[Description]) VALUES
('Stat Calls','Deliver Product','TimeStudy',1,getdate(),'Deliver Product')
END
GO


if not exists(select * from bluebin.Config where ConfigName like 'Storeroom Pick Lines')  
BEGIN
insert into bluebin.Config (ConfigName,ConfigValue,ConfigType,Active,LastUpdated,[Description]) VALUES
('Storeroom Pick Lines','25','TimeStudy',1,getdate(),'Avg Time to Pick an Order in Storeroom in seconds')
END
GO

if not exists(select * from bluebin.Config where ConfigName like 'Scanning Bin')  
BEGIN
insert into bluebin.Config (ConfigName,ConfigValue,ConfigType,Active,LastUpdated,[Description]) VALUES
('Scanning Bin','1.5','TimeStudy',1,getdate(),'Average Time to Scan each Bin in seconds')
END
GO

if not exists(select * from bluebin.Config where ConfigName like 'Scanning Time')  
BEGIN
insert into bluebin.Config (ConfigName,ConfigValue,ConfigType,Active,LastUpdated,[Description]) VALUES
('Scanning Time','1.1','TimeStudy',1,getdate(),'Average Time to Scan Bins in minutes')
END
GO

if not exists(select * from bluebin.Config where ConfigName like 'Scan New Node')  
BEGIN
insert into bluebin.Config (ConfigName,ConfigValue,ConfigType,Active,LastUpdated,[Description]) VALUES
('Scan New Node','1','TimeStudy',1,getdate(),'Average Time to Scan a New Node in minutes')
END
GO

if not exists(select * from bluebin.Config where ConfigName like 'Scanning Move')  
BEGIN
insert into bluebin.Config (ConfigName,ConfigValue,ConfigType,Active,LastUpdated,[Description]) VALUES
('Scanning Move','.75','TimeStudy',1,getdate(),'Average Time to move computer on wheels between nodes in minutes')
END
GO

if not exists(select * from bluebin.Config where ConfigName like 'Returns Bin Small')  
BEGIN
insert into bluebin.Config (ConfigName,ConfigValue,ConfigType,Active,LastUpdated,[Description]) VALUES
('Returns Bins Small','1.86','TimeStudy',1,getdate(),'Average Time to Returns Bin Small based on Returns Bins Threshold (Less) minutes')
END
GO

if not exists(select * from bluebin.Config where ConfigName like 'Returns Bin Large')  
BEGIN
insert into bluebin.Config (ConfigName,ConfigValue,ConfigType,Active,LastUpdated,[Description]) VALUES
('Returns Bin Large','2.30','TimeStudy',1,getdate(),'Average Time to Returns Bin Large based on Returns Bins Threshold (Greater) minutes')
END
GO

if not exists(select * from bluebin.Config where ConfigName like 'Returns Bin Threshhold')  
BEGIN
insert into bluebin.Config (ConfigName,ConfigValue,ConfigType,Active,LastUpdated,[Description]) VALUES
('Returns Bins Threshhold','8','TimeStudy',1,getdate(),'Threshhold for Returns Bins to go Large (GT) or Small (LT EQ)')
END
GO

if not exists(select * from bluebin.Config where ConfigName = 'Efficiency Factor')  
BEGIN
insert into bluebin.Config (ConfigName,ConfigValue,Active,LastUpdated,ConfigType,[Description])
select 'Efficiency Factor','.75','1',getdate(),'TimeStudy','Set Productivity Planner Efficiency Factor for FTE Equivalent calculations. Default-.75'
END
GO


SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

/****** Object:  Table [bluebin].[TimeStudyStageScan]     ******/

if not exists (select * from sys.tables where name = 'TimeStudyStageScan')
BEGIN
CREATE TABLE [bluebin].[TimeStudyStageScan](
	[TimeStudyStageScanID] INT NOT NULL IDENTITY(1,1)  PRIMARY KEY,
	[Date] datetime NOT NULL,
	[FacilityID] int NOT NULL,
	[LocationID] varchar(10) NOT NULL,
	[StartTime] DateTime NOT NULL,
	[StopTime] Datetime NOT NULL,
	[SKUS] int NOT NULL,
	[Comments] varchar(max) NULL,
	[BlueBinUserID] int NOT NULL,
	[BlueBinResourceID] int NULL,
	[MostRecent] int NOT NULL,
	[Active] int NOT NULL,
	[LastUpdated] datetime NOT NULL
	
)
END
GO


/****** Object:  Table [bluebin].[TimeStudyBinFill]     ******/
if not exists (select * from sys.tables where name = 'TimeStudyBinFill')
BEGIN
CREATE TABLE [bluebin].[TimeStudyBinFill](
	[TimeStudyBinFillID] INT NOT NULL IDENTITY(1,1)  PRIMARY KEY,
	[Date] datetime NOT NULL,
	[FacilityID] int NOT NULL,
	[LocationID] varchar(10) NOT NULL,
	[StartTime] DateTime NOT NULL,
	[StopTime] Datetime NOT NULL,
	[SKUS] int NOT NULL,
	[Comments] varchar(max) NULL,
	[BlueBinUserID] int NOT NULL,
	[BlueBinResourceID] int NULL,
	[MostRecent] int NOT NULL,
	[Active] int NOT NULL,
	[LastUpdated] datetime NOT NULL
)


END
GO

/****** Object:  Table [bluebin].[TimeStudyStockOut]     ******/
if not exists (select * from sys.tables where name = 'TimeStudyStockOut')
BEGIN
CREATE TABLE [bluebin].[TimeStudyStockOut](
	[TimeStudyStockOutID] INT NOT NULL IDENTITY(1,1)  PRIMARY KEY,
	[Date] datetime NOT NULL,
	[FacilityID] int NOT NULL,
	[LocationID] varchar(10) NULL,	
	[TimeStudyProcessID] int NOT NULL,
	[StartTime] DateTime NOT NULL,
	[StopTime] Datetime NOT NULL,
	[SKUS] int NOT NULL,
	[Comments] varchar(max) NULL,
	[BlueBinUserID] int NOT NULL,
	[BlueBinResourceID] int NULL,
	[MostRecent] int NOT NULL,
	[Active] int NOT NULL,
    [LastUpdated] datetime NOT NULL
)


END
GO

/****** Object:  Table [bluebin].[TimeStudyNodeService]     ******/
if not exists (select * from sys.tables where name = 'TimeStudyNodeService')
BEGIN
CREATE TABLE [bluebin].[TimeStudyNodeService](
	[TimeStudyNodeServiceID] INT NOT NULL IDENTITY(1,1)  PRIMARY KEY,
	[Date] datetime NOT NULL,
	[FacilityID] int NOT NULL,
	[LocationID] varchar(10) NOT NULL,
	[TravelLocationID] varchar(10) NOT NULL,
	[TimeStudyProcessID] int NOT NULL,
	[StartTime] DateTime NOT NULL,
	[StopTime] Datetime NOT NULL,
	[SKUS] int NOT NULL,
	[Comments] varchar(max) NULL,
	[BlueBinUserID] int NOT NULL,
	[BlueBinResourceID] int NULL,
	[MostRecent] int NOT NULL,
	[Active] int NOT NULL,
	[LastUpdated] datetime NOT NULL
)


END
GO

--/****** Object:  Table [bluebin].[TimeStudyProcess]     ******/
--if not exists (select * from sys.tables where name = 'TimeStudyProcess')
--BEGIN
--CREATE TABLE [bluebin].[TimeStudyProcess](
--	[TimeStudyProcessID] INT NOT NULL IDENTITY(1,1)  PRIMARY KEY,
--	[ProcessType] varchar (100) NOT NULL,
--	[ProcessName] varchar (100) NOT NULL,
--	[ProcessValue] varchar (100) NULL,
--	[Description] varchar(255) NULL,
--	[Active] int NOT NULL,
--	[LastUpdated] datetime NOT NULL
--)


--END
--GO

/****** Object:  Table [bluebin].[TimeStudyGroup]     ******/
if not exists (select * from sys.tables where name = 'TimeStudyGroup')
BEGIN
CREATE TABLE [bluebin].[TimeStudyGroup](
[TimeStudyGroupID] INT NOT NULL IDENTITY(1,1)  PRIMARY KEY,
	[FacilityID] int NOT NULL,
	[LocationID] varchar(10) NOT NULL,
	[GroupName] varchar(50) NOT NULL,
	[Description] varchar(255) NULL,
	[Active] int NOT NULL,
	[LastUpdated] datetime NOT NULL
)


END
GO



--*****************************************************
--**************************SPROC**********************

if exists (select * from dbo.sysobjects where id = object_id(N'sp_SelectTimeStudyStockOutEdit') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_SelectTimeStudyStockOutEdit
GO

--exec sp_SelectTimeStudyStockOutEdit 'TEST'

CREATE PROCEDURE sp_SelectTimeStudyStockOutEdit
@TimeStudyStockOutID int



--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON
	
select
	[TimeStudyStockOutID] ,
	[Date] ,
	[FacilityID],
	[LocationID],
	[TimeStudyProcessID],
	convert(varchar(2),DATEPART(hh,StartTime))+':'+right(('0' + convert(varchar(2),DATEPART(mi,StartTime))),2) as StartTime,
	convert(varchar(2),DATEPART(hh,StopTime))+':'+right(('0' + convert(varchar(2),DATEPART(mi,StopTime))),2) as StopTime,
	[SKUS],
	[Comments],
	[BlueBinUserID] ,
	[BlueBinResourceID]

FROM bluebin.TimeStudyStockOut t
WHERE [TimeStudyStockOutID] = @TimeStudyStockOutID 
				

END
GO
grant exec on sp_SelectTimeStudyStockOutEdit to appusers
GO







--*****************************************************
--**************************SPROC**********************

if exists (select * from dbo.sysobjects where id = object_id(N'sp_SelectTimeStudyStockOut') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_SelectTimeStudyStockOut
GO

--select * from bluebin.TimeStudyStockOut
--exec sp_SelectTimeStudyStockOut '%','%','%','2' 

CREATE PROCEDURE sp_SelectTimeStudyStockOut
@FacilityName varchar(50)
,@LocationName varchar(50)
,@UserName varchar(50)
,@MostRecent int

--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON

declare @MostRecent2 int
if @MostRecent = 2 
BEGIN
set @MostRecent = 0
set @MostRecent2 = 1
END

select
'Time Study Stock Out' as TimeStudy,
t.TimeStudyStockOutID,
t.Date,
df.FacilityName,
dl.LocationID,
dl.LocationName,
bbu.LastName + ', ' + bbu.FirstName as SubmittedBy,
ISNULL(bbr.LastName + ', ' + bbr.FirstName,'') as ServiceTech,
case when t.MostRecent = '1' then 'Yes' else 'No' end as MostRecent,
c.ConfigValue as ProcessName,
t.SKUS,
DATEDIFF(ss,t.StartTime,t.StopTime) as [Seconds],
DATEDIFF(mi,t.StartTime,t.StopTime) as [Minutes]

FROM bluebin.TimeStudyStockOut t
inner join bluebin.Config c on t.TimeStudyProcessID = c.ConfigID and c.ConfigType = 'TimeStudy'
left join bluebin.DimLocation dl on t.LocationID = dl.LocationID and t.FacilityID = dl.LocationFacility
inner join bluebin.DimFacility df on t.FacilityID = df.FacilityID
inner join bluebin.BlueBinUser bbu on t.BlueBinUserID = bbu.BlueBinUserID
left join bluebin.BlueBinResource bbr on t.BlueBinResourceID = bbr.BlueBinResourceID
where t.Active = 1
and df.FacilityName like '%' + @FacilityName + '%'
and (dl.LocationID + ' - ' + dl.[LocationName] LIKE '%' + @LocationName + '%' or t.LocationID like '%' + @LocationName + '%')
and t.MostRecent in (@MostRecent,@MostRecent2)
and case	
	when @UserName <> '%' then bbu.LastName + ', ' + bbu.FirstName else '' end LIKE  '%' + @UserName + '%'

END
GO
grant exec on sp_SelectTimeStudyStockOut to appusers
GO





--*****************************************************
--**************************SPROC**********************

if exists (select * from dbo.sysobjects where id = object_id(N'sp_SelectTimeStudyStageScanEdit') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_SelectTimeStudyStageScanEdit
GO

--exec sp_SelectTimeStudyStageScanEdit 'TEST'

CREATE PROCEDURE sp_SelectTimeStudyStageScanEdit
@TimeStudyStageScanID int


--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON
	
select
	[TimeStudyStageScanID] ,
	[Date] ,
	[FacilityID],
	[LocationID],
	convert(varchar(2),DATEPART(hh,StartTime))+':'+right(('0' + convert(varchar(2),DATEPART(mi,StartTime))),2) as StartTime,
	convert(varchar(2),DATEPART(hh,StopTime))+':'+right(('0' + convert(varchar(2),DATEPART(mi,StopTime))),2) as StopTime,
	[SKUS],
	[Comments],
	[BlueBinUserID] ,
	[BlueBinResourceID]

FROM bluebin.TimeStudyStageScan t

WHERE [TimeStudyStageScanID] = @TimeStudyStageScanID 
				

END
GO
grant exec on sp_SelectTimeStudyStageScanEdit to appusers
GO




--*****************************************************
--**************************SPROC**********************

if exists (select * from dbo.sysobjects where id = object_id(N'sp_SelectTimeStudyStageScan') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_SelectTimeStudyStageScan
GO

--select * from bluebin.TimeStudyStageScan
--exec sp_SelectTimeStudyStageScan '%','%','%','2' 

CREATE PROCEDURE sp_SelectTimeStudyStageScan
@FacilityName varchar(50)
,@LocationName varchar(50)
,@UserName varchar(50)
,@MostRecent int

--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON

declare @MostRecent2 int
if @MostRecent = 2 
BEGIN
set @MostRecent = 0
set @MostRecent2 = 1
END

select
'Time Study Stage Scanning' as TimeStudy,
t.TimeStudyStageScanID,
t.Date,
df.FacilityName,
dl.LocationID,
case
		when t.[LocationID] = 'Multiple' then t.LocationID
		else case	when dl.LocationID = dl.LocationName then dl.LocationID
					else dl.LocationID + ' - ' + dl.[LocationName] end end as LocationName,
bbu.LastName + ', ' + bbu.FirstName as SubmittedBy,
ISNULL(bbr.LastName + ', ' + bbr.FirstName,'') as ServiceTech,
case when t.MostRecent = '1' then 'Yes' else 'No' end as MostRecent,
t.SKUS,
DATEDIFF(ss,t.StartTime,t.StopTime) as [Seconds],
DATEDIFF(mi,t.StartTime,t.StopTime) as [Minutes]

FROM bluebin.TimeStudyStageScan t
inner join bluebin.DimLocation dl on t.LocationID = dl.LocationID and t.FacilityID = dl.LocationFacility
inner join bluebin.DimFacility df on t.FacilityID = df.FacilityID
inner join bluebin.BlueBinUser bbu on t.BlueBinUserID = bbu.BlueBinUserID
left join bluebin.BlueBinResource bbr on t.BlueBinResourceID = bbr.BlueBinResourceID
where t.Active = 1
and df.FacilityName like '%' + @FacilityName + '%'
and (dl.LocationID + ' - ' + dl.[LocationName] LIKE '%' + @LocationName + '%' or t.LocationID like '%' + @LocationName + '%')
and t.MostRecent in (@MostRecent,@MostRecent2)
and case	
	when @UserName <> '%' then bbu.LastName + ', ' + bbu.FirstName else '' end LIKE  '%' + @UserName + '%'

END
GO
grant exec on sp_SelectTimeStudyStageScan to appusers
GO




--*****************************************************
--**************************SPROC**********************

if exists (select * from dbo.sysobjects where id = object_id(N'sp_SelectTimeStudyNodeServiceEdit') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_SelectTimeStudyNodeServiceEdit
GO

--exec sp_SelectTimeStudyNodeServiceEdit 'TEST'

CREATE PROCEDURE sp_SelectTimeStudyNodeServiceEdit
@TimeStudyNodeServiceID int



--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON
	
select
	[TimeStudyNodeServiceID] ,
	[Date] ,
	[FacilityID],
	[LocationID],
	[TravelLocationID],
	[TimeStudyProcessID],
	convert(varchar(2),DATEPART(hh,StartTime))+':'+right(('0' + convert(varchar(2),DATEPART(mi,StartTime))),2) as StartTime,
	convert(varchar(2),DATEPART(hh,StopTime))+':'+right(('0' + convert(varchar(2),DATEPART(mi,StopTime))),2) as StopTime,
	[SKUS],
	[Comments],
	[BlueBinUserID] ,
	[BlueBinResourceID]

FROM bluebin.TimeStudyNodeService t

WHERE [TimeStudyNodeServiceID] = @TimeStudyNodeServiceID 
				

END
GO
grant exec on sp_SelectTimeStudyNodeServiceEdit to appusers
GO








--*****************************************************
--**************************SPROC**********************

if exists (select * from dbo.sysobjects where id = object_id(N'sp_SelectTimeStudyNodeService') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_SelectTimeStudyNodeService
GO


--select * from bluebin.TimeStudyNodeService
--exec sp_SelectTimeStudyNodeService '%','%','%','2'

CREATE PROCEDURE sp_SelectTimeStudyNodeService
@FacilityName varchar(50)
,@LocationName varchar(50)
,@UserName varchar(50)
,@MostRecent int

--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON

declare @MostRecent2 int
if @MostRecent = 2 
BEGIN
set @MostRecent = 0
set @MostRecent2 = 1
END

select
'Time Study Node Service' as TimeStudy,
t.TimeStudyNodeServiceID,
t.Date,
df.FacilityName,
dl.LocationID,
case
		when t.[LocationID] = 'Multiple' then t.LocationID
		else case	when dl.LocationID = dl.LocationName then dl.LocationID
					else dl.LocationID + ' - ' + dl.[LocationName] end end as LocationName,
bbu.LastName + ', ' + bbu.FirstName as SubmittedBy,
ISNULL(bbr.LastName + ', ' + bbr.FirstName,'') as ServiceTech,
case when t.MostRecent = '1' then 'Yes' else 'No' end as MostRecent,
c.ConfigValue as ProcessName,
t.SKUS,
ISNULL(dl2.LocationID,'') as TravelLocationID,
ISNULL(dl2.LocationName,'') as TravelLocationName,
DATEDIFF(ss,t.StartTime,t.StopTime) as [Seconds],
DATEDIFF(mi,t.StartTime,t.StopTime) as [Minutes]

FROM bluebin.TimeStudyNodeService t
inner join bluebin.Config c on t.TimeStudyProcessID = c.ConfigID and c.ConfigType = 'TimeStudy'
inner join bluebin.DimLocation dl on t.LocationID = dl.LocationID and t.FacilityID = dl.LocationFacility
inner join bluebin.DimFacility df on t.FacilityID = df.FacilityID
inner join bluebin.BlueBinUser bbu on t.BlueBinUserID = bbu.BlueBinUserID
left join bluebin.DimLocation dl2 on t.TravelLocationID = dl2.LocationID
left join bluebin.BlueBinResource bbr on t.BlueBinResourceID = bbr.BlueBinResourceID
where t.Active = 1
and df.FacilityName like '%' + @FacilityName + '%'
and (dl.LocationID + ' - ' + dl.[LocationName] LIKE '%' + @LocationName + '%' or t.LocationID like '%' + @LocationName + '%')
and t.MostRecent in (@MostRecent,@MostRecent2)
and case	
	when @UserName <> '%' then bbu.LastName + ', ' + bbu.FirstName else '' end LIKE  '%' + @UserName + '%'

END
GO
grant exec on sp_SelectTimeStudyNodeService to appusers
GO




--*****************************************************
--**************************SPROC**********************

if exists (select * from dbo.sysobjects where id = object_id(N'sp_SelectTimeStudyGroup') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_SelectTimeStudyGroup
GO

--select * from bluebin.TimeStudyGroup
--exec sp_SelectTimeStudyGroup '%','%','%'

CREATE PROCEDURE sp_SelectTimeStudyGroup
@FacilityName varchar(50)
,@LocationName varchar(50)
,@GroupName varchar(50)

--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON

select
t.TimeStudyGroupID,
df.FacilityName,
dl.LocationID,
dl.LocationName,
t.GroupName,
t.LastUpdated as DateCreated,
t.Description

FROM bluebin.TimeStudyGroup t
inner join bluebin.DimLocation dl on t.LocationID = dl.LocationID and t.FacilityID = dl.LocationFacility
inner join bluebin.DimFacility df on t.FacilityID = df.FacilityID
where t.Active = 1
and df.FacilityName like '%' + @FacilityName + '%'
and dl.LocationName like '%' + @LocationName + '%'
and t.GroupName like '%' + @GroupName + '%'

END
GO
grant exec on sp_SelectTimeStudyGroup to appusers
GO





--*****************************************************
--**************************SPROC**********************

if exists (select * from dbo.sysobjects where id = object_id(N'sp_SelectTimeStudyGroupNames') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_SelectTimeStudyGroupNames
GO

--select * from bluebin.TimeStudyGroup
--exec sp_SelectTimeStudyGroupNames

CREATE PROCEDURE sp_SelectTimeStudyGroupNames


--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON

select
distinct
t.GroupName

FROM bluebin.TimeStudyGroup t


END
GO
grant exec on sp_SelectTimeStudyGroupNames to appusers
GO




--*****************************************************
--**************************SPROC**********************

if exists (select * from dbo.sysobjects where id = object_id(N'sp_SelectTimeStudyBinFillEdit') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_SelectTimeStudyBinFillEdit
GO

--exec sp_SelectTimeStudyBinFillEdit 'TEST'

CREATE PROCEDURE sp_SelectTimeStudyBinFillEdit
@TimeStudyBinFillID int



--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON
	
select
	[TimeStudyBinFillID] ,
	[Date] ,
	[FacilityID],
	[LocationID],
	convert(varchar(2),DATEPART(hh,StartTime))+':'+right(('0' + convert(varchar(2),DATEPART(mi,StartTime))),2) as StartTime,
	convert(varchar(2),DATEPART(hh,StopTime))+':'+right(('0' + convert(varchar(2),DATEPART(mi,StopTime))),2) as StopTime,
	[SKUS],
	[Comments],
	[BlueBinUserID] ,
	[BlueBinResourceID]

FROM bluebin.TimeStudyBinFill t
WHERE [TimeStudyBinFillID] = @TimeStudyBinFillID 				

END
GO
grant exec on sp_SelectTimeStudyBinFillEdit to appusers
GO




--*****************************************************
--**************************SPROC**********************

if exists (select * from dbo.sysobjects where id = object_id(N'sp_SelectTimeStudyBinFill') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_SelectTimeStudyBinFill
GO

--select * from bluebin.TimeStudyBinFill
--exec sp_SelectTimeStudyBinFill '%','%','%','2'

CREATE PROCEDURE sp_SelectTimeStudyBinFill
@FacilityName varchar(50)
,@LocationName varchar(50)
,@UserName varchar(50)
,@MostRecent int

--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON

declare @MostRecent2 int
if @MostRecent = 2 
BEGIN
set @MostRecent = 0
set @MostRecent2 = 1
END

select
'Time Study Bin Fills' as TimeStudy,
t.TimeStudyBinFillID,
t.Date,
df.FacilityName,
dl.LocationID,
dl.LocationName,
bbu.LastName + ', ' + bbu.FirstName as SubmittedBy,
ISNULL(bbr.LastName + ', ' + bbr.FirstName,'') as ServiceTech,
case when t.MostRecent = '1' then 'Yes' else 'No' end as MostRecent,
t.SKUS,
DATEDIFF(ss,t.StartTime,t.StopTime) as [Seconds],
DATEDIFF(mi,t.StartTime,t.StopTime) as [Minutes]

FROM bluebin.TimeStudyBinFill t
inner join bluebin.DimLocation dl on t.LocationID = dl.LocationID and t.FacilityID = dl.LocationFacility
inner join bluebin.DimFacility df on t.FacilityID = df.FacilityID
inner join bluebin.BlueBinUser bbu on t.BlueBinUserID = bbu.BlueBinUserID
left join bluebin.BlueBinResource bbr on t.BlueBinResourceID = bbr.BlueBinResourceID
where t.Active = 1
and df.FacilityName like '%' + @FacilityName + '%'
and (dl.LocationID + ' - ' + dl.[LocationName] LIKE '%' + @LocationName + '%' or t.LocationID like '%' + @LocationName + '%')
and t.MostRecent in (@MostRecent,@MostRecent2)
and case	
	when @UserName <> '%' then bbu.LastName + ', ' + bbu.FirstName else '' end LIKE  '%' + @UserName + '%'

END
GO
grant exec on sp_SelectTimeStudyBinFill to appusers
GO




--*****************************************************
--**************************SPROC**********************

if exists (select * from dbo.sysobjects where id = object_id(N'sp_InsertTimeStudyStockOut') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_InsertTimeStudyStockOut
GO

/*
exec sp_InsertTimeStudyStockOut '6','BB001','1','09:51','09:59','3','Test Comments',1,1
exec sp_InsertTimeStudyStockOut '6','BB002','1','09:01','09:13','3','Test Comments',1,1
exec sp_InsertTimeStudyStockOut '6','BB001','2','09:03','09:22','14','Test Comments',1,1
exec sp_InsertTimeStudyStockOut '6','BB001','3','09:16','09:20','14','Test Comments',1,1
exec sp_InsertTimeStudyStockOut '6','BB002','3','09:26','09:50','14','Test Comments',1,1
exec sp_InsertTimeStudyStockOut '6','BB001','4','09:28','09:33','3','Test Comments',1,1
exec sp_InsertTimeStudyStockOut '6','BB002','4','09:34','09:40','2','Test Comments',1,1
exec sp_InsertTimeStudyStockOut '6','BB003','4','09:42','09:50','2','Test Comments',1,1

select * from bluebin.TimeStudyStockOut
select * from bluebin.TimeStudyProcess
select * from bluebin.TimeStudyGroup
*/

CREATE PROCEDURE sp_InsertTimeStudyStockOut
	@FacilityID int,
	@LocationID varchar(10),	
	@TimeStudyProcessID int,
	@StartTime varchar(5),
	@StopTime varchar(5),
	@SKUS int,
	@Comments varchar(max),
	@BlueBinUser varchar(30),
	@BlueBinResourceID int


--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON

update bluebin.TimeStudyStockOut set MostRecent = 0 
where MostRecent = 1 and FacilityID = @FacilityID 
--and LocationID = @LocationID 
and TimeStudyProcessID = @TimeStudyProcessID 
and [Date] < getdate()
;

declare @BlueBinUserID int 
select @bluebinUserID = BlueBinUserID from bluebin.BlueBinUser where UserLogin = @BlueBinUser

declare @Times Table ([Start] varchar(11),[Stop] varchar(11))
insert into @Times select left(getdate(),11),left(getdate(),11) 

Insert into bluebin.TimeStudyStockOut (	
	[Date],
	[FacilityID],
	[LocationID],
	[TimeStudyProcessID],
	[StartTime],
	[StopTime],
	[SKUS],
	[Comments],
	[BlueBinUserID],
	[BlueBinResourceID],
	[MostRecent],
	[Active],
    [LastUpdated])
VALUES (
	getdate(), --Entered is current time
	@FacilityID,
	@LocationID,
	@TimeStudyProcessID,
	(select convert(datetime,([Start] + ' ' + @StartTime),112) from @Times),
	(select convert(datetime,([Stop] + ' ' + @StopTime),112) from @Times),
	@SKUS,
	@Comments,
	@BlueBinUserID,
	@BlueBinResourceID,
	1, --Most Recent  New entries default to 1
	1, --Active Flag  Default to 1
	getdate() --Last Updated is current time
)


Declare @TimeStudyID int, @BlueBinUserLogin varchar(50)
SET @TimeStudyID = SCOPE_IDENTITY()

	exec sp_InsertMasterLog @BlueBinUser,'TimeStudy','Submit Time Study Stock Out',@TimeStudyID

END
GO
grant exec on sp_InsertTimeStudyStockOut to appusers
GO

--*****************************************************
--**************************SPROC**********************

if exists (select * from dbo.sysobjects where id = object_id(N'sp_InsertTimeStudyStageScan') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_InsertTimeStudyStageScan
GO

/*
exec sp_InsertTimeStudyStageScan '6','BB001','08:51','08:57','19','Test Comments',1,1
exec sp_InsertTimeStudyStageScan '6','BB002','09:03','09:10','19','Test Comments',1,1
exec sp_InsertTimeStudyStageScan '6','BB003','09:16','09:20','19','Test Comments',1,1
exec sp_InsertTimeStudyStageScan '6','BB004','09:28','09:29','19','Test Comments',1,1

select * from bluebin.TimeStudyStageScan
select * from bluebin.TimeStudyProcess
select * from bluebin.TimeStudyGroup
*/ 

CREATE PROCEDURE sp_InsertTimeStudyStageScan
	@FacilityID int,
	@LocationID varchar(10),
	@StartTime varchar(5),
	@StopTime varchar(5),
	@SKUS int,
	@Comments varchar(max),
	@BlueBinUser varchar(30),
	@BlueBinResourceID int


--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON

update bluebin.TimeStudyStageScan set MostRecent = 0 where MostRecent = 1 and FacilityID = @FacilityID and LocationID = @LocationID and [Date] < getdate()
;

declare @BlueBinUserID int 
select @bluebinUserID = BlueBinUserID from bluebin.BlueBinUser where UserLogin = @BlueBinUser

declare @Times Table ([Start] varchar(11),[Stop] varchar(11))
insert into @Times select left(getdate(),11),left(getdate(),11) 

Insert into bluebin.TimeStudyStageScan (	
	[Date],
	[FacilityID],
	[LocationID],
	[StartTime],
	[StopTime],
	[SKUS],
	[Comments],
	[BlueBinUserID],
	[BlueBinResourceID],
	[MostRecent],
	[Active],
    [LastUpdated])
VALUES (
	getdate(), --Entered is current time
	@FacilityID,
	@LocationID,
	(select convert(datetime,([Start] + ' ' + @StartTime),112) from @Times),
	(select convert(datetime,([Stop] + ' ' + @StopTime),112) from @Times),
	@SKUS,
	@Comments,
	@BlueBinUserID,
	@BlueBinResourceID,
	1, --Most Recent  New entries default to 1
	1, --Active Flag  Default to 1
	getdate() --Last Updated is current time
)

Declare @TimeStudyID int, @BlueBinUserLogin varchar(50)
SET @TimeStudyID = SCOPE_IDENTITY()

	exec sp_InsertMasterLog @BlueBinUser,'TimeStudy','Submit Time Study StageScan',@TimeStudyID

END
GO
grant exec on sp_InsertTimeStudyStageScan to appusers
GO



--*****************************************************
--**************************SPROC**********************

if exists (select * from dbo.sysobjects where id = object_id(N'sp_InsertTimeStudyNodeService') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_InsertTimeStudyNodeService
GO
--

/*
exec sp_InsertTimeStudyNodeService '6','BB001','','5','08:51','08:57','19','Test Comments',1,1
exec sp_InsertTimeStudyNodeService '6','BB001','','6','09:03','09:18','19','Test Comments',1,1
exec sp_InsertTimeStudyNodeService '6','BB001','','7','09:16','09:23','19','Test Comments',1,1
exec sp_InsertTimeStudyNodeService '6','BB001','BB002','8','09:28','09:29','19','Test Comments',1,1


exec sp_InsertTimeStudyNodeService '6','BB002','','6','09:30','09:36','19','Test Comments',1,1
exec sp_InsertTimeStudyNodeService '6','BB002','','7','09:37','09:38','19','Test Comments',1,1
exec sp_InsertTimeStudyNodeService '6','BB002','BB003','8','09:40','09:42','19','Test Comments',1,1


select * from bluebin.TimeStudyNodeService
select * from bluebin.TimeStudyProcess
select * from bluebin.TimeStudyGroup
*/ 

CREATE PROCEDURE sp_InsertTimeStudyNodeService
	@FacilityID int,
	@LocationID varchar(10),
	@TravelLocationID varchar(10),	
	@TimeStudyProcessID int,
	@StartTime varchar(5),
	@StopTime varchar(5),
	@SKUS int,
	@Comments varchar(max),
	@BlueBinUser varchar(30),
	@BlueBinResourceID int


--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON

update bluebin.TimeStudyNodeService set MostRecent = 0 where MostRecent = 1 and FacilityID = @FacilityID and LocationID = @LocationID and TimeStudyProcessID = @TimeStudyProcessID and [Date] < getdate()
;

declare @BlueBinUserID int 
select @bluebinUserID = BlueBinUserID from bluebin.BlueBinUser where UserLogin = @BlueBinUser
declare @Times Table ([Start] varchar(11),[Stop] varchar(11))
insert into @Times select left(getdate(),11),left(getdate(),11) 

Insert into bluebin.TimeStudyNodeService (	
	[Date],
	[FacilityID],
	[LocationID],
	[TravelLocationID], 
	[TimeStudyProcessID],
	[StartTime],
	[StopTime],
	[SKUS],
	[Comments],
	[BlueBinUserID],
	[BlueBinResourceID],
	[MostRecent],
	[Active],
    [LastUpdated])
VALUES (
	getdate(), --Entered is current time
	@FacilityID,
	@LocationID,
	@TravelLocationID,
	@TimeStudyProcessID,
	(select convert(datetime,([Start] + ' ' + @StartTime),112) from @Times),
	(select convert(datetime,([Stop] + ' ' + @StopTime),112) from @Times),
	@SKUS,
	@Comments,
	@BlueBinUserID,
	@BlueBinResourceID,
	1, --Most Recent  New entries default to 1
	1, --Active Flag  Default to 1
	getdate() --Last Updated is current time
)

Declare @TimeStudyID int, @BlueBinUserLogin varchar(50)
SET @TimeStudyID = SCOPE_IDENTITY()
	exec sp_InsertMasterLog @BlueBinUser,'TimeStudy','Submit Time Study NodeService',@TimeStudyID


END 

GO
grant exec on sp_InsertTimeStudyNodeService to appusers
GO

--*****************************************************
--**************************SPROC**********************

if exists (select * from dbo.sysobjects where id = object_id(N'sp_InsertTimeStudyGroup') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_InsertTimeStudyGroup
GO

--exec sp_InsertTimeStudyGroup 

CREATE PROCEDURE sp_InsertTimeStudyGroup
@FacilityID int,
@LocationID varchar(10),
@GroupName varchar(50),
@Description varchar(255)


--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON

Insert into bluebin.TimeStudyGroup (
	[FacilityID],
	[LocationID],
	[GroupName],
	[Description],
	[Active],
	[LastUpdated] )
VALUES (
	@FacilityID,
	@LocationID,
	@GroupName,
	@Description,
	1,
	getdate()
)

END
GO
grant exec on sp_InsertTimeStudyGroup to appusers
GO



--*****************************************************
--**************************SPROC**********************

if exists (select * from dbo.sysobjects where id = object_id(N'sp_InsertTimeStudyBinFill') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_InsertTimeStudyBinFill
GO

--exec sp_InsertTimeStudyBinFill '6','BB001','10:00','14:00','5','Test Comments',1,1
/*
select * from bluebin.TimeStudyBinFill
select * from bluebin.TimeStudyProcess
select * from bluebin.TimeStudyGroup
*/

CREATE PROCEDURE sp_InsertTimeStudyBinFill
	@FacilityID int,
	@LocationID varchar(10),	
	@StartTime varchar(5),
	@StopTime varchar(5),
	@SKUS int,
	@Comments varchar(max),
	@BlueBinUser varchar(30),
	@BlueBinResourceID int


--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON

update bluebin.TimeStudyBinFill set MostRecent = 0 where MostRecent = 1 and FacilityID = @FacilityID and LocationID = @LocationID and [Date] < getdate()

declare @BlueBinUserID int 
select @bluebinUserID = BlueBinUserID from bluebin.BlueBinUser where UserLogin = @BlueBinUser

declare @Times Table ([Start] varchar(11),[Stop] varchar(11))
insert into @Times select left(getdate(),11),left(getdate(),11) 


Insert into bluebin.TimeStudyBinFill (	
	[Date],
	[FacilityID],
	[LocationID],
	[StartTime],
	[StopTime],
	[SKUS],
	[Comments],
	[BlueBinUserID],
	[BlueBinResourceID],
	[MostRecent],
	[Active],
    [LastUpdated])
VALUES (
	getdate(), --Entered is current time
	@FacilityID,
	@LocationID,
	(select convert(datetime,([Start] + ' ' + @StartTime),112) from @Times),
	(select convert(datetime,([Stop] + ' ' + @StopTime),112) from @Times),
	@SKUS,
	@Comments,
	@BlueBinUserID,
	@BlueBinResourceID,
	1, --Most Recent  New entries default to 1
	1, --Active Flag  Default to 1
	getdate() --Last Updated is current time
)

Declare @TimeStudyID int, @BlueBinUserLogin varchar(50)
SET @TimeStudyID = SCOPE_IDENTITY()

	exec sp_InsertMasterLog @BlueBinUser,'TimeStudy','Submit Time Study BinFill',@TimeStudyID


END

GO
grant exec on sp_InsertTimeStudyBinFill to appusers
GO
--*****************************************************
--**************************SPROC**********************

if exists (select * from dbo.sysobjects where id = object_id(N'sp_EditTimeStudyStockOut') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_EditTimeStudyStockOut
GO

--exec sp_EditTimeStudyStockOut 
CREATE PROCEDURE sp_EditTimeStudyStockOut
@TimeStudyStockOutID int,
@StartTime varchar(5),
@StopTime varchar(5),
@SKUS int,
@Comments varchar(max),
@BlueBinResourceID int

--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON


declare @Times Table ([Start] varchar(10),[Stop] varchar(10))
insert into @Times select left(StartTime,10),left(StopTime,10) from [bluebin].[TimeStudyStockOut] where TimeStudyStockOutID = @TimeStudyStockOutID


update [bluebin].[TimeStudyStockOut] 
set 
StartTime = (select convert(datetime,([Start] + ' ' + @StartTime),112) from @Times),
StopTime = (select convert(datetime,([Stop] + ' ' + @StopTime),112) from @Times),
SKUS = @SKUS,
Comments = @Comments,
BlueBinResourceID = @BlueBinResourceID

where TimeStudyStockOutID = @TimeStudyStockOutID
;
declare @BlueBinUserID int 
select @BlueBinUserID = BlueBinUserID from [bluebin].[TimeStudyStockOut] where TimeStudyStockOutID = @TimeStudyStockOutID
exec sp_InsertMasterLog @BlueBinUserID,'TimeStudy','Edit Time Study Stock Out',@TimeStudyStockOutID


END
GO
grant exec on sp_EditTimeStudyStockOut to appusers
GO


--*****************************************************
--**************************SPROC**********************

if exists (select * from dbo.sysobjects where id = object_id(N'sp_EditTimeStudyStageScan') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_EditTimeStudyStageScan
GO

--exec sp_EditTimeStudyStageScan 
CREATE PROCEDURE sp_EditTimeStudyStageScan
@TimeStudyStageScanID int,
@StartTime varchar(5),
@StopTime varchar(5),
@SKUS int,
@Comments varchar(max),
@BlueBinResourceID int

--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON


declare @Times Table ([Start] varchar(10),[Stop] varchar(10))
insert into @Times select left(StartTime,10),left(StopTime,10) from [bluebin].[TimeStudyStockOut] where TimeStudyStockOutID = @TimeStudyStageScanID


update [bluebin].[TimeStudyStageScan] 
set 

StartTime = (select convert(datetime,([Start] + ' ' + @StartTime),112) from @Times),
StopTime = (select convert(datetime,([Stop] + ' ' + @StopTime),112) from @Times),
SKUS = @SKUS,
Comments = @Comments,
BlueBinResourceID = @BlueBinResourceID

where TimeStudyStageScanID = @TimeStudyStageScanID
;
declare @BlueBinUserID int 
select @BlueBinUserID = BlueBinUserID from [bluebin].[TimeStudyStageScan] where TimeStudyStageScanID = @TimeStudyStageScanID
exec sp_InsertMasterLog @BlueBinUserID,'TimeStudy','Edit Time Study StageScan',@TimeStudyStageScanID

END
GO
grant exec on sp_EditTimeStudyStageScan to appusers
GO





--*****************************************************
--**************************SPROC**********************

if exists (select * from dbo.sysobjects where id = object_id(N'sp_EditTimeStudyNodeService') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_EditTimeStudyNodeService
GO

--exec sp_EditTimeStudyNodeService 
CREATE PROCEDURE sp_EditTimeStudyNodeService
@TimeStudyNodeServiceID int,
@TravelLocationID varchar(10),
@StartTime varchar(5),
@StopTime varchar(5),
@SKUS int,
@Comments varchar(max),
@BlueBinResourceID int

--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON


declare @Times Table ([Start] varchar(10),[Stop] varchar(10))
insert into @Times select left(StartTime,10),left(StopTime,10) from [bluebin].[TimeStudyStockOut] where TimeStudyStockOutID = @TimeStudyNodeServiceID


update [bluebin].[TimeStudyNodeService] 
set 

StartTime = (select convert(datetime,([Start] + ' ' + @StartTime),112) from @Times),
StopTime = (select convert(datetime,([Stop] + ' ' + @StopTime),112) from @Times),
SKUS = @SKUS,
Comments = @Comments,
BlueBinResourceID = @BlueBinResourceID,
TravelLocationID = @TravelLocationID

where TimeStudyNodeServiceID = @TimeStudyNodeServiceID
;
declare @BlueBinUserID int 
select @BlueBinUserID = BlueBinUserID from [bluebin].[TimeStudyNodeService] where TimeStudyNodeServiceID = @TimeStudyNodeServiceID
exec sp_InsertMasterLog @BlueBinUserID,'TimeStudy','Edit Time Study NodeService',@TimeStudyNodeServiceID


END
GO
grant exec on sp_EditTimeStudyNodeService to appusers
GO



--*****************************************************
--**************************SPROC**********************

if exists (select * from dbo.sysobjects where id = object_id(N'sp_EditTimeStudyGroup') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_EditTimeStudyGroup
GO

--exec sp_EditTimeStudyGroup 
CREATE PROCEDURE sp_EditTimeStudyGroup
@TimeStudyGroupID int,
@GroupName varchar(50),
@Description varchar(255)

--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON

update [bluebin].[TimeStudyGroup] 
set 
GroupName = @GroupName,
[Description] = @Description

where TimeStudyGroupID = @TimeStudyGroupID


END
GO
grant exec on sp_EditTimeStudyGroup to appusers
GO



--*****************************************************
--**************************SPROC**********************

if exists (select * from dbo.sysobjects where id = object_id(N'sp_EditTimeStudyBinFill') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_EditTimeStudyBinFill
GO

--exec sp_EditTimeStudyBinFill 
CREATE PROCEDURE sp_EditTimeStudyBinFill
@TimeStudyBinFillID int,
@StartTime varchar(5),
@StopTime varchar(5),
@SKUS int,
@Comments varchar(max),
@BlueBinResourceID int

--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON


declare @Times Table ([Start] varchar(10),[Stop] varchar(10))
insert into @Times select left(StartTime,10),left(StopTime,10) from [bluebin].[TimeStudyStockOut] where TimeStudyStockOutID = @TimeStudyBinFillID


update [bluebin].[TimeStudyBinFill] 
set 

StartTime = (select convert(datetime,([Start] + ' ' + @StartTime),112) from @Times),
StopTime = (select convert(datetime,([Stop] + ' ' + @StopTime),112) from @Times),
SKUS = @SKUS,
Comments = @Comments,
BlueBinResourceID = @BlueBinResourceID


where TimeStudyBinFillID = @TimeStudyBinFillID
;
declare @BlueBinUserID int 
select @BlueBinUserID = BlueBinUserID from [bluebin].[TimeStudyBinFill] where TimeStudyBinFillID = @TimeStudyBinFillID
exec sp_InsertMasterLog @BlueBinUserID,'TimeStudy','Edit Time Study BinFill',@TimeStudyBinFillID

END
GO
grant exec on sp_EditTimeStudyBinFill to appusers
GO


--*****************************************************
--**************************SPROC**********************

if exists (select * from dbo.sysobjects where id = object_id(N'sp_DeleteTimeStudyStockOut') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_DeleteTimeStudyStockOut
GO

--exec sp_DeleteTimeStudyStockOut 'TEST'

CREATE PROCEDURE sp_DeleteTimeStudyStockOut
@TimeStudyStockOutID int



--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON
	
UPDATE bluebin.[TimeStudyStockOut] 
set Active = 0, MostRecent = 0
WHERE [TimeStudyStockOutID] = @TimeStudyStockOutID 
				

END
GO
grant exec on sp_DeleteTimeStudyStockOut to appusers
GO



--*****************************************************
--**************************SPROC**********************

if exists (select * from dbo.sysobjects where id = object_id(N'sp_DeleteTimeStudyStageScan') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_DeleteTimeStudyStageScan
GO

--exec sp_DeleteTimeStudyStageScan 'TEST'

CREATE PROCEDURE sp_DeleteTimeStudyStageScan
@TimeStudyStageScanID int



--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON
	
UPDATE bluebin.[TimeStudyStageScan] 
set Active = 0, MostRecent = 0
WHERE [TimeStudyStageScanID] = @TimeStudyStageScanID 
				

END
GO
grant exec on sp_DeleteTimeStudyStageScan to appusers
GO



--*****************************************************
--**************************SPROC**********************

if exists (select * from dbo.sysobjects where id = object_id(N'sp_DeleteTimeStudyNodeService') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_DeleteTimeStudyNodeService
GO

--exec sp_DeleteTimeStudyNodeService 'TEST'

CREATE PROCEDURE sp_DeleteTimeStudyNodeService
@TimeStudyNodeServiceID int



--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON
	
UPDATE bluebin.[TimeStudyNodeService] 
set Active = 0, MostRecent = 0
WHERE [TimeStudyNodeServiceID] = @TimeStudyNodeServiceID 
				

END
GO
grant exec on sp_DeleteTimeStudyNodeService to appusers
GO




--*****************************************************
--**************************SPROC**********************

if exists (select * from dbo.sysobjects where id = object_id(N'sp_DeleteTimeStudyGroup') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_DeleteTimeStudyGroup
GO

--exec sp_DeleteTimeStudyGroup 'TEST'

CREATE PROCEDURE sp_DeleteTimeStudyGroup
@TimeStudyGroupID int



--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON
	
Delete from bluebin.[TimeStudyGroup] 
WHERE [TimeStudyGroupID] = @TimeStudyGroupID 
				

END
GO
grant exec on sp_DeleteTimeStudyGroup to appusers
GO


--*****************************************************
--**************************SPROC**********************

if exists (select * from dbo.sysobjects where id = object_id(N'sp_DeleteTimeStudyBinFill') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_DeleteTimeStudyBinFill
GO

--exec sp_DeleteTimeStudyBinFill 'TEST'

CREATE PROCEDURE sp_DeleteTimeStudyBinFill
@TimeStudyBinFillID int



--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON
	
UPDATE bluebin.[TimeStudyBinFill] 
set Active = 0, MostRecent = 0
WHERE [TimeStudyBinFillID] = @TimeStudyBinFillID 
				

END
GO
grant exec on sp_DeleteTimeStudyBinFill to appusers
GO






















