
	
--Upgrade Script v2.4
--Backward compatible to V2.3
--Created By Gerry Butler 20161001

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

SET NOCOUNT ON
GO


--*************************************************************************************************************************************
--*************************************************************************************************************************************

--Schema Creation

--*************************************************************************************************************************************
--*************************************************************************************************************************************



--*****************************************************
--**************************NEWSCHEMA**********************

if not exists (select * from sys.schemas where name = 'gemba')
BEGIN
EXEC sp_executesql N'Create SCHEMA gemba AUTHORIZATION  dbo'
Print 'Schema gemba created'
END
GO

--*****************************************************
--**************************NEWSCHEMA**********************
if not exists (select * from sys.schemas where name = 'qcn')
BEGIN
EXEC sp_executesql N'Create SCHEMA qcn AUTHORIZATION  dbo'
Print 'Schema qcn created'
END
GO

--*****************************************************
--**************************NEWSCHEMA**********************
if not exists (select * from sys.schemas where name = 'bluebin')
BEGIN
EXEC sp_executesql N'Create SCHEMA bluebin AUTHORIZATION  dbo'
Print 'Schema bluebin created'
END
GO

--*****************************************************
--**************************NEWSCHEMA**********************
if not exists (select * from sys.schemas where name = 'scan')
BEGIN
EXEC sp_executesql N'Create SCHEMA scan AUTHORIZATION  dbo'
Print 'Schema scan created'
END
GO


Print 'Schema Updates Complete'


--*************************************************************************************************************************************************
--Table Updates
--*************************************************************************************************************************************************
--2.4

--*********************************************************************************************************************
--*********************************************************************************************************************
--PRODUCTIVITY MODULE CREATION
--*********************************************************************************************************************
--*********************************************************************************************************************


if not exists(select * from bluebin.Config where ConfigName like 'MENU-PP-Observation')  
BEGIN
insert into bluebin.Config (ConfigName,ConfigValue,ConfigType,Active,LastUpdated,[Description]) VALUES
('MENU-PP-Observation','1','DMS',1,getdate(),'Productivity Planner Module Observations Sub Module is viewable.')
END
GO

if not exists(select * from bluebin.Config where ConfigName like 'MENU-PP-ServiceTimes')  
BEGIN
insert into bluebin.Config (ConfigName,ConfigValue,ConfigType,Active,LastUpdated,[Description]) VALUES
('MENU-PP-ServiceTimes','1','DMS',1,getdate(),'Productivity Planner Module Service Times Sub Module is viewable.')
END
GO

if not exists(select * from bluebin.Config where ConfigName like 'MENU-PP-StockOutP')  
BEGIN
insert into bluebin.Config (ConfigName,ConfigValue,ConfigType,Active,LastUpdated,[Description]) VALUES
('MENU-PP-StockOutP','1','DMS',1,getdate(),'Productivity Planner Module Observations Sub Module is viewable.')
END
GO


--*************************************************************************************************************************************
--*************************************************************************************************************************************

--Config Stuff

--*************************************************************************************************************************************
--*************************************************************************************************************************************
/*Time Study */
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

if not exists(select * from bluebin.Config where ConfigType = 'Reports' and ConfigName like 'OP-Activity%')  
BEGIN
insert into bluebin.Config (ConfigName,ConfigValue,Active,LastUpdated,ConfigType,[Description]) VALUES
('OP-Activity Times','0',1,getdate(),'Reports','Setting for whether to display the Time Study Activity Times'),
('OP-Activity Averages','0',1,getdate(),'Reports','Setting for whether to display the Time Study Averages for Nodes'),
('OP-Activity Planner','0',1,getdate(),'Reports','Setting for whether to display the Time Study Overview Dashboard (Detail)')
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

if not exists(select * from bluebin.Config where ConfigName like 'Returns Bin Large')  
BEGIN
insert into bluebin.Config (ConfigName,ConfigValue,ConfigType,Active,LastUpdated,[Description]) VALUES
('Returns Bins Large','2.30','TimeStudy',1,getdate(),'Average Time to Returns Bin Large based on Returns Bins Threshold (Greater)')
END
GO

if not exists(select * from bluebin.Config where ConfigName like 'Returns Bin Small')  
BEGIN
insert into bluebin.Config (ConfigName,ConfigValue,ConfigType,Active,LastUpdated,[Description]) VALUES
('Returns Bins Small','1.86','TimeStudy',1,getdate(),'Average Time to Returns Bin Small based on Returns Bins Threshold (Less)')
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

/* PEOPLESOFT CONFIGS*/
if not exists(select * from bluebin.Config where ConfigName = 'ClientERP')  
BEGIN
insert into bluebin.Config (ConfigName,ConfigValue,Active,LastUpdated,ConfigType,[Description])
select 'ClientERP','Lawson',1,getdate(),'DMS','Client ERP System.  Used to avoid running the wrong upgrade script'
END
GO

if not exists(select * from bluebin.Config where ConfigName = 'PS_DefaultFacility')  
BEGIN
insert into bluebin.Config (ConfigName,ConfigValue,Active,LastUpdated,ConfigType,[Description])
select 'PS_DefaultFacility','',1,getdate(),'Tableau','Value for a Default Facility if none exist.  Used in Peoplesoft.  Defaults to 99'
END
GO

if not exists(select * from bluebin.Config where ConfigName = 'PS_InFulfillState')  
BEGIN
insert into bluebin.Config (ConfigName,ConfigValue,Active,LastUpdated,ConfigType,[Description])
select 'PS_InFulfillState','',1,getdate(),'Tableau','Value for in Fulfill State to match.'
END
GO

if not exists(select * from bluebin.Config where ConfigName = 'PS_BUSINESSUNIT')  
BEGIN
insert into bluebin.Config (ConfigName,ConfigValue,Active,LastUpdated,ConfigType,[Description])
select 'PS_BUSINESSUNIT','',1,getdate(),'Tableau','Business Unit to Match to for Warehouse Identity.'
END
GO

/*  */


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

if not exists(select * from bluebin.Config where ConfigType = 'Reports' and ConfigName like 'OP-Activity%')  
BEGIN
insert into bluebin.Config (ConfigName,ConfigValue,Active,LastUpdated,ConfigType,[Description]) VALUES
('OP-Activity Times','0',1,getdate(),'Reports','Setting for whether to display the Time Study Activity Times'),
('OP-Activity Averages','0',1,getdate(),'Reports','Setting for whether to display the Time Study Averages for Nodes'),
('OP-Activity Planner','0',1,getdate(),'Reports','Setting for whether to display the Time Study Overview Dashboard (Detail)')
END


if exists(select * from scan.ScanBatch where ScanType = 'Order')  
BEGIN
update scan.ScanBatch set ScanType = 'ScanOrder' where ScanType = 'Order'
END

if not exists(select * from bluebin.Config where ConfigName = 'DefaultLeadTime')  
BEGIN
insert into bluebin.Config (ConfigName,ConfigValue,Active,LastUpdated,ConfigType,[Description])
select 'DefaultLeadTime','3',1,getdate(),'Tableau','Lead Time to Default to in DimBin if no LeadTime is in the ERP'
END
GO

if not exists(select * from bluebin.Config where ConfigName = 'AutoExtractTrayScans')  
BEGIN
insert into bluebin.Config (ConfigName,ConfigValue,Active,LastUpdated,ConfigType,[Description])
select 'AutoExtractTrayScans','0',1,getdate(),'Interface','Automaticaly create an extract for Scans that originate from the RFID Tray.  Default to No'
END
GO

if not exists(select * from bluebin.Config where ConfigName = 'SingleCompany')  
BEGIN
insert into bluebin.Config (ConfigName,ConfigValue,Active,LastUpdated,ConfigType,[Description])
select 'SingleCompany','0',1,getdate(),'DMS','Tableau Setting - Will limit the return of rows to one company for ERPs. Default=0 (Boolean 0 is No, 1 is Yes)'
END
GO


if not exists(select * from bluebin.Config where ConfigName = 'AutoExtractScans')  
BEGIN
insert into bluebin.Config (ConfigName,ConfigValue,Active,LastUpdated,ConfigType,[Description])
select 'AutoExtractScans','0',1,getdate(),'Interface','Automaticaly create an extract for Scans that originate from Scanning.  Default to No'
END
GO

if not exists(select * from bluebin.Config where ConfigName = 'ScanThreshold')  
BEGIN
insert into bluebin.Config (ConfigName,ConfigValue,Active,LastUpdated,ConfigType,[Description])
select 'ScanThreshold','1',1,getdate(),'Tableau','Number of Scans to ignore in calculations for Bin Status and first Stockouts'
END
GO

if not exists(select * from bluebin.Config where ConfigType = 'Reports' and ConfigName like 'SC-%')  
BEGIN
insert into bluebin.Config (ConfigName,ConfigValue,Active,LastUpdated,ConfigType,[Description]) VALUES
('SC-Daily Management DB','1',1,getdate(),'Reports','Setting for whether to display the Daily Management DB'),
('SC-Bin Activity','1',1,getdate(),'Reports','Setting for whether to display the BlueBin Activity Report'),
('SC-Node Activity','1',1,getdate(),'Reports','Setting for whether to display the Node Activity Report'),
('SC-Bin Velocity Report','1',1,getdate(),'Reports','Setting for whether to display the Bin Velocity Report'),
('SC-Slow Bin Report','1',1,getdate(),'Reports','Setting for whether to display the Slow Bin Report'),
('SC-BlueBin Par Master','1',1,getdate(),'Reports','Setting for whether to display the BlueBin Par Master Report'),
('SC-Order Details','1',1,getdate(),'Reports','Setting for whether to display the Order Details Report'),
('SC-Open Scans','1',1,getdate(),'Reports','Setting for whether to display the Open Scans Report'),
('SC-Par Valuation','1',1,getdate(),'Reports','Setting for whether to display the Par Valuation Report'),
('SC-Item Locator','1',1,getdate(),'Reports','Setting for whether to display the Item Locator Report'),
('SC-Item Master','1',1,getdate(),'Reports','Setting for whether to display the Item Master Report')
END

if not exists(select * from bluebin.Config where ConfigType = 'Reports' and ConfigName like 'OP-%')  
BEGIN
insert into bluebin.Config (ConfigName,ConfigValue,Active,LastUpdated,ConfigType,[Description]) VALUES
('OP-Activity Times','0',1,getdate(),'Reports','Setting for whether to display the Time Study Activity Times'),
('OP-Activity Averages','0',1,getdate(),'Reports','Setting for whether to display the Time Study Averages for Nodes'),
('OP-Activity Planner','0',1,getdate(),'Reports','Setting for whether to display the Time Study Overview Dashboard (Detail)'),
('OP-Warehouse History','0',1,getdate(),'Reports','Setting for whether to display the WH History Report'),
('OP-Item Usage','0',1,getdate(),'Reports','Setting for whether to display the Item Usage Report'),
('OP-Pick Line Volume','1',1,getdate(),'Reports','Setting for whether to display the Pick Line Volume Report'),
('OP-Supply Spend','1',1,getdate(),'Reports','Setting for whether to display the Supply Spend Report'),
('OP-Overall Line Volume','1',1,getdate(),'Reports','Setting for whether to display the Overall Line Volume Report'),
('OP-Kanbans Adjusted','1',1,getdate(),'Reports','Setting for whether to display the Kanbans Adjusted Report'),
('OP-Stat Calls','1',1,getdate(),'Reports','Setting for whether to display the Stat Calls Report'),
('OP-Warehouse Detail','1',1,getdate(),'Reports','Setting for whether to display the Warehouse Size Report'),
('OP-Warehouse Volume','1',1,getdate(),'Reports','Setting for whether to display the Warehouse Value Report'),
('OP-Huddle Board','1',1,getdate(),'Reports','Setting for whether to display the Huddle Board Report'),
('OP-Cones Dashboard','1',1,getdate(),'Reports','Setting for whether to display the Cones Deploy DB'),
('OP-QCN Dashboard','1',1,getdate(),'Reports','Setting for whether to display the QCN DB'),
('OP-QCN Detail','1',1,getdate(),'Reports','Setting for whether to display the QCN Detail Report'),
('OP-Gemba Dashboard','1',1,getdate(),'Reports','Setting for whether to display the Gemba DB')
END

if not exists(select * from bluebin.Config where ConfigType = 'Reports' and ConfigName like 'Src-%')  
BEGIN
insert into bluebin.Config (ConfigName,ConfigValue,Active,LastUpdated,ConfigType,[Description]) VALUES
('Src-Buyer Performance','1',1,getdate(),'Reports','Setting for whether to display the Buyer Performance DB'),
('Src-Special Performance','1',1,getdate(),'Reports','Setting for whether to display the Specials DB'),
('Src-Supplier Performance','1',1,getdate(),'Reports','Setting for whether to display the Supplier Performance DB'),
('Src-Cost Impact Calculator','1',1,getdate(),'Reports','Setting for whether to display the Item Cost Impact DB'),
('Src-Open PO Report','1',1,getdate(),'Reports','Setting for whether to display the Open PO Report'),
('Src-Supplier Spend Manager','1',1,getdate(),'Reports','Setting for whether to display the Supplier Spend Manager Report'),
('Src-Sourcing Calendar','1',1,getdate(),'Reports','Setting for whether to display the Sourcing Calendar Report'),
('Src-Cost Variance Dashboard','1',1,getdate(),'Reports','Setting for whether to display the Cost Variance DB')
END

if not exists(select * from bluebin.Config where ConfigName = 'TableauSiteName')  
BEGIN
insert into bluebin.Config (ConfigName,ConfigValue,Active,LastUpdated,ConfigType,[Description])
select 'TableauSiteName','Demo',1,getdate(),'Tableau','Name of the site where we publish the workbooks for this client on Tableau Server'

insert into bluebin.Config (ConfigName,ConfigValue,Active,LastUpdated,ConfigType,[Description])
select 'TableauDefaultUser','demo@bluebin.com',1,getdate(),'Tableau','Name of Default User to use instead of bluebin'

insert into bluebin.Config (ConfigName,ConfigValue,Active,LastUpdated,ConfigType,[Description])
select 'TableauHBDefaultUser','demohb@bluebin.com',1,getdate(),'Tableau','Name of Default HB User to use instead of bluebin'

insert into bluebin.Config (ConfigName,ConfigValue,Active,LastUpdated,ConfigType,[Description])
select 'TableauWorkbook','Demo',1,getdate(),'Tableau','Name of Default Workbook Used'
END
GO

if not exists(select * from bluebin.Config where ConfigName = 'GembaShadowTitle')  
BEGIN
insert into bluebin.Config (ConfigName,ConfigValue,Active,LastUpdated,ConfigType,[Description])
select 'GembaShadowTitle','Tech',1,getdate(),'DMS','BlueBin Resource Title that is available in Shadowed User section of Gemba Audit'

insert into bluebin.Config (ConfigName,ConfigValue,Active,LastUpdated,ConfigType,[Description])
select 'GembaShadowTitle','Strider',1,getdate(),'DMS','BlueBin Resource Title that is available in Shadowed User section of Gemba Audit'
END
GO

if not exists(select * from bluebin.Config where ConfigName = 'MENU-Scanning-Receive')  
BEGIN
insert into bluebin.Config (ConfigName,ConfigValue,Active,LastUpdated,ConfigType,[Description])
select 'MENU-Scanning-Receive','0',1,getdate(),'DMS','Receive Scanning Functionality is available for this client. Default=0 (Boolean 0 is No, 1 is Yes)'
END
GO

if not exists(select * from bluebin.Config where ConfigName = 'UseClinicalDescription')  
BEGIN
insert into bluebin.Config (ConfigName,ConfigValue,Active,LastUpdated,ConfigType,[Description])
select 'UseClinicalDescription','1',1,getdate(),'Tableau','Use ClinicalDescription from UserFields instead of Description for DimItem'
END
GO


if not exists(select * from bluebin.Config where ConfigName = 'RQ500User')  
BEGIN
insert into bluebin.Config (ConfigName,ConfigValue,Active,LastUpdated,ConfigType,[Description])
select 'RQ500User','mmstaff',1,getdate(),'Interface','User to enter as Requester when processing a batch into RQ500. 19-28'
END
GO

if not exists(select * from bluebin.Config where ConfigName = 'RQ500FromLoc')  
BEGIN
insert into bluebin.Config (ConfigName,ConfigValue,Active,LastUpdated,ConfigType,[Description])
select 'RQ500FromLoc','STORE',1,getdate(),'Interface','Inventory location that supplies the items or the purchase order ship to location that receives the items.54-58'
END
GO

if not exists(select * from bluebin.Config where ConfigName = 'RQ500FromComp')  
BEGIN
insert into bluebin.Config (ConfigName,ConfigValue,Active,LastUpdated,ConfigType,[Description])
select 'RQ500FromComp','1',1,getdate(),'Interface','Company that is the source of the items for Reqs.50-53'
END
GO

if not exists(select * from bluebin.Config where ConfigName = 'RQ500AccountCat')  
BEGIN
insert into bluebin.Config (ConfigName,ConfigValue,Active,LastUpdated,ConfigType,[Description])
select 'RQ500AccountCat','200',1,getdate(),'Interface','Accounting category code, used for reporting and inquiry functions. 241-245'
END
GO

if not exists(select * from bluebin.Config where ConfigName = 'RQ500AccountUnit')  
BEGIN
insert into bluebin.Config (ConfigName,ConfigValue,Active,LastUpdated,ConfigType,[Description])
select 'RQ500AccountUnit','1000',1,getdate(),'Interface','Posting accounting unit when processing a batch into RQ500. 278-292'
END
GO

if not exists(select * from bluebin.Config where ConfigName = 'RQ500Account')  
BEGIN
insert into bluebin.Config (ConfigName,ConfigValue,Active,LastUpdated,ConfigType,[Description])
select 'RQ500Account','016180',1,getdate(),'Interface','Account from the general ledger for PO when processing an RQ500 batch. 293-298'
END
GO

if not exists(select * from bluebin.Config where ConfigName = 'RQ500SubAccount')  
BEGIN
insert into bluebin.Config (ConfigName,ConfigValue,Active,LastUpdated,ConfigType,[Description])
select 'RQ500SubAccount','0000',1,getdate(),'Interface','Subaccount from the general ledger charged for this requisition. 299-302'
END
GO



if not exists(select * from bluebin.Config where ConfigName = 'QCN-ReferenceC')  
BEGIN
insert into bluebin.Config (ConfigName,ConfigValue,Active,LastUpdated,ConfigType,[Description])
select 'QCN-ReferenceC',0,1,getdate(),'DMS','Allow the Reference Number Column to display in the QCN main GridView'
END
GO

if not exists(select * from bluebin.Config where ConfigName = 'ADMIN-PARMASTER')  
BEGIN
insert into bluebin.Config (ConfigName,ConfigValue,Active,LastUpdated,ConfigType,[Description])
select 'ADMIN-PARMASTER',0,1,getdate(),'DMS','Give User ability to see Custom BlueBin Par Master'
END
GO


if not exists(select * from bluebin.Config where ConfigName = 'TrainingTitle')  
BEGIN
insert into bluebin.Config (ConfigName,ConfigValue,Active,LastUpdated,ConfigType,[Description])
select 'TrainingTitle','Tech',1,getdate(),'DMS',''
END
GO

if not exists(select * from bluebin.Config where ConfigName = 'PO_DATE')  
BEGIN
insert into bluebin.Config (ConfigName,ConfigValue,Active,LastUpdated,ConfigType,[Description])
select 'PO_DATE','1/1/2015',1,getdate(),'Tableau',''
END
GO

if not exists(select * from bluebin.Config where ConfigName = 'GLSummaryAccountID')  
BEGIN
insert into bluebin.Config (ConfigName,ConfigValue,Active,LastUpdated,ConfigType,[Description])
select 'GLSummaryAccountID','',1,getdate(),'Tableau',''
END
GO

if not exists(select * from bluebin.Config where ConfigName like 'MENU-%')  
BEGIN
insert into bluebin.Config (ConfigName,ConfigValue,ConfigType,Active,LastUpdated,[Description]) VALUES
('MENU-Cones','1','DMS',1,getdate(),'Ability to see the Cones Module'),
('MENU-Dashboard','1','DMS',1,getdate(),''),
('MENU-QCN','1','DMS',1,getdate(),''),
('MENU-Gemba','1','DMS',1,getdate(),''),
('MENU-Hardware','1','DMS',1,getdate(),''),
('MENU-Scanning','1','DMS',1,getdate(),''),
('MENU-Other','1','DMS',1,getdate(),'')
END
GO

if not exists(select * from bluebin.Config where ConfigName like 'MENU-Dashboard-%')  
BEGIN
insert into bluebin.Config (ConfigName,ConfigValue,ConfigType,Active,LastUpdated,[Description]) VALUES
('MENU-Dashboard-HuddleBoard','1','DMS',1,getdate(),''),
('MENU-Dashboard-SupplyChain','1','DMS',1,getdate(),''),
('MENU-Dashboard-Sourcing','1','DMS',1,getdate(),''),
('MENU-Dashboard-Ops','1','DMS',1,getdate(),'')
END
GO

if not exists(select * from bluebin.Config where ConfigName = 'ReportDateEnd')  
BEGIN
insert into bluebin.Config (ConfigName,ConfigValue,Active,LastUpdated,ConfigType,[Description])
select 'ReportDateEnd','',1,getdate(),'Tableau','Set to Current if you want to capture scans from today as well.  Default is blank'
END
GO


Print 'Table Updates Complete'



--*************************************************************************************************************************************
--*************************************************************************************************************************************

--Table Adds

--*************************************************************************************************************************************
--*************************************************************************************************************************************

--*****************************************************
--**************************NEWTABLE**********************
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

--*****************************************************
--**************************NEWTABLE**********************

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

--*****************************************************
--**************************NEWTABLE**********************

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

--*****************************************************
--**************************NEWTABLE**********************

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

--*****************************************************
--**************************NEWTABLE**********************

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
--*****************************************************
--**************************NEWTABLE**********************

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
--**************************NEWTABLE**********************
if not exists (select * from sys.tables where name = 'ConesDeployed')
BEGIN
CREATE TABLE [bluebin].[ConesDeployed](
	[ConesDeployedID] INT NOT NULL IDENTITY(1,1)  PRIMARY KEY,
	FacilityID int NOT NULL,
	LocationID varchar(10) NOT NULL,
	ItemID varchar(32) NOT NULL,
	ConeDeployed int,
	Deployed datetime,
	ConeReturned int NULL,
	Returned datetime NULL,
	Deleted int null,
	LastUpdated datetime not null
	
)

END
GO

--*****************************************************
--**************************NEWTABLE**********************
if not exists (select * from sys.tables where name = 'TrainingModule')
BEGIN
CREATE TABLE [bluebin].[TrainingModule](
	[TrainingModuleID] INT NOT NULL IDENTITY(1,1)  PRIMARY KEY,
	[ModuleName] varchar (50) not null,
	[ModuleDescription] varchar (255),
	[Active] int not null,
	[Required] int NULL,
	[LastUpdated] datetime not null
)

;
insert into bluebin.TrainingModule (ModuleName,ModuleDescription,Active,Required,LastUpdated) VALUES
('SOP 3000','SOP 3000',1,1,getdate()),
('SOP 3001','SOP 3001',1,1,getdate()),
('SOP 3002','SOP 3002',1,1,getdate()),
('SOP 3003','SOP 3003',1,1,getdate()),
('SOP 3004','SOP 3004',1,1,getdate()),
('SOP 3005','SOP 3005',1,1,getdate()),
('SOP 3006','SOP 3006',1,1,getdate()),
('SOP 3007','SOP 3007',1,1,getdate()),
('SOP 3008','SOP 3008',1,1,getdate()),
('SOP 3009','SOP 3009',1,1,getdate()),
('SOP 3010','SOP 3010',1,1,getdate()),
('Green Belt Certification','Green Belt Certification',1,0,getdate()),
('Blue Belt Certification','Blue Belt Certification',1,0,getdate()),
('Black Belt Certification','Black Belt Certification',1,0,getdate()),
('DMS App Training','Training on the use of Gemba, QCN, and Dashboard as applicable',1,0,getdate())
;
END
GO

--*****************************************************
--**************************NEWTABLE**********************


if not exists (select * from sys.tables where name = 'Training')
BEGIN
CREATE TABLE [bluebin].[Training](
	[TrainingID] INT NOT NULL IDENTITY(1,1)  PRIMARY KEY,
	[BlueBinResourceID] INT NOT NULL,
	[TrainingModuleID] INT not null,
	[Status] varchar(10) not null,
	[BlueBinUserID] int NULL,
	[Active] int not null,
	[LastUpdated] datetime not null
)
;
ALTER TABLE [bluebin].[Training] WITH CHECK ADD FOREIGN KEY([BlueBinResourceID])
REFERENCES [bluebin].[BlueBinResource] ([BlueBinResourceID])
;
ALTER TABLE [bluebin].[Training] WITH CHECK ADD FOREIGN KEY([BlueBinUserID])
REFERENCES [bluebin].[BlueBinUser] ([BlueBinUserID])
;
ALTER TABLE [bluebin].[Training] WITH CHECK ADD FOREIGN KEY([TrainingModuleID])
REFERENCES [bluebin].[TrainingModule] ([TrainingModuleID])
;
if not exists (select * from bluebin.Training)
BEGIN
insert into bluebin.Training ([BlueBinResourceID],[TrainingModuleID],[Status],[BlueBinUserID],[Active],[LastUpdated])
select 
u.BlueBinResourceID,
t.TrainingModuleID,
'No',
(select BlueBinUserID from bluebin.BlueBinUser where UserLogin = 'gbutler@bluebin.com'),
1,
getdate()
from bluebin.TrainingModule t, bluebin.BlueBinResource u
where t.Required = 1 and u.Title in (select ConfigValue from bluebin.Config where ConfigName = 'TrainingTitle') 
END

END
GO

--*****************************************************
--**************************NEWTABLE**********************


if not exists (select * from sys.tables where name = 'ALT_REQ_LOCATION')
BEGIN
CREATE TABLE [bluebin].[ALT_REQ_LOCATION](
	[COMPANY] INT NOT NULL,
	[REQ_LOCATION] varchar(12) not null,
	Active int not null,
	LastUpdated datetime not null

)
END
GO

--*****************************************************
--**************************NEWTABLE**********************


if not exists (select * from sys.tables where name = 'BlueBinParMaster')
BEGIN
CREATE TABLE [bluebin].[BlueBinParMaster](
	[ParMasterID] INT NOT NULL IDENTITY(1,1)  PRIMARY KEY,
	[FacilityID] smallint not null,
	[LocationID] varchar (10) NOT NULL,
	[ItemID] char (32) NOT NULL,
	[BinSequence] varchar (50) NOT NULL,
	[BinSize] varchar(5) NULL,
	[BinUOM] varchar (10) NULL,
	[BinQuantity] int NULL,
    [LeadTime] smallint NULL,
    [ItemType] varchar (10) NULL,
	[WHLocationID] varchar(10) null,
	[WHSequence] varchar(50) null,
	[PatientCharge] int not NULL,
	[Updated] int not null,
	[LastUpdated] datetime not null
	
)


END
GO

--*****************************************************
--**************************NEWTABLE**********************
if not exists (select * from sys.tables where name = 'DimBinHistory')
BEGIN
CREATE TABLE [bluebin].[DimBinHistory](
	DimBinHistoryID INT NOT NULL IDENTITY(1,1)  PRIMARY KEY,
	[Date] date,
	BinKey int null,
	[FacilityID] smallint not null,
	[LocationID] varchar(10) not null,
	[ItemID] char(32) NOT NULL,
	BinQty int not null,
	LastBinQty int null,
	Sequence varchar(7) null,
	LastSequence varchar(7) null,
	BinUOM varchar(4) null,
	LastBinUOM varchar(4)

)

END
GO

--*****************************************************
--**************************NEWTABLE**********************

if not exists (select * from sys.tables where name = 'Document')
BEGIN
CREATE TABLE [bluebin].[Document](
	[DocumentID] INT NOT NULL IDENTITY(1,1)  PRIMARY KEY,
	[DocumentName] varchar(100) not null,
	[DocumentType] varchar(30) not NULL,
	[DocumentSource] varchar(100) not NULL,
	--[Document] varbinary(max) NOT NULL,
	[Document] varchar(max) NOT NULL,
	[Active] int not null,
	[DateCreated] DateTime not null,
	[LastUpdated] DateTime not null

)
;
if not exists (select * from bluebin.Document where DocumentSource = 'SOPs')
BEGIN  
insert into bluebin.Document (DocumentName,DocumentType,DocumentSource,Document,Active,DateCreated,LastUpdated) VALUES
('3000 - Replenishing BlueBin Technology Nodes','application/pdf','SOPs','D:\BlueBinDocuments\'+(select DB_NAME())+'\SOPs\3000 - Replenishing BlueBin Technology Nodes.pdf',1,getdate(),getdate()),
('3001 - BlueBin Stage Operations','application/pdf','SOPs','D:\BlueBinDocuments\'+(select DB_NAME())+'\SOPs\3001 - BlueBin Stage Operations.pdf',1,getdate(),getdate()),
('3002 - Filling BBT Orders - Art of Bin Fill','application/pdf','SOPs','D:\BlueBinDocuments\'+(select DB_NAME())+'\SOPs\3002 - Filling BBT Orders - Art of Bin Fill.pdf',1,getdate(),getdate()),
('3003 - Managing BlueBin Stock-Outs','application/pdf','SOPs','D:\BlueBinDocuments\'+(select DB_NAME())+'\SOPs\3003 - Managing BlueBin Stock-Outs.pdf',1,getdate(),getdate()),
('3004 - BlueBin Kanban & Stage Maintenance','application/pdf','SOPs','D:\BlueBinDocuments\'+(select DB_NAME())+'\SOPs\3004 - BlueBin Kanban & Stage Maintenance.pdf',1,getdate(),getdate()),
('3005 - BlueBin Stage Audit Process','application/pdf','SOPs','D:\BlueBinDocuments\'+(select DB_NAME())+'\SOPs\3005 - BlueBin Stage Audit Process.pdf',1,getdate(),getdate()),
('3006 - Stage Audit Form','application/pdf','SOPs','D:\BlueBinDocuments\'+(select DB_NAME())+'\SOPs\3006 - Stage Audit Form.pdf',1,getdate(),getdate()),
('3007 - BlueBIn Daily Health Audit Process','application/pdf','SOPs','D:\BlueBinDocuments\'+(select DB_NAME())+'\SOPs\3007 - BlueBIn Daily Health Audit Process.pdf',1,getdate(),getdate()),
('3008 - BBT Weekly Health Checklist','application/pdf','SOPs','D:\BlueBinDocuments\'+(select DB_NAME())+'\SOPs\3008 - BBT Weekly Health Checklist.pdf',1,getdate(),getdate()),
('3009 - BBT Orange Cone Process','application/pdf','SOPs','D:\BlueBinDocuments\'+(select DB_NAME())+'\SOPs\3009 - BBT Orange Cone Process.pdf',1,getdate(),getdate()),
('3010 - QCN Process','application/pdf','SOPs','D:\BlueBinDocuments\'+(select DB_NAME())+'\SOPs\3010 - QCN Process.pdf',1,getdate(),getdate())
END
;
if not exists (select * from bluebin.Document where DocumentSource = 'FormsSignage')
BEGIN
insert into bluebin.Document (DocumentName,DocumentType,DocumentSource,Document,Active,DateCreated,LastUpdated) VALUES
('NODE SIGNAGE - Main','application/pdf','FormsSignage','D:\BlueBinDocuments\'+(select DB_NAME())+'\FormsSignage\NODE SIGNAGE - Main.pdf',1,getdate(),getdate()),
('QCN Drop','application/pdf','FormsSignage','D:\BlueBinDocuments\'+(select DB_NAME())+'\FormsSignage\QCN Drop.pdf',1,getdate(),getdate()),
('Sequence Worksheet','application/vnd.ms-excel','FormsSignage','D:\BlueBinDocuments\'+(select DB_NAME())+'\FormsSignage\SEQUENCE WORKSHEET.xlsx',1,getdate(),getdate())
END
;
if not exists (select * from bluebin.Document where DocumentSource = 'BeltCertification')
BEGIN
insert into bluebin.Document (DocumentName,DocumentType,DocumentSource,Document,Active,DateCreated,LastUpdated) VALUES
('Belt Certificate Overview','application/ppsx','BeltCertification','D:\BlueBinDocuments\'+(select DB_NAME())+'\BeltCertification\DMS-CERTIFICATION.ppsx',1,getdate(),getdate())
END
;
END
GO

--*****************************************************
--**************************NEWTABLE**********************

if not exists (select * from sys.tables where name = 'BlueBinUserOperations')
BEGIN
CREATE TABLE [bluebin].[BlueBinUserOperations](
	[BlueBinUserID] INT NOT NULL,
	[OpID] INT NOT NULL
)

ALTER TABLE [bluebin].[BlueBinUserOperations] WITH CHECK ADD FOREIGN KEY([BlueBinUserID])
REFERENCES [bluebin].[BlueBinUser] ([BlueBinUserID])

END
GO


--*****************************************************
--**************************NEWTABLE**********************

if not exists (select * from sys.tables where name = 'BlueBinRoleOperations')
BEGIN
CREATE TABLE [bluebin].[BlueBinRoleOperations](
	[RoleID] INT NOT NULL,
	[OpID] INT NOT NULL
)

ALTER TABLE [bluebin].[BlueBinRoleOperations] WITH CHECK ADD FOREIGN KEY([RoleID])
REFERENCES [bluebin].[BlueBinRoles] ([RoleID])

ALTER TABLE [bluebin].[BlueBinRoleOperations] WITH CHECK ADD FOREIGN KEY([OpID])
REFERENCES [bluebin].[BlueBinOperations] ([OpID])

insert into [bluebin].[BlueBinRoleOperations]
select 
RoleID,--(select RoleID from bluebin.BlueBinRoles where RoleName = 'Manager'),
OpID
from  [bluebin].[BlueBinOperations],bluebin.BlueBinRoles 
WHERE OpName like 'ADMIN%' and RoleName in ('SuperUser','BlueBinPersonnel','BlueBelt')

delete from bluebin.BlueBinRoleOperations where OpID = (select OpID from bluebin.BlueBinOperations where OpName = 'ADMIN-CONFIG') and RoleID in (Select RoleID from bluebin.BlueBinRoles where RoleName in ('SuperUser','BlueBelt'))

END
GO


--*****************************************************
--**************************NEWTABLE**********************

/****** Object:  Table [scan].[ScanExtract]     ******/

if not exists (select * from sys.tables where name = 'ScanExtract')
BEGIN
CREATE TABLE [scan].[ScanExtract](
	[ScanExtractID] INT NOT NULL IDENTITY(1,1)  PRIMARY KEY,
	[ScanBatchID] int NOT NULL,
	[ScanLineID] int NOT NULL,
	[ScanExtractDateTime] datetime not null
)

ALTER TABLE [scan].[ScanExtract] WITH CHECK ADD FOREIGN KEY([ScanLineID])
REFERENCES [scan].[ScanLine] ([ScanLineID])

ALTER TABLE [scan].[ScanExtract] WITH CHECK ADD FOREIGN KEY([ScanBatchID])
REFERENCES [scan].[ScanLine] ([ScanLineID])

END
GO

--*****************************************************
--**************************NEWTABLE**********************

/****** Object:  Table [scan].[ScanBatch]     ******/

if not exists (select * from sys.tables where name = 'ScanBatch')
BEGIN
CREATE TABLE [scan].[ScanBatch](
	[ScanBatchID] INT NOT NULL IDENTITY(1,1)  PRIMARY KEY,
	[FacilityID] int NOT NULL,
	[LocationID] varchar(10) NOT NULL,
	[BlueBinUserID] int NULL,
	[Active] int NOT NULL,
	[Extract] int NOT NULL,
	[ScanType] varchar(50) NOT NULL,
	[ScanDateTime] datetime not null
)
END
GO

--*****************************************************
--**************************NEWTABLE**********************


/****** Object:  Table [scan].[ScanLine]     ******/
if not exists (select * from sys.tables where name = 'ScanLine')
BEGIN
CREATE TABLE [scan].[ScanLine](
	[ScanLineID] INT NOT NULL IDENTITY(1,1)  PRIMARY KEY,
	[ScanBatchID] int NOT NULL,
	[Line] int NOT NULL,
	[ItemID] char (32) NOT NULL,
	[Bin] varchar(2) NULL,
	[Qty] int NOT NULL,
	[Active] int NOT NULL,
	[Extract] int NOT NULL,
    [ScanDateTime] datetime NOT NULL
)

ALTER TABLE [scan].[ScanLine] WITH CHECK ADD FOREIGN KEY([ScanBatchID])
REFERENCES [scan].[ScanBatch] ([ScanBatchID])

END
GO

--*****************************************************
--**************************NEWTABLE**********************

if not exists (select * from sys.tables where name = 'ScanMatch')
BEGIN
CREATE TABLE [scan].[ScanMatch](
	[ScanMatchID] INT NOT NULL IDENTITY(1,1)  PRIMARY KEY,
	[ScanLineOrderID] int NOT NULL,
	[ScanLineReceiveID] int NOT NULL,
	[Qty] int NOT NULL,
	[ScanDateTime] datetime not null
)

ALTER TABLE [scan].[ScanMatch] WITH CHECK ADD FOREIGN KEY([ScanLineOrderID])
REFERENCES [scan].[ScanLine] ([ScanLineID])

ALTER TABLE [scan].[ScanMatch] WITH CHECK ADD FOREIGN KEY([ScanLineReceiveID])
REFERENCES [scan].[ScanLine] ([ScanLineID])

END
GO

--*****************************************************
--**************************NEWTABLE**********************

if not exists (select * from sys.tables where name = 'MasterLog')
BEGIN
CREATE TABLE [bluebin].[MasterLog](
	[MasterLogID] INT NOT NULL IDENTITY(1,1)  PRIMARY KEY,
	[BlueBinUserID] int NOT NULL,
	[ActionType] varchar (30) NULL,
    [ActionName] varchar (60) NULL,
	[ActionID] int NULL,
	[ActionDateTime] datetime not null
)
END
GO

--*****************************************************
--**************************NEWTABLE**********************

if not exists (select * from sys.tables where name = 'Config')
BEGIN
CREATE TABLE [bluebin].[Config](
	[ConfigID] INT NOT NULL IDENTITY(1,1)  PRIMARY KEY,
	[ConfigName] varchar (30) NOT NULL,
	[ConfigValue] varchar (50) NOT NULL,
    [Active] int not null,
	[LastUpdated] datetime not null,
	[ConfigType] varchar(50) not null,
	[Description] varchar(255)
)

insert into bluebin.Config (ConfigName,ConfigValue,ConfigType,Active,LastUpdated,[Description])
VALUES
('GLSummaryAccountID','','Tableau',1,getdate(),''),
('PO_DATE','1/1/2015','Tableau',1,getdate(),''),
('TrainingTitle','Tech','DMS',1,getdate(),''),
('BlueBinHardwareCustomer','Demo','DMS',1,getdate(),''),
('TimeOffset','3','DMS',1,getdate(),''),
('CustomerImage','BlueBin_Logo.png','DMS',1,getdate(),''),
('REQ_LOCATION','BB','Tableau',1,getdate(),''),
('Version','1.2.20151211','DMS',1,getdate(),''),
('PasswordExpires','90','DMS',1,getdate(),''),
('SiteAppURL','BlueBinOperations_Demo','DMS',1,getdate(),''),
('TableaURL','/bluebinanalytics/views/Demo/','Tableau',1,getdate(),''),
('LOCATION','STORE','Tableau',1,getdate(),''),
('MENU-Dashboard','1','DMS',1,getdate(),''),
('MENU-Dashboard-HuddleBoard','1','DMS',1,getdate(),''),
('MENU-Dashboard-Sourcing','1','DMS',1,getdate(),''),
('MENU-Dashboard-SupplyChain','1','DMS',1,getdate(),''),
('MENU-Dashboard-Ops','1','DMS',1,getdate(),''),
('MENU-QCN','1','DMS',1,getdate(),''),
('MENU-Gemba','1','DMS',1,getdate(),''),
('MENU-Hardware','1','DMS',1,getdate(),''),
('MENU-Scanning','1','DMS',1,getdate(),''),
('MENU-Other','1','DMS',1,getdate(),''),
('GembaShadowTitle','Tech','DMS',1,getdate(),'BlueBin Resource Title that is available in Shadowed User section of Gemba Audit'),
('GembaShadowTitle','Strider','DMS',1,getdate(),'BlueBin Resource Title that is available in Shadowed User section of Gemba Audit'),
('ReportDateStart','-90','Tableau',1,getdate(),'This value is how many days back to start the analytics for something like the Kanban table'),
('SlowBinDays','90','Tableau',1,getdate(),'This is a configuarble value for how many days you want to configure for a bin to be slow.  Default is 90'),
('StaleBinDays','180','Tableau',1,getdate(),'This is a configuarble value for how many days you want to configure for a bin to be stale.  Default is 180')

update bluebin.Config set [Description] = 'Value in the BlueBinHardware Database for matching invoices. Default=Demo' where ConfigName = 'BlueBinHardwareCustomer'
update bluebin.Config set [Description] = 'Time offset in hours from the server time for custom interface changing. Default=0' where ConfigName = 'TimeOffset'
update bluebin.Config set [Description] = 'Linked image on the Front Page.  Should be NameofHospital_Logo.png. Default=BlueBin_Logo.png' where ConfigName = 'CustomerImage'
update bluebin.Config set [Description] = 'Tableau Setting - REQLINE.REQLOCATION Value that is used for pulling locations in to the Dashboard.  Should be 2 characters.  Default=BB' where ConfigName = 'REQ_LOCATION'
update bluebin.Config set [Description] = 'Current Version of the Application.  Default=current version' where ConfigName = 'Version'
update bluebin.Config set [Description] = 'Default value for password expiration when user is created. Default=90' where ConfigName = 'PasswordExpires'
update bluebin.Config set [Description] = 'Name of the Site app hosted in dms.bluebin.com. Default=Demo' where ConfigName = 'SiteAppURL'
update bluebin.Config set [Description] = 'Tableau Setting - URL for the Tableau Workbook for the site. Default=/bluebinanalytics/views/DemoV22/' where ConfigName = 'TableauURL'
update bluebin.Config set [Description] = 'Tableau Setting - Default setting for the Warehouse for the client in their ERP. Default=STORE' where ConfigName = 'LOCATION'
update bluebin.Config set [Description] = 'Tableau Setting - Will limit the return of rows to one company for ERPs. Default=0 (Boolean 0 is No, 1 is Yes)' where ConfigName = 'SingleCompany'
update bluebin.Config set [Description] = 'Title that will auto create from Resources an entry in the Training table. Default=Tech' where ConfigName = 'TrainingTitle'
update bluebin.Config set [Description] = 'Dashboard Functionality is available for this client. Default=0 (Boolean 0 is No, 1 is Yes)' where ConfigName = 'MENU-Dashboard'
update bluebin.Config set [Description] = 'QCN Functionality is available for this client. Default=0 (Boolean 0 is No, 1 is Yes)' where ConfigName = 'MENU-QCN'
update bluebin.Config set [Description] = 'Gemba Functionality is available for this client. Default=0 (Boolean 0 is No, 1 is Yes)' where ConfigName = 'MENU-Gemba'
update bluebin.Config set [Description] = 'Hardware Functionality is available for this client. Default=0 (Boolean 0 is No, 1 is Yes)' where ConfigName = 'MENU-Hardware'
update bluebin.Config set [Description] = 'Scanning Functionality is available for this client. Default=0 (Boolean 0 is No, 1 is Yes)' where ConfigName = 'MENU-Scanning'
update bluebin.Config set [Description] = 'Other Functionality is available for this client. Default=0 (Boolean 0 is No, 1 is Yes)' where ConfigName = 'MENU-Other'
update bluebin.Config set [Description] = 'Dashboard Supply Chain Functionality is available for this client. Default=0 (Boolean 0 is No, 1 is Yes)' where ConfigName = 'MENU-Dashboard-SupplyChain'
update bluebin.Config set [Description] = 'Dashboard Sourcing Functionality is available for this client. Default=0 (Boolean 0 is No, 1 is Yes)' where ConfigName = 'MENU-Dashboard-Sourcing'
update bluebin.Config set [Description] = 'Dashboard Ops Functionality is available for this client. Default=0 (Boolean 0 is No, 1 is Yes)' where ConfigName = 'MENU-Dashboard-Ops'
update bluebin.Config set [Description] = 'HuddleBoard Functionality is available for this client. Default=0 (Boolean 0 is No, 1 is Yes)' where ConfigName = 'MENU-Dashboard-HuddleBoard'
update bluebin.Config set [Description] = 'Tableau Setting - Custom setting to only pull POs from a certain date. Format as MM/DD/YYYY Default=1/1/2015' where ConfigName = 'PO_DATE'
update bluebin.Config set [Description] = 'Tableau Setting - GLACCOUNT value that can be custom set in Tableu. Default=70' where ConfigName = 'GLSummaryAccountID'

END
GO

--*****************************************************
--**************************NEWTABLE**********************

if not exists (select * from sys.tables where name = 'BlueBinResource')
BEGIN
CREATE TABLE [bluebin].[BlueBinResource](
	[BlueBinResourceID] INT NOT NULL IDENTITY(1,1)  PRIMARY KEY,
	[FirstName] varchar (30) NOT NULL,
	[LastName] varchar (30) NOT NULL,
	[MiddleName] varchar (30) NULL,
    [Login] varchar (30) NULL,
	[Email] varchar (60) NULL,
	[Phone] varchar (20) NULL,
	[Cell] varchar (20) NULL,
	[Title] varchar (50) NULL,
    [Active] int not null,
	[LastUpdated] datetime not null
)
END
GO

--*****************************************************
--**************************NEWTABLE**********************

if not exists (select * from sys.tables where name = 'BlueBinUser')
BEGIN
CREATE TABLE [bluebin].[BlueBinUser](
	[BlueBinUserID] INT NOT NULL IDENTITY(1,1)  PRIMARY KEY,
	[UserLogin] varchar (60) NOT NULL,
	[FirstName] varchar (30) NOT NULL,
	[LastName] varchar (30) NOT NULL,
	[MiddleName] varchar (30) NULL,
    [Email] varchar (60) NULL,
    [Active] int not null,
	[Password] varchar(30) not null,
	[RoleID] int null,
	[LastLoginDate] datetime not null,
	[MustChangePassword] int not null,
	[PasswordExpires] int not null,
	[LastUpdated] datetime not null,
	GembaTier varchar(50) null,
	ERPUser varchar(60) null,
	AssignToQCN int not null
)

ALTER TABLE [bluebin].[MasterLog] WITH CHECK ADD FOREIGN KEY([BlueBinUserID])
REFERENCES [bluebin].[BlueBinUser] ([BlueBinUserID])

ALTER TABLE [bluebin].[BlueBinUser] ADD CONSTRAINT U_Login UNIQUE(UserLogin)

END
GO


--*****************************************************
--**************************NEWTABLE**********************
if not exists (select * from sys.tables where name = 'BlueBinRoles')
BEGIN
CREATE TABLE [bluebin].[BlueBinRoles](
	[RoleID] INT NOT NULL IDENTITY(1,1)  PRIMARY KEY,
	[RoleName] varchar (50) NOT NULL
)

ALTER TABLE [bluebin].[BlueBinUser] WITH CHECK ADD FOREIGN KEY([RoleID])
REFERENCES [bluebin].[BlueBinRoles] ([RoleID])

insert into [bluebin].[BlueBinRoles] (RoleName) VALUES
('User'),
('BlueBelt'),
('BlueBinPersonnel'),
('SuperUser')

END
GO

--*****************************************************
--**************************NEWTABLE**********************

if not exists (select * from sys.tables where name = 'BlueBinOperations')
BEGIN
CREATE TABLE [bluebin].[BlueBinOperations](
	[OpID] INT NOT NULL IDENTITY(1,1)  PRIMARY KEY,
	[OpName] varchar (50) NOT NULL,
	[Description] varchar (255) NULL
)

Insert into bluebin.BlueBinOperations (OpName,[Description]) VALUES
('ADMIN-MENU','Give User ability to see the Main Admin Menu'),
('ADMIN-CONFIG','Give User ability to see the Sub Admin Menu Config'),
('ADMIN-USERS','Give User ability to see the Sub Admin Menu User Administration'),
('ADMIN-RESOURCES','Give User ability to see the Sub Admin Menu Resources'),
('ADMIN-TRAINING','Give User ability to see the Sub Admin Menu Training'),
('MENU-Dashboard','Give User ability to see the Dashboard Menu'),
('MENU-QCN','Give User ability to see the QCN Menu'),
('MENU-Gemba','Give User ability to see the Gemba Menu'),
('MENU-Hardware','Give User ability to see the Hardware Menu'),
('MENU-Scanning','Give User ability to see the Scanning Menu'),
('MENU-Other','Give User ability to see the Other Menu'),
('MENU-Dashboard-SupplyChain','Give User ability to see the Supply Chain DB'),
('MENU-Dashboard-Sourcing','Give User ability to see the Sourcing DB'),
('MENU-Dashboard-Ops','Give User ability to see the Op Performance DB'),
('MENU-Dashboard-HuddleBoard','Give User ability to see the Huddle Board')

END
GO

--*****************************************************
--**************************NEWTABLE**********************


if not exists (select * from sys.tables where name = 'Image')
BEGIN
CREATE TABLE [bluebin].[Image](
	[ImageID] INT NOT NULL IDENTITY(1,1)  PRIMARY KEY,
	[ImageName] varchar(100) not null,
	[ImageType] varchar(10) not NULL,
	[ImageSource] varchar(100) not NULL,
	[ImageSourceID] int not null,	
	[Image] varbinary(max) NOT NULL,
	[Active] int not null,
	[DateCreated] DateTime not null,
	[LastUpdated] DateTime not null

)
END
GO
--ALTER TABLE [bluebin].[Image] WITH CHECK ADD FOREIGN KEY([ImageTypeID])
--REFERENCES [gemba].[GembaAuditNode] ([GembaAuditNodeID])


--*****************************************************
--**************************NEWTABLE**********************

if not exists (select * from sys.tables where name = 'GembaAuditStage')
BEGIN
CREATE TABLE [gemba].[GembaAuditStage](
	[GembaAuditStageID] INT NOT NULL IDENTITY(1,1)  PRIMARY KEY,
	[Date] datetime not null,
	[AuditerUserID]  int NOT NULL,
	[KanbansFilled]  int NOT NULL,
	[KanbansFilledText]  varchar(max) NULL,
	[LeftBehind]  int NOT NULL,
	[FollowUpDistrib]  int NOT NULL,
	[FollowUpDistribText]  varchar(max) NULL,
	[Concerns]  varchar(max) NULL,
	[DirectOrderBins]  int NOT NULL,
	[OldestBin]  datetime NOT NULL,
	[CheckOpenOrders]  int NOT NULL,
	[CheckOpenOrdersText]  varchar(max) NULL,
	[HowManyLate]  int NOT NULL,
	[FollowUpBuyers]  int NOT NULL,
	[FollowUpBuyersText]  varchar(max) NULL,
	[UpdatedStatusTag]  int NOT NULL,
	[UpdatedStatusTagText]  varchar(max) NULL,
	[ReqsSubmitted]  int NULL,
	[ReqsSubmittedText]  varchar(max) NULL,
	[BinsInOrder]  int NULL,
	[BinsInOrderText]  varchar(max) NULL,
	[AreaNeatTidy]  int NULL,
	[AreaNeatTidyText]  varchar(max) NULL,
	[CartsClean]  int NULL,
	[CartsCleanText]  varchar(max) NULL,
	[AdditionalComments] varchar(max) NULL,
	[Active] int not null,
	[LastUpdated] datetime not null

)

ALTER TABLE [gemba].[GembaAuditStage] WITH CHECK ADD FOREIGN KEY([AuditerUserID])
REFERENCES [bluebin].[BlueBinUser] ([BlueBinUserID])

END
GO

--*****************************************************
--**************************NEWTABLE**********************
if not exists (select * from sys.tables where name = 'GembaAuditNode')
BEGIN
CREATE TABLE [gemba].[GembaAuditNode](
	[GembaAuditNodeID] INT NOT NULL IDENTITY(1,1)  PRIMARY KEY,
	[Date] datetime not null,
	[LocationID] varchar(10) not null,
	[AuditerUserID]  int NOT NULL,
	[AdditionalComments] varchar(max) NULL,
    [PS_EmptyBins] int NOT NULL,
	    [PS_BackBins] int NOT NULL,
		    [PS_StockOuts] int NOT NULL,
			    [PS_ReturnVolume] int NOT NULL,
				    [PS_NonBBT] int NOT NULL,
						[PS_OrangeCones] int NOT NULL,
				[PS_Comments] varchar(max) NULL,
    [RS_BinsFilled] int NOT NULL,
	    [RS_EmptiesCollected] int NOT NULL,
			[RS_BinServices] int NOT NULL,
				[RS_NodeSwept] int NOT NULL,
					[RS_NodeCorrections] int NOT NULL,
							[RS_ShadowedUserID] int NULL,
				[RS_Comments] varchar(max) NULL,
	 [SS_Supplied] int NOT NULL,
	    [SS_KanbansPP] int NOT NULL,
		    [SS_StockoutsPT] int NOT NULL,
			    [SS_StockoutsMatch] int NOT NULL,
					[SS_HuddleBoardMatch] int NOT NULL,
				[SS_Comments] varchar(max) NULL,
	    [NIS_Labels] int NOT NULL,
		    [NIS_CardHolders] int NOT NULL,
			    [NIS_BinsRacks] int NOT NULL,
				    [NIS_GeneralAppearance] int NOT NULL,
					    [NIS_Signage] int NOT NULL,
				[NIS_Comments] varchar(max) NULL,
[PS_TotalScore] int Not null,
[RS_TotalScore] int not null,
[SS_TotalScore] int not null,
[NIS_TotalScore] int not null,
[TotalScore] int not null,
[Active] int not null,
[LastUpdated] datetime not null

)

--ALTER TABLE [qcn].[QCNRequest] WITH CHECK ADD FOREIGN KEY([LocationID])
--REFERENCES [bluebin].[DimBin] ([LocationID])

--ALTER TABLE [qcn].[QCNRequest] WITH CHECK ADD FOREIGN KEY([ItemID])
--REFERENCES [bluebin].[DimBin] ([ItemID])

ALTER TABLE [gemba].[GembaAuditNode] WITH CHECK ADD FOREIGN KEY([AuditerUserID])
REFERENCES [bluebin].[BlueBinUser] ([BlueBinUserID])

ALTER TABLE [gemba].[GembaAuditNode] WITH CHECK ADD FOREIGN KEY([RS_ShadowedUserID])
REFERENCES [bluebin].[BlueBinResource] ([BlueBinResourceID])
END
GO

--*****************************************************
--**************************NEWTABLE**********************
if not exists (select * from sys.tables where name = 'QCN')
BEGIN
CREATE TABLE [qcn].[QCN](
	[QCNID] INT NOT NULL IDENTITY(1,1)  PRIMARY KEY,
	[LocationID] varchar(10) not null,
	[ItemID] char(32) null,
	[RequesterUserID] int NOT NULL,
	[AssignedUserID] int NULL,
	[QCNTypeID] int NOT NULL,
	[Details] varchar(max) NULL,
	[Updates] varchar(max) NULL,
	[DateEntered] datetime not null,
	[DateCompleted] datetime null,
	[QCNStatusID] int NOT NULL,
	[Active] int not null,
	[LastUpdated] datetime not null

)

ALTER TABLE [qcn].[QCN] WITH CHECK ADD FOREIGN KEY([RequesterUserID])
REFERENCES [bluebin].[BlueBinResource] ([BlueBinResourceID])

ALTER TABLE [qcn].[QCN] WITH CHECK ADD FOREIGN KEY([AssignedUserID])
REFERENCES [bluebin].[BlueBinResource] ([BlueBinResourceID])
END
GO


--*****************************************************
--**************************NEWTABLE**********************

if not exists (select * from sys.tables where name = 'QCNStatus')
BEGIN
CREATE TABLE [qcn].[QCNStatus](
	[QCNStatusID] INT NOT NULL IDENTITY(1,1)  PRIMARY KEY,
	[Status] [varchar](255) NOT NULL,
	[Description] varchar(100) null,
	[Active] int not null,
	[LastUpdated] datetime not null
)

ALTER TABLE [qcn].[QCN] WITH CHECK ADD FOREIGN KEY([QCNStatusID])
REFERENCES [qcn].[QCNStatus] ([QCNStatusID])

insert into qcn.QCNStatus (Status,Active,LastUpdated,Description) VALUES
('New/NotStarted','1',getdate(),'Logged, not yet evaluated for next steps.'),
('InProgress/Approved','1',getdate(),'No additional support needed, QCN will be completed within 10 working days.'),
('NeedsMoreInfo','1',getdate(),'Requester/clinical/other clarification.'),
('AwaitingApproval','1',getdate(),'New items only, e.g. Value Analysis, Product Standards, or other new product committee process.'),
('InFileMaintenance','1',getdate(),'New ERP # or other item activation steps.'),
('Rejected','1',getdate(),'QCN is rejected.  This will remove the record off the Live board.'),
('Completed','1',getdate(),'QCN is done.  This will remove the record off the Live board.')

END
GO

--*****************************************************
--**************************NEWTABLE**********************

if not exists (select * from sys.tables where name = 'QCNType')
BEGIN
CREATE TABLE [qcn].[QCNType](
	[QCNTypeID] INT NOT NULL IDENTITY(1,1)  PRIMARY KEY,
	[Name] [varchar](255) NOT NULL,
	[Description] varchar(100) null,
	[Active] int not null,
	[LastUpdated] datetime not null
)

ALTER TABLE [qcn].[QCN] WITH CHECK ADD FOREIGN KEY([QCNTypeID])
REFERENCES [qcn].[QCNType] ([QCNTypeID])

Insert into [qcn].[QCNType] VALUES 
('ADD','',1,getdate()),
('MODIFY','',1,getdate()),
('REMOVE','',1,getdate())

END

GO

--*****************************************************
--**************************NEWTABLE**********************

if not exists (select * from sys.tables where name = 'QCNComplexity')
BEGIN
CREATE TABLE [qcn].[QCNComplexity](
	[QCNCID] INT NOT NULL IDENTITY(1,1)  PRIMARY KEY,
	[Name] [varchar](255) NOT NULL,
	[Description] varchar(100) null,
	[Active] int not null,
	[LastUpdated] datetime not null
)


Insert into [qcn].[QCNComplexity] VALUES 
('1','Many Nodes, Many Moves',1,getdate()),
('2','Not Many Nodes, Many Moves',1,getdate()),
('3','Many Nodes, Not Many Moves',1,getdate()),
('4','Not Many Nodes, Not Many Moves',1,getdate())

END
GO

SET ANSI_PADDING OFF
GO

Print 'Table Adds Complete'


--*************************************************************************************************************************************
--*************************************************************************************************************************************

--Sprocs

--*************************************************************************************************************************************
--*************************************************************************************************************************************




--*****************************************************
--**************************SPROC**********************


if exists (select * from dbo.sysobjects where id = object_id(N'sp_SelectScanLinesReceive') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_SelectScanLinesReceive
GO

--exec sp_SelectScanLinesReceive 1

/*
select * from scan.ScanMatch
select * from scan.ScanLine where ScanLineID = 25


*/
CREATE PROCEDURE sp_SelectScanLinesReceive
@ScanBatchID int

--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON
select 
sbr.ScanBatchID,
db.BinKey,
db.BinSequence,
rtrim(sbr.LocationID) as LocationID,
dl.LocationName as LocationName,
slr.ItemID,
di.ItemDescription,
slr.Qty,
slo.Line,
sbr.ScanDateTime as [DateScanned],
bbu.LastName + ', ' + bbu.FirstName as ScannedBy

from scan.ScanMatch sm
inner join scan.ScanLine slr on sm.ScanLineReceiveID = slr.ScanLineID
inner join scan.ScanLine slo on sm.ScanLineOrderID = slo.ScanLineID
inner join scan.ScanBatch sbr on slr.ScanBatchID = sbr.ScanBatchID 
inner join scan.ScanBatch sbo on slo.ScanBatchID = sbo.ScanBatchID 
inner join bluebin.DimBin db on sbr.LocationID = db.LocationID and slr.ItemID = db.ItemID
inner join bluebin.DimItem di on slr.ItemID = di.ItemID
inner join bluebin.DimLocation dl on sbr.LocationID = dl.LocationID
inner join bluebin.BlueBinUser bbu on sbr.BlueBinUserID = bbu.BlueBinUserID
where slo.ScanBatchID = @ScanBatchID and slo.Active = 1
order by slo.Line

--11 --

END
GO
grant exec on sp_SelectScanLinesReceive to public
GO




--*****************************************************
--**************************SPROC**********************



if exists (select * from dbo.sysobjects where id = object_id(N'sp_InsertScanLineReceive') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_InsertScanLineReceive
GO

/* 
exec sp_InsertScanBatch 'BB013','gbutler@bluebin.com','Receive'
exec sp_InsertScanLineReceive 17,'0000014','1'
exec sp_InsertScanLineReceive 17,'0000017','1'
exec sp_InsertScanLineReceive 16,'0000018','1'

select * from scan.ScanLine where Line = 0
select * from scan.ScanMatch
delete from scan.ScanLine where ScanBatchID in (select ScanBatchID from scan.ScanBatch where ScanType = 'Receive')
*/

CREATE PROCEDURE sp_InsertScanLineReceive
@ScanBatchID int,
@Item varchar(30),
@Qty int,
@Line int

--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON

if exists (select * from bluebin.DimItem where ItemID = @Item) 
BEGIN
declare @ScanMatchLocationID varchar(10) 
declare @ScanMatchFacilityID int 
declare @ScanMatchItemID varchar(32) = @Item
declare @ScanMatchScanLineOrderID int
declare @ScanMatchScanLineReceiveID int
declare @ScanMatch table (ScanBatchID int,ScanLineOrderID int,FaciltyID int,LocationID varchar(7),ItemID varchar(32),Qty int)

select @ScanMatchFacilityID = FacilityID from scan.ScanBatch where ScanBatchID = @ScanBatchID
select @ScanMatchLocationID = LocationID from scan.ScanBatch where ScanBatchID = @ScanBatchID
select @ScanMatchScanLineOrderID = 
min(ScanLineID)
from scan.ScanBatch sb
inner join scan.ScanLine sl on sb.ScanBatchID = sl.ScanBatchID
where
sb.FacilityID = @ScanMatchFacilityID and
sb.LocationID = @ScanMatchLocationID and
sl.ItemID = @Item and 
sb.ScanType like '%Order' and
sl.ScanLineID not in (select ScanLineOrderID from scan.ScanMatch)

		if @ScanMatchScanLineOrderID is not null 
		BEGIN
		insert into scan.ScanLine (ScanBatchID,Line,ItemID,Qty,Active,ScanDateTime,Extract)
			select 
			@ScanBatchID,
			0,--Default Received Line to 0 for identification purposes
			@Item,
			@Qty,
			1,--Active Default to Yes
			getdate(),
			0 --Extract default to No, will not extract this.

		set @ScanMatchScanLineReceiveID = SCOPE_IDENTITY()

		insert into scan.ScanMatch (ScanLineOrderID,ScanLineReceiveID,Qty,ScanDateTime) VALUES
		(@ScanMatchScanLineOrderID,@ScanMatchScanLineReceiveID,@Qty,getdate())
		END
			ELSE
			BEGIN
			SELECT -2 -- Backout if there is no existing item waiting to be scanned in
			delete from scan.ScanMatch where ScanLineReceiveID in (select ScanLineID from scan.ScanLine where ScanBatchID = @ScanBatchID)
			delete from scan.ScanLine where ScanBatchID = @ScanBatchID
			delete from scan.ScanBatch where ScanBatchID = @ScanBatchID
			END

END
	ELSE
	BEGIN
	SELECT -1 -- Back out scan if there is an issue with the Item existing
	delete from scan.ScanLine where ScanBatchID = @ScanBatchID
	delete from scan.ScanBatch where ScanBatchID = @ScanBatchID
	END

END
GO
grant exec on sp_InsertScanLineReceive to public
GO





--*****************************************************
--**************************SPROC**********************

if exists (select * from dbo.sysobjects where id = object_id(N'sp_SelectUserName') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_SelectUserName
GO

--exec sp_SelectUserName'gbutler@bluebin.com'
CREATE PROCEDURE sp_SelectUserName
@UserLogin varchar(100)

--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON
select 
FirstName
from  [bluebin].[BlueBinUser] 

WHERE LOWER(UserLogin)=LOWER(@UserLogin)

END
GO
grant exec on sp_SelectUserName to appusers
GO

--*****************************************************
--**************************SPROC**********************

if exists (select * from dbo.sysobjects where id = object_id(N'sp_SelectFacilityName') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_SelectFacilityName
GO

--exec sp_SelectFacilityName
CREATE PROCEDURE sp_SelectFacilityName

--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON
select ConfigValue from bluebin.Config where ConfigName = 'FriendlySiteName'

END
GO
grant exec on sp_SelectFacilityName to appusers
GO

--*****************************************************
--**************************SPROC**********************

if exists (select * from dbo.sysobjects where id = object_id(N'sp_SelectScanDates') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_SelectScanDates
GO

--exec sp_SelectScanDates ''
CREATE PROCEDURE sp_SelectScanDates


--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON

SELECT DISTINCT 
convert(varchar,(convert(Date,ScanDateTime)),111) as ScanDate
from scan.ScanBatch
WHERE Active = 1 --and convert(Date,ScanDateTime) = @ScanDate 
order by 1 desc

END 
GO
grant exec on sp_SelectScanDates to public
GO






--*****************************************************
--**************************SPROC**********************

if exists (select * from dbo.sysobjects where id = object_id(N'sp_ExtractScansXML') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_ExtractScansXML
GO

--exec sp_ExtractScansXML

CREATE PROCEDURE sp_ExtractScansXML

--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON

select
sb.ScanBatchID as '@ID',
ltrim(rtrim(sb.LocationID)) as LocationID,
sl.Line as Line,
ltrim(rtrim(sl.ItemID)) as ItemID,
sl.Qty as Qty,
sb.ScanDateTime as ScanDateTime
from 
scan.ScanBatch sb
inner join scan.ScanLine sl on sb.ScanBatchID = sl.ScanBatchID
where sl.Extract = 1

FOR XML PATH('ScanBatch'), ROOT('Scans')

END
GO
grant exec on sp_ExtractScansXML to appusers
GO

--*****************************************************
--**************************SPROC**********************

if exists (select * from dbo.sysobjects where id = object_id(N'sp_InsertDocument') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_InsertDocument
GO

--exec sp_InsertDocument 'TestDocument','application/pdf','SOPs','gbutler@bluebin.com','C:\BlueBinDocuments\DemoV22\SOPs\3000 - Replenishing BlueBin Technology Nodes.pdf'
CREATE PROCEDURE sp_InsertDocument
@DocumentName varchar(100),
@DocumentType varchar(30),
@DocumentSource varchar(100),
@UserLogin varchar(60),
@Document varchar(max)

--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON
if not exists (select * from bluebin.Document where DocumentName = @DocumentName and DocumentSource = @DocumentSource)
BEGIN
insert into bluebin.[Document] 
(DocumentName,DocumentType,DocumentSource,[Document],[Active],[DateCreated],[LastUpdated])        
VALUES 
(@DocumentName,@DocumentType,@DocumentSource,@Document,1,getdate(),getdate())
END
ELSE
	BEGIN
	update bluebin.[Document] set Document = @Document, LastUpdated = getdate() where DocumentName = @DocumentName and DocumentSource = @DocumentSource
	END

Declare @DocumentID int  = SCOPE_IDENTITY()
declare @Text varchar(60) = 'Insert Document - '+left(@DocumentName,30)
exec sp_InsertMasterLog @UserLogin,'Documents',@Text,@DocumentID

END
GO
grant exec on sp_InsertDocument to appusers
GO



--*****************************************************
--**************************SPROC**********************

if exists (select * from dbo.sysobjects where id = object_id(N'sp_SelectDocuments') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_SelectDocuments
GO

--exec sp_SelectDocuments 'gbutler@bluebin.com','FormsSignage'
CREATE PROCEDURE sp_SelectDocuments
@UserLogin varchar(60),
@DocumentSource varchar(20)



--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON
if exists (select * from bluebin.Document where DocumentSource = @DocumentSource)
BEGIN
	Select 
	DocumentID,
	DocumentName,
	DocumentType,
	DocumentSource,
	Document,
	Active,
	DateCreated,
	LastUpdated
	from bluebin.[Document]    
	where 
	DocumentSource = @DocumentSource
	order by DocumentName asc
END
ELSE
BEGIN
Select 
	0 as DocumentID,
	'*No Documents Available*' as DocumentName,
	'' as DocumentType,
	'' as DocumentSource,
	'' as Document,
	'' as Active,
	'' as DateCreated,
	'' as LastUpdated
END

END
GO
grant exec on sp_SelectDocuments to appusers
GO

--*****************************************************
--**************************SPROC**********************

if exists (select * from dbo.sysobjects where id = object_id(N'sp_DeleteDocument') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_DeleteDocument
GO


--exec sp_DeleteDocument 'gbutler@bluebin.com','1'
CREATE PROCEDURE sp_DeleteDocument
@UserLogin varchar(60),
@DocumentID int


--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON
delete
from bluebin.[Document]    
where 
DocumentID = @DocumentID


END
GO
grant exec on sp_DeleteDocument to appusers
GO

--*****************************************************
--**************************SPROC**********************


if exists (select * from dbo.sysobjects where id = object_id(N'sp_SelectDocumentSingle') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_SelectDocumentSingle
GO

--exec sp_SelectDocumentSingle 10
CREATE PROCEDURE sp_SelectDocumentSingle
@DocumentID int



--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON
select DocumentName, Document, DocumentType from bluebin.Document where DocumentID=@DocumentID


END
GO
grant exec on sp_SelectDocumentSingle to appusers
GO


--*****************************************************
--**************************SPROC**********************

if exists (select * from dbo.sysobjects where id = object_id(N'sp_SelectSingleConfig') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_SelectSingleConfig
GO

--exec sp_SelectSingleConfig 'SiteAppURL'

CREATE PROCEDURE sp_SelectSingleConfig
@ConfigName varchar(30)

--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON
	SELECT 
	ConfigValue
	
	FROM bluebin.[Config]
	where ConfigName = @ConfigName and Active = 1

END
GO
grant exec on sp_SelectSingleConfig to appusers
GO


--*****************************************************
--**************************SPROC**********************

if exists (select * from dbo.sysobjects where id = object_id(N'sp_InsertUserOperations') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_InsertUserOperations
GO


CREATE PROCEDURE sp_InsertUserOperations
@BlueBinUserID int,
@OpID int


--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON

insert into bluebin.BlueBinUserOperations select @BlueBinUserID,@OpID

END
GO
grant exec on sp_InsertUserOperations to appusers
GO


--*****************************************************
--**************************SPROC**********************

if exists (select * from dbo.sysobjects where id = object_id(N'sp_InsertRoleOperations') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_InsertRoleOperations
GO


CREATE PROCEDURE sp_InsertRoleOperations
@RoleID int,
@OpID int


--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON

insert into bluebin.BlueBinRoleOperations select @RoleID,@OpID

END
GO
grant exec on sp_InsertRoleOperations to appusers
GO


--*****************************************************
--**************************SPROC**********************
if exists (select * from dbo.sysobjects where id = object_id(N'sp_SelectUserOperations') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_SelectUserOperations
GO

--exec sp_SelectUserOperations 'Butler'
CREATE PROCEDURE sp_SelectUserOperations
@Name varchar(50)
--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON
Select 
bbuo.BlueBinUserID,
bbuo.OpID,
LOWER(bbu.UserLogin) as UserLogin,
bbu.LastName + ', ' + FirstName as Name,
bbr.RoleName as [CurrentRole],
bbo.OpName 
from bluebin.BlueBinUserOperations bbuo
inner join bluebin.BlueBinUser bbu on bbuo.BlueBinUserID = bbu.BlueBinUserID
inner join bluebin.BlueBinRoles bbr on bbu.RoleID = bbr.RoleID
inner join bluebin.BlueBinOperations bbo on bbuo.OpID = bbo.OpID
where bbu.Active = 1
  and
  ([LastName] like '%' + @Name + '%' 
	OR [FirstName] like '%' + @Name + '%' )
	or bbo.OpName like '%' + @Name + '%' 
order by bbu.LastName + ', ' + FirstName,bbo.OpName

END
GO
grant exec on sp_SelectUserOperations to appusers
GO

--*****************************************************
--**************************SPROC**********************

if exists (select * from dbo.sysobjects where id = object_id(N'sp_SelectRoleOperations') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_SelectRoleOperations
GO

--exec sp_SelectRoleOperations ''
CREATE PROCEDURE sp_SelectRoleOperations
@Name varchar(50)

--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON
Select 
bbro.RoleID,
bbro.OpID,
bbr.RoleName,
bbo.OpName 
from bluebin.BlueBinRoleOperations bbro
inner join bluebin.BlueBinRoles bbr on bbro.RoleID = bbr.RoleID
inner join bluebin.BlueBinOperations bbo on bbro.OpID = bbo.OpID
where bbr.RoleName like '%' + @Name + '%'  or bbo.OpName like '%' + @Name + '%'
order by bbr.RoleName,bbo.OpName

END
GO
grant exec on sp_SelectRoleOperations to appusers
GO

--*****************************************************
--**************************SPROC**********************

if exists (select * from dbo.sysobjects where id = object_id(N'sp_EditOperations') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_EditOperations
GO


CREATE PROCEDURE sp_EditOperations
@OpID int,
@OpName varchar(50),
@Description varchar(255)


--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON

update bluebin.BlueBinOperations set OpName = @OpName, [Description] = @Description where OpID = @OpID
END
GO
grant exec on sp_EditOperations to appusers
GO

--*****************************************************
--**************************SPROC**********************

if exists (select * from dbo.sysobjects where id = object_id(N'sp_InsertOperations') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_InsertOperations
GO


CREATE PROCEDURE sp_InsertOperations
@OpName varchar(50),
@Description varchar(255)


--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON
if not exists(select * from bluebin.BlueBinOperations where OpName = @OpName)
BEGIN
insert into bluebin.BlueBinOperations select @OpName,@Description
END

END
GO
grant exec on sp_InsertOperations to appusers
GO


--*****************************************************
--**************************SPROC**********************

if exists (select * from dbo.sysobjects where id = object_id(N'sp_SelectOperations') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_SelectOperations
GO


CREATE PROCEDURE sp_SelectOperations
@OpName varchar(50)


--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON
Select OpID,OpName,
isnull([Description],'') as [Description] from bluebin.BlueBinOperations
where OpName like '%' + @OpName + '%'
order by OpName

END
GO
grant exec on sp_SelectOperations to appusers
GO
--*****************************************************
--**************************SPROC**********************

if exists (select * from dbo.sysobjects where id = object_id(N'sp_ValidateMenus') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_ValidateMenus
GO

--exec sp_ValidateMenus 'MENU-QCN'

CREATE PROCEDURE [dbo].[sp_ValidateMenus]
	@ConfigName NVARCHAR(50)
AS
BEGIN
SET NOCOUNT ON;

declare @Menu as Table (ConfigValue varchar(50))

Select 
Case	
	When ConfigValue = 1 or ConfigValue = 'Yes' Then 'Yes'
	Else 'No'
	End as ConfigValue
from bluebin.Config 
where ConfigName = @ConfigName


END
GO
grant exec on sp_ValidateMenus to appusers
GO

--*****************************************************
--**************************SPROC**********************

if exists (select * from dbo.sysobjects where id = object_id(N'sp_ValidateBlueBinRole') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_ValidateBlueBinRole
GO

--exec sp_ValidateBlueBinRole 'dhagan@bluebin.com','ADMIN-CONFIG'

CREATE PROCEDURE [dbo].[sp_ValidateBlueBinRole]
      @UserLogin NVARCHAR(60),
	  @OpName NVARCHAR(50)
AS
BEGIN
SET NOCOUNT ON;
--Select RoleName from bluebin.BlueBinRoles
--where RoleID in (select RoleID from bluebin.BlueBinUser where LOWER(UserLogin) = LOWER(@UserLogin))

declare @UserOp as Table (OpName varchar(50))

insert into @UserOp
select 
Distinct 
OpName 
from bluebin.BlueBinOperations
where 
OpID in (select OpID from bluebin.BlueBinUserOperations where BlueBinUserID = (select BlueBinUserID from bluebin.BlueBinUser where LOWER(UserLogin) = LOWER(@UserLogin)))
or
OpID in (select OpID from bluebin.BlueBinRoleOperations where RoleID in (select RoleID from bluebin.BlueBinUser where LOWER(UserLogin) = LOWER(@UserLogin)))


if exists(select * from @UserOp where OpName = @OpName)
BEGIN
	Select 'Yes'
END
ELSE
	Select 'No'


END
GO
grant exec on sp_ValidateBlueBinRole to appusers
GO

--*****************************************************
--**************************SPROC**********************
if exists (select * from dbo.sysobjects where id = object_id(N'sp_SelectTrainingModule') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_SelectTrainingModule
GO


--exec sp_SelectTrainingModule 
CREATE PROCEDURE sp_SelectTrainingModule



--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON
select 
ModuleName,
ModuleDescription,
Active,
Required,
LastUpdated
 from bluebin.TrainingModule


END

GO
grant exec on sp_SelectTrainingModule to appusers
GO

--*****************************************************
--**************************SPROC**********************
if exists (select * from dbo.sysobjects where id = object_id(N'sp_InsertTrainingModule') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_InsertTrainingModule
GO

--exec sp_InsertTrainingModule '',''
--select * from bluebin.TrainingModule

CREATE PROCEDURE sp_InsertTrainingModule 
@ModuleName varchar(50),
@ModuleDescription varchar(255),
@Required int


--WITH ENCRYPTION 
AS
BEGIN
SET NOCOUNT ON

if not exists (select * from bluebin.TrainingModule where ModuleName = @ModuleName)
	BEGIN
	insert into bluebin.TrainingModule (ModuleName,ModuleDescription,[Active],Required,[LastUpdated])
	select 
		@ModuleName,
		@ModuleDescription,
		1, --Default Active to Yes
		@Required,
		getdate()

		END
END
GO

grant exec on sp_InsertTrainingModule to appusers
GO



--*****************************************************
--**************************SPROC**********************
if exists (select * from dbo.sysobjects where id = object_id(N'sp_DeleteTrainingModule') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_DeleteTrainingModule
GO

CREATE PROCEDURE sp_DeleteTrainingModule
@TrainingModuleID int

--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON
Update [bluebin].[TrainingModule] set [Active] = 0, [LastUpdated] = getdate() where TrainingModuleID = @TrainingModuleID

END
GO
grant exec on sp_DeleteTrainingModule to appusers
GO

--*****************************************************
--**************************SPROC**********************

if exists (select * from dbo.sysobjects where id = object_id(N'sp_EditTrainingModule') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_EditTrainingModule
GO

--exec sp_EditTrainingModule ''
--select * from [bluebin].[TrainingModule]


CREATE PROCEDURE sp_EditTrainingModule
@TrainingModuleID int, 
@ModuleName varchar(50),
@ModuleDescription varchar(255),
@Required int

--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON


update [bluebin].[TrainingModule]
set
ModuleName=@ModuleName,
ModuleDescription=@ModuleDescription,
@Required=@Required,
LastUpdated = getdate()
where TrainingModuleID = @TrainingModuleID
	;

END
GO

grant exec on sp_EditTrainingModule to appusers
GO



--*****************************************************
--**************************SPROC**********************
if exists (select * from dbo.sysobjects where id = object_id(N'sp_SelectTraining') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_SelectTraining
GO

--select * from bluebin.Training  select * from bluebin.BlueBinResource
--exec sp_SelectTraining '','300'
CREATE PROCEDURE sp_SelectTraining
@Name varchar (30),
@Module varchar (50)


--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON
SELECT 
bbt.[TrainingID],
bbt.[BlueBinResourceID], 
bbr.[LastName] + ', ' +bbr.[FirstName] as ResourceName, 
bbr.Title,
bbt.Status,
ISNULL(trained.Ct,0) as Trained,
ISNULL(trained.Ct,0) + ISNULL(nottrained.Ct,0) as Total,
bbtm.ModuleName,
bbtm.ModuleDescription,
ISNULL((bbu.[LastName] + ', ' +bbu.[FirstName]),'N/A') as Updater,
case when bbt.Active = 0 then 'No' else 'Yes' end as Active,

bbt.LastUpdated

FROM [bluebin].[Training] bbt
inner join [bluebin].[BlueBinResource] bbr on bbt.[BlueBinResourceID] = bbr.[BlueBinResourceID]
inner join bluebin.TrainingModule bbtm on bbt.TrainingModuleID = bbtm.TrainingModuleID
left join [bluebin].[BlueBinUser] bbu on bbt.[BlueBinUserID] = bbu.[BlueBinUserID]
left join (select BlueBinResourceID,count(*) as Ct from [bluebin].[Training] where Active = 1 and Status = 'Trained' group by BlueBinResourceID) trained on bbt.[BlueBinResourceID] = trained.[BlueBinResourceID]
left join (select BlueBinResourceID,count(*) as Ct from [bluebin].[Training] where Active = 1 and Status <> 'Trained' group by BlueBinResourceID) nottrained on bbt.[BlueBinResourceID] = nottrained.[BlueBinResourceID]
WHERE 
bbt.Active = 1 and 
bbtm.ModuleName like '%' + @Module + '%' and 
(bbr.[LastName] like '%' + @Name + '%' 
	OR bbr.[FirstName] like '%' + @Name + '%') 
	
ORDER BY bbr.[LastName]
END

GO
grant exec on sp_SelectTraining to appusers
GO

--*****************************************************
--**************************SPROC**********************
if exists (select * from dbo.sysobjects where id = object_id(N'sp_InsertTraining') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_InsertTraining
GO

--exec sp_InsertTraining 1,'Yes','No','No','No','No','No','No','No','No','No','No','gbutler@bluebin.com'


CREATE PROCEDURE sp_InsertTraining
@BlueBinResource int,--varchar(255), 
@TrainingModuleID int,
@Status varchar(10),
@Updater varchar(255)

--WITH ENCRYPTION 
AS
BEGIN
SET NOCOUNT ON

if not exists (select * from bluebin.Training where Active = 1 and TrainingModuleID = @TrainingModuleID and BlueBinResourceID in (select BlueBinResourceID from bluebin.BlueBinResource where BlueBinResourceID  = @BlueBinResource))--
	BEGIN
	insert into bluebin.Training ([BlueBinResourceID],[TrainingModuleID],[Status],[BlueBinUserID],[Active],[LastUpdated])
	select 
		@BlueBinResource,
		@TrainingModuleID,
		@Status,
		(select BlueBinUserID from bluebin.BlueBinUser where LOWER(UserLogin) = LOWER(@Updater)),
		1, --Default Active to Yes
		getdate()


	
	;
	declare @TrainingID int
	SET @TrainingID = SCOPE_IDENTITY()
		exec sp_InsertMasterLog @Updater,'Training','New Training Record Entered',@TrainingID
	END
END
GO

grant exec on sp_InsertTraining to appusers
GO


--*****************************************************
--**************************SPROC**********************
if exists (select * from dbo.sysobjects where id = object_id(N'sp_DeleteTraining') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_DeleteTraining
GO

CREATE PROCEDURE sp_DeleteTraining
@TrainingID int

--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON
Update [bluebin].[Training] set [Active] = 0, [LastUpdated] = getdate() where TrainingID = @TrainingID

END
GO
grant exec on sp_DeleteTraining to appusers
GO

--*****************************************************
--**************************SPROC**********************
if exists (select * from dbo.sysobjects where id = object_id(N'sp_EditTraining') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_EditTraining
GO

--exec sp_EditTraining ''
--select * from [bluebin].[Training]


CREATE PROCEDURE sp_EditTraining
@TrainingID int, 
@Status varchar(10),
@Updater varchar(255)

--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON


update [bluebin].[Training]
set
Status=@Status,
BlueBinUserID = (select BlueBinUserID from bluebin.BlueBinUser where LOWER(UserLogin) = LOWER(@Updater)),
	LastUpdated = getdate()
where TrainingID = @TrainingID
	;
exec sp_InsertMasterLog @Updater,'Training','Training Record Updated',@TrainingID
END
GO

grant exec on sp_EditTraining to appusers
GO





--*****************************************************
--**************************SPROC**********************


if exists (select * from dbo.sysobjects where id = object_id(N'sp_DeleteScanLine') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_DeleteScanLine
GO

--exec sp_DeleteScanLine

CREATE PROCEDURE sp_DeleteScanLine
@ScanLineID int
--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON

Delete from scan.ScanLine where ScanLineID = @ScanLineID


END
GO
grant exec on sp_DeleteScanLine to public
GO


--*****************************************************
--**************************SPROC**********************


if exists (select * from dbo.sysobjects where id = object_id(N'sp_DeleteScanBatch') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_DeleteScanBatch
GO

--exec sp_DeleteScanBatch

CREATE PROCEDURE sp_DeleteScanBatch
@ScanBatchID int
--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON

Update scan.ScanBatch set Active = 0 where ScanBatchID = @ScanBatchID
Update scan.ScanLine set Active = 0 where ScanBatchID = @ScanBatchID


END
GO
grant exec on sp_DeleteScanBatch to public
GO


--*****************************************************
--**************************SPROC**********************




if exists (select * from dbo.sysobjects where id = object_id(N'sp_InsertScanLine') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_InsertScanLine
GO

/* 
exec sp_InsertScanLine 1,'0001217','20',1
exec sp_InsertScanLine 1,'0001218','5',2
exec sp_InsertScanLine 1,'0002205','100',3
*/

CREATE PROCEDURE sp_InsertScanLine
@ScanBatchID int,
@Item varchar(30),
@Qty int,
@Line int

--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON

if exists (select * from bluebin.DimItem where ItemID = @Item) 
BEGIN

declare @AutoExtractTrayScans int
select @AutoExtractTrayScans = ConfigValue from bluebin.Config where ConfigName = 'AutoExtractTrayScans'

insert into scan.ScanLine (ScanBatchID,Line,ItemID,Qty,Active,ScanDateTime,Extract)
	select 
	@ScanBatchID,
	@Line,
	@Item,
	@Qty,
	1,--Active Default to Yes
	getdate(),
	@AutoExtractTrayScans --Extract, based on Config value from ConfigName = 'AutoExtractTrayScans'
END
	ELSE
	BEGIN
	SELECT -1 -- Back out scan if there is an issue with the Item existing
	delete from scan.ScanLine where ScanBatchID = @ScanBatchID
	delete from scan.ScanBatch where ScanBatchID = @ScanBatchID
	END

END
GO
grant exec on sp_InsertScanLine to public
GO

--*****************************************************
--**************************SPROC**********************

if exists (select * from dbo.sysobjects where id = object_id(N'sp_SelectScanFacilities') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_SelectScanFacilities
GO

--exec sp_SelectScanFacilities 
CREATE PROCEDURE sp_SelectScanFacilities


--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON

SELECT DISTINCT 
convert(varchar(4),df.FacilityID) +' - '+ df.FacilityName as FacilityLongName,
sb.FacilityID
from scan.ScanBatch sb
inner join bluebin.DimFacility df on sb.FacilityID = df.FacilityID
WHERE Active = 1 --and convert(Date,ScanDateTime) = @ScanDate 
order by 1 desc

END 
GO
grant exec on sp_SelectScanFacilities to public
GO

--*****************************************************
--**************************SPROC**********************


if exists (select * from dbo.sysobjects where id = object_id(N'sp_InsertScanBatch') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_InsertScanBatch
GO

/*
declare @Location char(5),@Scanner varchar(255) = 'gbutler@bluebin.com'
select @Location = LocationID from bluebin.DimLocation where LocationName = 'DN NICU 1'
exec sp_InsertScanBatch 'BB013','gbutler@bluebin.com','Order'
exec sp_InsertScanBatch 'BB013','gbutler@bluebin.com','Receive'
*/

CREATE PROCEDURE sp_InsertScanBatch
@Location varchar(10),
@Scanner varchar(255),
@ScanType varchar(50)


--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON
declare @FacilityID int, @AutoExtractScans int
select @AutoExtractScans = ConfigValue from bluebin.Config where ConfigName = 'AutoExtractScans'
select @FacilityID = max(LocationFacility) from bluebin.DimLocation where rtrim(LocationID) = rtrim(@Location)--Only grab one FacilityID or else bad things will happen

insert into scan.ScanBatch (FacilityID,LocationID,BlueBinUserID,Active,ScanDateTime,Extract,ScanType)
select 
@FacilityID,
@Location,
(select BlueBinUserID from bluebin.BlueBinUser where LOWER(UserLogin) = LOWER(@Scanner)),
1, --Default Active to Yes
getdate(),
@AutoExtractScans, --Default Extract to value from ,
@ScanType

Declare @ScanBatchID int  = SCOPE_IDENTITY()

if @ScanType = 'ScanOrder'
BEGIN
exec sp_InsertMasterLog @Scanner,'Scan','New Scan Batch OrderEntered',@ScanBatchID
END ELSE
BEGIN
exec sp_InsertMasterLog @Scanner,'Scan','New Scan Batch Receipt Entered',@ScanBatchID
END

Select @ScanBatchID

END
GO
grant exec on sp_InsertScanBatch to public
GO




--*****************************************************
--**************************SPROC**********************



if exists (select * from dbo.sysobjects where id = object_id(N'sp_SelectScanBatch') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_SelectScanBatch
GO

--exec sp_SelectScanBatch '','',''

CREATE PROCEDURE sp_SelectScanBatch
@ScanDate varchar(20),
@Facility varchar(50),
@Location varchar(50)

--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON


select @ScanDate = case when @ScanDate = 'Today' then convert(varchar,(convert(Date,getdate())),111) else @ScanDate end

select 
sb.ScanBatchID,
rtrim(df.FacilityID) as FacilityID,
df.FacilityName as FacilityName,
rtrim(sb.LocationID) as LocationID,
dl.LocationName as LocationName,
max(sl.Line) as BinsScanned,
sb.ScanDateTime as [DateScanned],
--convert(Date,sb.ScanDateTime) as ScanDate,
bbu.LastName + ', ' + bbu.FirstName as ScannedBy,
case when sb.ScanType like '%Tray%' then 'Tray' else 'Scan' end as Origin,
case when max(sl.Line) - isnull(sm3.Ct,0) > 0 then  
		case when sm3.Ct > 1 then 'Partial' else 'No' end
	 else 'Yes' end as Extracted,
case when max(sl.Line) - isnull(sm2.Ct,0) > 0 then 
		case when sm2.Ct > 1 then 'Partial' else 'No' end 
	 else 'Yes' end as [Matched]

from scan.ScanBatch sb
inner join bluebin.DimLocation dl on sb.LocationID = dl.LocationID
inner join bluebin.DimFacility df on sb.FacilityID = df.FacilityID
inner join scan.ScanLine sl on sb.ScanBatchID = sl.ScanBatchID
left join bluebin.BlueBinUser bbu on sb.BlueBinUserID = bbu.BlueBinUserID
left join
	(select sl2.ScanBatchID,count(*) as Ct from scan.ScanMatch sm1 
		inner join scan.ScanLine sl2 on sm1.ScanLineOrderID = sl2.ScanLineID group by sl2.ScanBatchID) sm2 on sb.ScanBatchID = sm2.ScanBatchID
left join
	(select sl3.ScanBatchID,count(*) as Ct from scan.ScanExtract se1 
		inner join scan.ScanLine sl3 on se1.ScanLineID = sl3.ScanLineID group by sl3.ScanBatchID) sm3 on sb.ScanBatchID = sm3.ScanBatchID
where sb.Active = 1 and ScanType like '%Order' 
and convert(varchar,(convert(Date,sb.ScanDateTime)),111) LIKE '%' + @ScanDate + '%'  
--and convert(varchar(4),df.FacilityID) +' - '+ df.FacilityName like '%' + @Facility + '%' 
and sb.FacilityID like '%' + @Facility + '%' 
and sb.LocationID like '%' + @Location + '%'

group by 
sb.ScanBatchID,
df.FacilityID,
df.FacilityName,
sb.LocationID,
dl.LocationName,
sb.ScanDateTime,
bbu.LastName + ', ' + bbu.FirstName,
case when sb.ScanType like '%Tray%' then 'Tray' else 'Scan' end,
sm2.Ct,
sm3.Ct
order by sb.ScanDateTime desc

END
GO
grant exec on sp_SelectScanBatch to public
GO





--*****************************************************
--**************************SPROC**********************


if exists (select * from dbo.sysobjects where id = object_id(N'sp_SelectScanLines') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_SelectScanLines
GO

--exec sp_SelectScanLines 38  select * from scan.ScanBatch

CREATE PROCEDURE sp_SelectScanLines
@ScanBatchID int

--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON
select 
sb.ScanBatchID,
db.BinKey,
db.BinSequence,
rtrim(sb.LocationID) as LocationID,
dl.LocationName as LocationName,
sl.ItemID,
di.ItemDescription,
sl.Bin,
sl.Qty,
sl.Line,
sb.ScanDateTime as [DateScanned],
bbu.LastName + ', ' + bbu.FirstName as ScannedBy,
case when sb.ScanType like '%Tray%' then 'Tray' else 'Scan' end as Origin,
sl.Extract,
case when se.ScanLineID is not null then 'Yes' else 'No' end as Extracted

from scan.ScanLine sl
inner join scan.ScanBatch sb on sl.ScanBatchID = sb.ScanBatchID
inner join bluebin.DimBin db on sb.LocationID = db.LocationID and sl.ItemID = db.ItemID
inner join bluebin.DimItem di on sl.ItemID = di.ItemID
inner join bluebin.DimLocation dl on sb.LocationID = dl.LocationID
left join bluebin.BlueBinUser bbu on sb.BlueBinUserID = bbu.BlueBinUserID
left join (select distinct ScanLineID from scan.ScanExtract) se on sl.ScanLineID = se.ScanLineID
where sl.ScanBatchID = @ScanBatchID and sl.Active = 1 and sb.ScanType like '%Order'
order by sl.Line


END
GO
grant exec on sp_SelectScanLines to public
GO



--*****************************************************
--**************************SPROC**********************


if exists (select * from dbo.sysobjects where id = object_id(N'sp_SelectHardwareCustomer') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_SelectHardwareCustomer
GO


CREATE PROCEDURE sp_SelectHardwareCustomer

--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON
	select ConfigValue from bluebin.Config where ConfigName = 'BlueBinHardwareCustomer'

END

GO
grant exec on sp_SelectHardwareCustomer to appusers
GO


--*****************************************************
--**************************SPROC**********************

if exists (select * from dbo.sysobjects where id = object_id(N'sp_SelectQCN') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_SelectQCN
GO

--select * from qcn.QCN
--exec sp_SelectQCN '%','%','%','0','%'
CREATE PROCEDURE sp_SelectQCN
@FacilityName varchar(50)
,@LocationName varchar(50)
,@QCNStatusName varchar(255)
,@Completed int
,@AssignedUserName varchar(50)

--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON
declare @QCNStatus int = 0
declare @QCNStatus2 int = 0
if @Completed = 0
begin
select @QCNStatus = QCNStatusID from qcn.QCNStatus where Status = 'Completed'
select @QCNStatus2 = QCNStatusID from qcn.QCNStatus where Status = 'Rejected'
end

select 
	q.[QCNID],
	q.FacilityID,
	df.FacilityName,
	q.[LocationID],
    case
		when q.[LocationID] = 'Multiple' then q.LocationID
		else case	when dl.LocationID = dl.LocationName then dl.LocationID
					else dl.LocationID + ' - ' + dl.[LocationName] end end as LocationName,
	RequesterUserID  as RequesterUserName,
	ApprovedBy as ApprovedBy,
    case when v.UserLogin is null then '' else v.LastName + ', ' + v.FirstName end as AssignedUserName,
        ISNULL(v.[UserLogin],'') as AssignedLogin,
    ISNULL(v.[Title],'') as AssignedTitleName,
	qt.Name as QCNType,
q.[ItemID],
COALESCE(di.ItemClinicalDescription,di.ItemDescription,'No Description') as ItemClinicalDescription,
q.Par,
q.UOM,
q.ManuNumName,
	q.[Details] as [DetailsText],
            case when q.[Details] ='' then 'No' else 'Yes' end Details,
	q.[Updates] as [UpdatesText],
            case when q.[Updates] ='' then 'No' else 'Yes' end Updates,
	case when qs.Status in ('Rejected','Completed') then convert(int,(q.[DateCompleted] - q.[DateEntered]))
		else convert(int,(getdate() - q.[DateEntered])) end as DaysOpen,
            q.[DateEntered],
	q.[DateCompleted],
	qs.Status,
    q.[LastUpdated],
	q.InternalReference,
	qc.Name as Complexity
from [qcn].[QCN] q
--left join [bluebin].[DimBin] db on q.LocationID = db.LocationID and rtrim(q.ItemID) = rtrim(db.ItemID)
left join [bluebin].[DimItem] di on rtrim(q.ItemID) = rtrim(di.ItemID)
        left join [bluebin].[DimLocation] dl on q.LocationID = dl.LocationID and dl.BlueBinFlag = 1
		left join [bluebin].[DimFacility] df on q.FacilityID = df.FacilityID
left join [bluebin].[BlueBinUser] v on q.AssignedUserID = v.BlueBinUserID
inner join [qcn].[QCNType] qt on q.QCNTypeID = qt.QCNTypeID
inner join [qcn].[QCNStatus] qs on q.QCNStatusID = qs.QCNStatusID
left join qcn.QCNComplexity qc on q.QCNCID = qc.QCNCID

WHERE q.Active = 1 
and df.FacilityName like '%' + @FacilityName + '%'
and (dl.LocationID + ' - ' + dl.[LocationName] LIKE '%' + @LocationName + '%' or q.LocationID like '%' + @LocationName + '%')
and qs.Status LIKE '%' + @QCNStatusName + '%'
and q.QCNStatusID not in (@QCNStatus,@QCNStatus2)
and case	
		when @AssignedUserName <> '%' then v.LastName + ', ' + v.FirstName else '' end LIKE  '%' + @AssignedUserName + '%' 
            order by q.[DateEntered] asc--,convert(int,(getdate() - q.[DateEntered])) desc

END
GO
grant exec on sp_SelectQCN to appusers
GO





--*****************************************************
--**************************SPROC**********************
if exists (select * from dbo.sysobjects where id = object_id(N'sp_DeleteConfig') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_DeleteConfig
GO

--exec sp_EditConfig 'TEST'

CREATE PROCEDURE sp_DeleteConfig
@original_ConfigID int,
@original_ConfigName varchar(30),
@original_ConfigValue varchar(30)


--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON
	DELETE FROM bluebin.[Config] 
	WHERE [ConfigID] = @original_ConfigID 
		AND [ConfigName] = @original_ConfigName 
			AND [ConfigValue] = @original_ConfigValue 
				

END
GO
grant exec on sp_DeleteConfig to appusers
GO


--*****************************************************
--**************************SPROC**********************
if exists (select * from dbo.sysobjects where id = object_id(N'sp_DeleteGembaAuditNode') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_DeleteGembaAuditNode
GO

CREATE PROCEDURE sp_DeleteGembaAuditNode
@GembaAuditNodeID int

--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON
Update [gemba].[GembaAuditNode] set Active = 0, LastUpdated = getdate() where GembaAuditNodeID = @GembaAuditNodeID  

END
GO
grant exec on sp_DeleteGembaAuditNode to appusers
GO

--*****************************************************
--**************************SPROC**********************
if exists (select * from dbo.sysobjects where id = object_id(N'sp_DeleteGembaAuditStage') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_DeleteGembaAuditStage
GO

CREATE PROCEDURE sp_DeleteGembaAuditStage
@GembaAuditStageID int

--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON
Update [gemba].[GembaAuditStage] set Active = 0, LastUpdated = getdate() where GembaAuditStageID = @GembaAuditStageID  

END
GO
grant exec on sp_DeleteGembaAuditStage to appusers
GO


--*****************************************************
--**************************SPROC**********************
if exists (select * from dbo.sysobjects where id = object_id(N'sp_DeleteQCN') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_DeleteQCN
GO

CREATE PROCEDURE sp_DeleteQCN
@QCNID int

--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON
Update [qcn].[QCN] set [Active] = 0, [LastUpdated] = getdate() where QCNID = @QCNID

END
GO
grant exec on sp_DeleteQCN to appusers
GO


--*****************************************************
--**************************SPROC**********************
if exists (Select * from dbo.sysobjects where id = object_id(N'sp_DeleteQCNStatus') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_DeleteQCNStatus
GO

--exec sp_DeleteQCNStatus 

CREATE PROCEDURE sp_DeleteQCNStatus
@original_QCNStatusID int,
@original_Status varchar(255)

--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON
	Update qcn.[QCNStatus] Set Active = 0 WHERE [QCNStatusID] = @original_QCNStatusID AND [Status] = @original_Status

END
GO
grant exec on sp_DeleteQCNStatus to appusers
GO

--*****************************************************
--**************************SPROC**********************
if exists (select * from dbo.sysobjects where id = object_id(N'sp_DeleteQCNType') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_DeleteQCNType
GO

--exec sp_DeleteQCNType 

CREATE PROCEDURE sp_DeleteQCNType
@original_QCNTypeID int,
@original_Name varchar(255)

--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON
	
	Update qcn.[QCNType] set Active = 0
	WHERE 
	[QCNTypeID] = @original_QCNTypeID 
		AND [Name] = @original_Name
END
GO
grant exec on sp_DeleteQCNType to appusers
GO


--*****************************************************
--**************************SPROC**********************
if exists (select * from dbo.sysobjects where id = object_id(N'sp_EditBlueBinResource') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_EditBlueBinResource
GO

--exec sp_EditBlueBinResource 'TEST'

CREATE PROCEDURE sp_EditBlueBinResource
@BlueBinResourceID int
,@FirstName varchar (30)
,@LastName varchar (30)
,@MiddleName varchar (30)
,@Login varchar (60)
,@Email varchar (60)
,@Phone varchar (20)
,@Cell varchar (20)
,@Title varchar (50)
,@Active int



--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON
Update bluebin.BlueBinResource set 
FirstName = @FirstName
,LastName = @LastName
,MiddleName = @MiddleName
,[Login] = @Login
,Email = @Email
,Phone = @Phone
,Cell = @Cell
,Title = @Title
,Active = @Active, LastUpdated = getdate() 
where BlueBinResourceID = @BlueBinResourceID	

END
GO
grant exec on sp_EditBlueBinResource to appusers
GO

--*****************************************************
--**************************SPROC**********************
if exists (select * from dbo.sysobjects where id = object_id(N'sp_EditConfig') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_EditConfig
GO

--exec sp_EditConfig 10,'3','Tableau',1


CREATE PROCEDURE sp_EditConfig
@ConfigID int
,@ConfigValue varchar (100)
,@ConfigType varchar(50)
,@Active int


--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON
	Update bluebin.Config set ConfigValue = @ConfigValue,ConfigType = @ConfigType,Active = @Active, LastUpdated = getdate() where ConfigID = @ConfigID

END
GO
grant exec on sp_EditConfig to appusers
GO



--*****************************************************
--**************************SPROC**********************
if exists (select * from dbo.sysobjects where id = object_id(N'sp_EditGembaAuditStage') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_EditGembaAuditStage
GO

--exec sp_EditGembaAuditStage 'TEST'

CREATE PROCEDURE sp_EditGembaAuditStage
	@GembaAuditStageID int,
	@KanbansFilled int,
	@KanbansFilledText varchar(max),
	@LeftBehind int,
	@FollowUpDistrib int,
	@FollowUpDistribText varchar(max),
	@Concerns varchar(max),
	@DirectOrderBins int,
	@OldestBin datetime,
	@CheckedOpenOrders int,
	@CheckedOpenOrdersText varchar(max),
	@HowManyLate int,
	@FollowUpBuyers int,
	@FollowUpBuyersText varchar(max),
	@UpdatedStatusTag int,
	@UpdatedStatusTagText varchar(max),
	@ReqsSubmitted int,
	@ReqsSubmittedText varchar(max),
	@BinsInOrder int,
	@BinsInOrderText varchar(max),
	@AreaNeatTidy int,
	@AreaNeatTidyText varchar(max),
	@CartsClean int,
	@CartsCleanText varchar(max),
	@AdditionalCommentsText varchar(max)


--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON
Update [gemba].[GembaAuditStage] Set

	[KanbansFilled] = @KanbansFilled,
	[KanbansFilledText] = @KanbansFilledText,
	[LeftBehind] = @LeftBehind,
	[FollowUpDistrib] = @FollowUpDistrib,
	[FollowUpDistribText] = @FollowUpDistribText,
	[Concerns] = @Concerns,
	[DirectOrderBins] = @DirectOrderBins,
	[OldestBin] = @OldestBin,
	[CheckOpenOrders] = @CheckedOpenOrders,
	[CheckOpenOrdersText] = @CheckedOpenOrdersText,
	[HowManyLate] = @HowManyLate,
	[FollowUpBuyers] = @FollowUpBuyers,
	[FollowUpBuyersText] = @FollowUpBuyersText,
	[UpdatedStatusTag] = @UpdatedStatusTag,
	[UpdatedStatusTagText] = @UpdatedStatusTagText,
	[ReqsSubmitted] = @ReqsSubmitted,
	[ReqsSubmittedText] = @ReqsSubmittedText,
	[BinsInOrder] = @BinsInOrder,
	[BinsInOrderText] = @BinsInOrderText,
	[AreaNeatTidy] = @AreaNeatTidy,
	[AreaNeatTidyText] = @AreaNeatTidyText,
	[CartsClean] = @CartsClean,
	[CartsCleanText] = @CartsCleanText,
	[AdditionalComments] = @AdditionalCommentsText,
    [LastUpdated] = getdate()
	Where [GembaAuditStageID] = @GembaAuditStageID	

END
GO
grant exec on sp_EditGembaAuditStage to appusers
GO


--*****************************************************
--**************************SPROC**********************
if exists (select * from dbo.sysobjects where id = object_id(N'sp_EditQCN') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_EditQCN
GO

--exec sp_EditQCN 

CREATE PROCEDURE sp_EditQCN
@QCNID int,
@FacilityID int,
@LocationID varchar(10),
@ItemID varchar(32),
@ClinicalDescription varchar(30),
@Sequence varchar(30),
@Requester varchar(255),
@ApprovedBy varchar(255),
@Assigned int,
@QCNComplexity varchar(255),
@QCNType varchar(255),
@Details varchar(max),
@Updates varchar(max),
@QCNStatus varchar(255),
@InternalReference varchar(50),
@ManuNumName varchar(60),
@Par int,
@UOM varchar(10)


--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON
	
update [qcn].[QCN] set
FacilityID = @FacilityID,
[LocationID] = @LocationID,
[ItemID] = @ItemID,
ClinicalDescription = @ClinicalDescription,
[Sequence] = @Sequence,
[RequesterUserID] = @Requester,
ApprovedBy = @ApprovedBy,
[AssignedUserID] = case when @Assigned not in (select BlueBinUserID from bluebin.BlueBinUser) then NULL else @Assigned end,
[QCNCID] =  @QCNComplexity,
[QCNTypeID] = (select max([QCNTypeID]) from [qcn].[QCNType] where [Name] = @QCNType),
[Details] = @Details,
[Updates] = @Updates,
[DateCompleted] = Case when @QCNStatus in ('Rejected','Completed') and DateCompleted is null then getdate() 
                        when @QCNStatus in ('Rejected','Completed') and DateCompleted is not null then DateCompleted
                            else NULL end,
[QCNStatusID] = (select max([QCNStatusID]) from [qcn].[QCNStatus] where [Status] = @QCNStatus),
[LastUpdated] = getdate(),
InternalReference = @InternalReference,
ManuNumName = @ManuNumName,
Par = @Par,
UOM = @UOM
WHERE QCNID = @QCNID



END

GO
grant exec on sp_EditQCN to appusers
GO



--*****************************************************
--**************************SPROC**********************
if exists (select * from dbo.sysobjects where id = object_id(N'sp_EditQCNStatus') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_EditQCNStatus
GO

--exec sp_EditQCNStatus 'TEST'

CREATE PROCEDURE sp_EditQCNStatus
@QCNStatusID int
,@Status varchar (255)
,@Active int
,@Description varchar(100)


--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON
	Update qcn.QCNStatus set [Status] = @Status,[Active] = @Active, [LastUpdated ]= getdate(),Description = @Description where QCNStatusID = @QCNStatusID

END

GO
grant exec on sp_EditQCNStatus to appusers
GO


--*****************************************************
--**************************SPROC**********************
if exists (select * from dbo.sysobjects where id = object_id(N'sp_EditQCNType') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_EditQCNType
GO

--exec sp_EditQCNType 'TEST'

CREATE PROCEDURE sp_EditQCNType
@QCNTypeID int
,@Name varchar (255)
,@Active int
,@Description varchar(100)


--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON
	Update qcn.QCNType set Name = @Name,Active = @Active, LastUpdated = getdate(),Description = @Description where QCNTypeID = @QCNTypeID

END

GO
grant exec on sp_EditQCNType to appusers
GO

--*****************************************************
--**************************SPROC**********************

if exists (select * from dbo.sysobjects where id = object_id(N'sp_InsertBlueBinResource') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_InsertBlueBinResource
GO

--exec sp_InsertBlueBinResource 'TEST'

CREATE PROCEDURE sp_InsertBlueBinResource
@LastName varchar (30)
,@FirstName varchar (30)
,@MiddleName varchar (30)
,@Login varchar (60)
,@Email varchar (60)
,@Phone varchar (20)
,@Cell varchar (20)
,@Title varchar (50)


--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON
if exists(select * from bluebin.BlueBinResource where FirstName = @FirstName and LastName = @LastName and [Login] = @Login)
	BEGIN
		if not exists (select * from bluebin.BlueBinTraining where BlueBinResourceID in (select BlueBinResourceID from bluebin.BlueBinResource where FirstName = @FirstName and LastName = @LastName and [Login] = @Login))
		BEGIN
		insert into bluebin.Training ([BlueBinResourceID],[TrainingModuleID],[Status],[BlueBinUserID],[Active],[LastUpdated])
			select 
			u.BlueBinResourceID,
			t.TrainingModuleID,
			'No',
			(select BlueBinUserID from bluebin.BlueBinUser where UserLogin = 'gbutler@bluebin.com'),
			1,
			getdate()
			from bluebin.TrainingModule t, bluebin.BlueBinResource u
			where t.Required = 1 and  u.FirstName = @FirstName and u.LastName = @LastName and u.[Login] = @Login
			and Title in (select ConfigValue from bluebin.Config where ConfigName = 'TrainingTitle')
		END
		GOTO THEEND
	END
;
insert into bluebin.BlueBinResource (FirstName,LastName,MiddleName,[Login],Email,Phone,Cell,Title,Active,LastUpdated) 
VALUES (@FirstName,@LastName,@MiddleName,@Login,@Email,@Phone,@Cell,@Title,1,getdate())
;
	insert into bluebin.Training ([BlueBinResourceID],[TrainingModuleID],[Status],[BlueBinUserID],[Active],[LastUpdated])
	select 
	u.BlueBinResourceID,
	t.TrainingModuleID,
	'No',
	(select BlueBinUserID from bluebin.BlueBinUser where UserLogin = 'gbutler@bluebin.com'),
	1,
	getdate()
	from bluebin.TrainingModule t, bluebin.BlueBinResource u
	where t.Required = 1 and  u.FirstName = @FirstName and u.LastName = @LastName and u.[Login] = @Login
	and Title in (select ConfigValue from bluebin.Config where ConfigName = 'TrainingTitle')

END
THEEND:

GO
grant exec on sp_InsertBlueBinResource to appusers
GO


--*****************************************************
--**************************SPROC**********************
if exists (select * from dbo.sysobjects where id = object_id(N'sp_InsertConfig') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_InsertConfig
GO

--exec sp_InsertConfig 'TEST'

CREATE PROCEDURE sp_InsertConfig
@ConfigName varchar (30)
,@ConfigValue varchar (100)
,@ConfigType varchar (50)


--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON
if exists(select * from bluebin.Config where ConfigName = @ConfigName and ConfigType = 'DMS')
BEGIN
GOTO THEEND
END
insert into bluebin.Config (ConfigName,ConfigValue,ConfigType,Active,LastUpdated) VALUES (@ConfigName,@ConfigValue,@ConfigType,1,getdate())

END
THEEND:

GO
grant exec on sp_InsertConfig to appusers
GO
--*****************************************************
--**************************SPROC**********************
if exists (select * from dbo.sysobjects where id = object_id(N'sp_InsertMasterLog') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_InsertMasterLog
GO

CREATE PROCEDURE sp_InsertMasterLog
@UserLogin varchar (60)
,@ActionType varchar (30)
,@ActionName varchar (50)
,@ActionID int
--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON


Insert into bluebin.MasterLog ([BlueBinUserID],[ActionType],[ActionName],[ActionID],[ActionDateTime]) Values
((select BlueBinUserID from bluebin.BlueBinUser where LOWER(UserLogin) = LOWER(@UserLogin)),@ActionType,@ActionName,@ActionID,getdate())

END
GO
grant exec on sp_InsertMasterLog to appusers
GO


--*****************************************************
--**************************SPROC**********************
if exists (select * from dbo.sysobjects where id = object_id(N'sp_InsertQCNStatus') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_InsertQCNStatus
GO

--exec sp_InsertQCNStatus 'TEST'

CREATE PROCEDURE sp_InsertQCNStatus
@Status varchar (255),
@Description varchar(100)


--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON
if exists(select * from qcn.QCNStatus where Status = @Status)
BEGIN
GOTO THEEND
END
insert into qcn.QCNStatus (Status,Active,LastUpdated,Description) VALUES (@Status,1,getdate(),@Description)

END
THEEND:

GO
grant exec on sp_InsertQCNStatus to appusers
GO


--*****************************************************
--**************************SPROC**********************
if exists (select * from dbo.sysobjects where id = object_id(N'sp_InsertQCNType') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_InsertQCNType
GO

--exec sp_InsertQCNType 'TEST'

CREATE PROCEDURE sp_InsertQCNType
@Name varchar (255),
@Description varchar(100)



--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON
if exists(select * from qcn.QCNType where Name = @Name)
BEGIN
GOTO THEEND
END
insert into qcn.QCNType (Name,Active,LastUpdated,Description) VALUES (@Name,1,getdate(),@Description)

END
THEEND:

GO
grant exec on sp_InsertQCNType to appusers
GO


--*****************************************************
--**************************SPROC**********************
if exists (select * from dbo.sysobjects where id = object_id(N'sp_SelectBlueBinResource') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_SelectBlueBinResource
GO


CREATE PROCEDURE sp_SelectBlueBinResource
@Name varchar (30)

--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON
SELECT 
[BlueBinResourceID], 
[Login], 
[FirstName], 
[LastName], 
[MiddleName], 
[Email], 
[Title],
[Phone],
[Cell],
case when Active = 1 then 'Yes' Else 'No' end as ActiveName,
Active,
LastUpdated

FROM [bluebin].[BlueBinResource] 

WHERE [LastName] like '%' + @Name + '%' 
	OR [FirstName] like '%' + @Name + '%' 
	
ORDER BY [LastName]
END

GO
grant exec on sp_SelectBlueBinResource to appusers
GO


--*****************************************************
--**************************SPROC**********************
if exists (select * from dbo.sysobjects where id = object_id(N'sp_SelectConfig') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_SelectConfig
GO

--exec sp_SelectConfig 'Tableau'

CREATE PROCEDURE sp_SelectConfig
@ConfigType varchar(50)

--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON
	SELECT 
	ConfigID,
	ConfigType,
	ConfigName,
	ConfigValue,
	case 
		when Active = 1 then 'Yes' 
		Else 'No' 
		end as ActiveName,
	Active,
	LastUpdated,
	[Description]
	
	FROM bluebin.[Config]
	where ConfigType like  '%' + @ConfigType + '%'
	order by ConfigType,ConfigName

END
GO
grant exec on sp_SelectConfig to appusers
GO



--*****************************************************
--**************************SPROC**********************
if exists (select * from dbo.sysobjects where id = object_id(N'sp_SelectGembaAuditNode') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_SelectGembaAuditNode
GO

CREATE PROCEDURE sp_SelectGembaAuditNode
@LocationName varchar(50),
@Auditer varchar(50)

--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON
    select 
	q.Date,
    q.[GembaAuditNodeID],
	dl.LocationID + ' - ' + dl.[LocationName] as LocationName,
	u.LastName + ', ' + u.FirstName as Auditer,
    u.UserLogin as AuditerLogin,
    q.PS_TotalScore as [Pull Score],
    q.RS_TotalScore as [Replenishment Score],
    q.NIS_TotalScore as [Node Integrity Score],
	q.SS_TotalScore as [Stage Score],
    q.TotalScore as [Total Score],
    q.AdditionalComments as AdditionalCommentsText,
    case when q.AdditionalComments ='' then 'No' else 'Yes' end [Addtl Comments],
    q.LastUpdated
from [gemba].[GembaAuditNode] q
inner join [bluebin].[DimLocation] dl on q.LocationID = dl.LocationID and dl.BlueBinFlag = 1
inner join [bluebin].[BlueBinUser] u on q.AuditerUserID = u.BlueBinUserID
    Where q.Active = 1 
	and dl.LocationID + ' - ' + dl.[LocationName] LIKE '%' + @LocationName + '%' 
	and u.LastName + ', ' + u.FirstName LIKE '%' + @Auditer + '%'
	order by q.Date desc

END
GO
grant exec on sp_SelectGembaAuditNode to appusers
GO



--*****************************************************
--**************************SPROC**********************
if exists (select * from dbo.sysobjects where id = object_id(N'sp_SelectGembaAuditNodeEdit') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_SelectGembaAuditNodeEdit
GO

--exec sp_SelectGembaAuditNodeEdit 'TEST'

CREATE PROCEDURE sp_SelectGembaAuditNodeEdit
@GembaAuditNodeID int

--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON
select
		a.[GembaAuditNodeID]
		,convert(varchar,a.[Date],101) as [Date]
		,rtrim([LocationID]) as LocationID
		,LOWER(b1.UserLogin) as Auditer
		,a.[AdditionalComments]
		,a.[PS_EmptyBins]
		,a.[PS_BackBins]
		,a.[PS_StockOuts]
		,a.[PS_ReturnVolume]
		,a.[PS_NonBBT]
		,a.[PS_OrangeCones]
		,a.[PS_Comments]
		,a.[RS_BinsFilled]
		,a.[RS_EmptiesCollected]
		,a.[RS_BinServices]
		,a.[RS_NodeSwept]
		,a.[RS_NodeCorrections]
		,b2.LastName + ', ' + b2.FirstName + ' (' + b2.Login + ')' as RS_ShadowedUser
		,a.[RS_Comments]

		,a.[SS_Supplied]
		,a.[SS_KanbansPP]
		,a.[SS_StockoutsPT]
		,a.[SS_StockoutsMatch]
		,a.[SS_HuddleBoardMatch]
		,a.[SS_Comments]

		,a.[NIS_Labels]
		,a.[NIS_CardHolders]
		,a.[NIS_BinsRacks]
		,a.[NIS_GeneralAppearance]
		,a.[NIS_Signage]
		,a.[NIS_Comments]
		,a.[PS_TotalScore]
		,a.[RS_TotalScore]
		,a.[SS_TotalScore]
		,a.[NIS_TotalScore]
		,a.[TotalScore]
		,convert(varchar,a.[LastUpdated],101) as [LastUpdated]
		from gemba.GembaAuditNode a 
				inner join bluebin.BlueBinUser b1 on a.[AuditerUserID] = b1.BlueBinUserID
				left join bluebin.BlueBinResource b2 on a.[RS_ShadowedUserID] = b2.BlueBinResourceID where a.GembaAuditNodeID = @GembaAuditNodeID
END
GO
grant exec on sp_SelectGembaAuditNodeEdit to appusers
GO


--*****************************************************
--**************************SPROC**********************
if exists (select * from dbo.sysobjects where id = object_id(N'sp_SelectGembaAuditStage') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_SelectGembaAuditStage
GO


--exec sp_SelectGembaAuditStage
CREATE PROCEDURE sp_SelectGembaAuditStage

--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON
SELECT 
      a.[GembaAuditStageID]
      ,a.[Date]
      ,b.LastName + ', ' + b.FirstName as Auditer
      ,LOWER(b.UserLogin) as AuditerLogin
      ,a.[OldestBin]
      ,case when a.[KanbansFilled] = 1 then 'Yes' else 'No' end [KanbansFilled]
      ,case when a.[ReqsSubmitted] = 3 then 'Need' when a.[ReqsSubmitted] = 0 then 'No' else 'Yes' end [ReqsSubmitted]
      ,case when a.[BinsInOrder] = 3 then 'Need' when a.[BinsInOrder] = 0 then 'No'  else 'Yes' end [BinsInOrder]
      ,case when a.[AreaNeatTidy] = 3 then 'Need' when a.[AreaNeatTidy] = 0 then 'No'  else 'Yes' end [AreaNeatTidy]
      ,case when a.[CartsClean] = 3 then 'Need' when a.[CartsClean] = 0 then 'No'  else 'Yes' end [CartsClean]
      ,a.[AdditionalComments] as AdditionalCommentsStageText 
      ,case when a.[AdditionalComments] = '' then 'None' else 'Yes' end [AdditionalCommentsStage]
	  ,a.Concerns as ConcernsText
     ,case when a.[Concerns] = '' then 'None' else 'Yes' end [Concerns],
      a.LastUpdated
  FROM [gemba].[GembaAuditStage] a
  inner join bluebin.BlueBinUser b on a.AuditerUserID = b.BlueBinUserID WHERE a.Active = 1 order by a.[Date] desc

END
GO
grant exec on sp_SelectGembaAuditStage to appusers
GO


--*****************************************************
--**************************SPROC**********************
if exists (select * from dbo.sysobjects where id = object_id(N'sp_SelectGembaAuditStageEdit') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_SelectGembaAuditStageEdit
GO

--exec sp_SelectGembaAuditStageEdit 'TEST'

CREATE PROCEDURE sp_SelectGembaAuditStageEdit
@GembaAuditStageID int

--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON

select 
    a.GembaAuditStageID
    , convert(varchar,a.[Date],101) as [Date]
    ,LOWER(b.UserLogin) as Auditer
    ,a.[KanbansFilled]
    ,a.[KanbansFilledText]
    ,a.[LeftBehind]
    ,a.[FollowUpDistrib]
    ,a.[FollowUpDistribText]
    ,a.[Concerns]
    ,a.[DirectOrderBins]
    ,convert(varchar,a.[OldestBin],101) as OldestBin
    ,a.[CheckOpenOrders]
    ,a.[CheckOpenOrdersText]
    ,a.[HowManyLate]
    ,a.[FollowUpBuyers]
    ,a.[FollowUpBuyersText]
    ,a.[UpdatedStatusTag]
    ,a.[UpdatedStatusTagText]
    ,a.[ReqsSubmitted]
    ,a.[ReqsSubmittedText]
    ,a.[BinsInOrder]
    ,a.[BinsInOrderText]
    ,a.[AreaNeatTidy]
    ,a.[AreaNeatTidyText]
    ,a.[CartsClean]
    ,a.[CartsCleanText]
    ,a.[AdditionalComments]
    , convert(varchar,a.[LastUpdated],101) as [LastUpdated]
from gemba.GembaAuditStage a 
	inner join bluebin.BlueBinUser b on a.[AuditerUserID] = b.BlueBinUserID
where 
	a.GembaAuditStageID=@GembaAuditStageID
END
GO
grant exec on sp_SelectGembaAuditStageEdit to appusers
GO


--*****************************************************
--**************************SPROC**********************
if exists (select * from dbo.sysobjects where id = object_id(N'sp_SelectGembaShadow') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_SelectGembaShadow
GO

--sp_SelectGembaShadow

CREATE PROCEDURE sp_SelectGembaShadow

--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON
	SELECT 
		BlueBinResourceID,
		LastName + ', ' + FirstName + ' (' + Login + ')' as FullName 
	
	FROM [bluebin].[BlueBinResource] 
	
	WHERE 
		Title in (Select ConfigValue from bluebin.Config where ConfigName = 'GembaShadowTitle')
		order by 1
END
GO
grant exec on sp_SelectGembaShadow to appusers
GO



--*****************************************************
--**************************SPROC**********************
if exists (select * from dbo.sysobjects where id = object_id(N'sp_SelectLocation') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_SelectLocation
GO

--exec sp_SelectLocation 

CREATE PROCEDURE sp_SelectLocation

--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON

SELECT 
LocationFacility as FacilityID,
LocationID,
--LocationName,
case when LocationID = LocationName then LocationID else LocationID + ' - ' + [LocationName] end as LocationName 
FROM [bluebin].[DimLocation] where BlueBinFlag = 1

order by LocationID
END
GO
grant exec on sp_SelectLocation to appusers
GO

--*****************************************************
--**************************SPROC**********************

if exists (select * from dbo.sysobjects where id = object_id(N'sp_SelectLocationCascade') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_SelectLocationCascade
GO

--exec sp_SelectLocationCascade 'Yes'

CREATE PROCEDURE sp_SelectLocationCascade
@Multiple varchar(3)

--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON
declare @MultipleID varchar(10), @MultipleName varchar(10)
select @MultipleID = case when @Multiple = 'Yes' then 'Multiple' else '' end
select @MultipleName = case when @Multiple = 'Yes' then 'Multiple' else '--Select--' end


Select distinct 
FacilityID,
LocationID,
LocationName
from (
SELECT 
LocationFacility as FacilityID,
LocationID,
--LocationName,
case when LocationID = LocationName then LocationID else LocationID + ' - ' + [LocationName] end as LocationName 

FROM [bluebin].[DimLocation] where BlueBinFlag = 1
UNION ALL 
select distinct LocationFacility as FacilityID,'','--Select--' FROM [bluebin].[DimLocation] where BlueBinFlag = 1
UNION ALL 
select distinct LocationFacility as FacilityID,@MultipleID,@MultipleName FROM [bluebin].[DimLocation] where BlueBinFlag = 1) as a
order by LocationID
END
GO
grant exec on sp_SelectLocationCascade to appusers
GO

--*****************************************************
--**************************SPROC**********************
if exists (select * from dbo.sysobjects where id = object_id(N'sp_SelectLogoImage') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_SelectLogoImage
GO


CREATE PROCEDURE sp_SelectLogoImage

--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON
	select ConfigValue from bluebin.Config where ConfigName = 'CustomerImage'

END

GO
grant exec on sp_SelectLogoImage to appusers
GO

--*****************************************************
--**************************SPROC**********************
if exists (select * from dbo.sysobjects where id = object_id(N'sp_SelectQCNFormEdit') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_SelectQCNFormEdit
GO

--exec sp_SelectQCNFormEdit '270'

CREATE PROCEDURE sp_SelectQCNFormEdit
@QCNID int

--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON
SELECT 
	[QCNID]
	,rtrim([LocationID]) as LocationID
	,a.FacilityID
	,rtrim(a.ItemID) as ItemID
	,a.ClinicalDescription
	,a.[Sequence]
	,RequesterUserID as RequesterUser
	,ApprovedBy
	,a.[AssignedUserID] as AssignedUser
	,a.QCNCID as QCNComplexity
	,qt.Name as QCNType
	,[Details]
	,[Updates]
	,convert(varchar,a.[DateRequested],101) as [DateRequested]
	,convert(varchar,a.[DateEntered],101) as [DateEntered]
	,convert(varchar,a.[DateCompleted],101) as [DateCompleted]
	,qs.Status as QCNStatus
	,convert(varchar,a.[LastUpdated],101) as [LastUpdated]
	,InternalReference
	,ManuNumName
	,bbu.LastName + ', ' + bbu.FirstName + ' (' + bbu.UserLogin + ')' as [LoggedByUser]
	,Par
	,UOM
		FROM [qcn].[QCN] a 
		inner join bluebin.BlueBinUser bbu on a.LoggedUserID = bbu.BlueBinUserID
			left join bluebin.BlueBinUser b2 on a.[AssignedUserID] = b2.BlueBinUserID
			left join qcn.QCNStatus qs on a.[QCNStatusID] = qs.[QCNStatusID]
			left join qcn.QCNType qt on a.[QCNTypeID] = qt.[QCNTypeID]
			left join qcn.QCNComplexity qc on a.[QCNCID] = qc.[QCNCID]
		where a.QCNID=@QCNID

END
GO
grant exec on sp_SelectQCNFormEdit to appusers
GO




--*****************************************************
--**************************SPROC**********************
if exists (select * from dbo.sysobjects where id = object_id(N'sp_SelectQCNComplexity') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_SelectQCNComplexity
GO

--exec sp_SelectQCNComplexity ''

CREATE PROCEDURE sp_SelectQCNComplexity
@Active varchar(1)
--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON
	SELECT 
	QCNCID,
	Name,
	[Name]+' - ' + Description as QCNComplexity,
	Description,
	case 
		when Active = 1 then 'Yes' 
		Else 'No' 
		end as ActiveName,
	Active,
	LastUpdated 
	
	FROM qcn.[QCNComplexity]
	where Active like '%' + @Active + '%'
END
GO
grant exec on sp_SelectQCNComplexity to appusers
GO

--*****************************************************
--**************************SPROC**********************

if exists (select * from dbo.sysobjects where id = object_id(N'sp_InsertQCNComplexity') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_InsertQCNComplexity
GO

--exec sp_InsertQCNComplexity 'TEST'

CREATE PROCEDURE sp_InsertQCNComplexity
@Name varchar (255),
@Description varchar(100)



--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON
if exists(select * from qcn.QCNComplexity where Name = @Name)
BEGIN
GOTO THEEND
END
insert into qcn.QCNComplexity (Name,Active,LastUpdated,Description) VALUES (@Name,1,getdate(),@Description)

END
THEEND:

GO
grant exec on sp_InsertQCNComplexity to appusers
GO


--*****************************************************
--**************************SPROC**********************
if exists (select * from dbo.sysobjects where id = object_id(N'sp_DeleteQCNComplexity') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_DeleteQCNComplexity
GO

--exec sp_DeleteQCNComplexity

CREATE PROCEDURE sp_DeleteQCNComplexity
@original_QCNCID int,
@original_Name varchar(255)

--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON
	
	Update qcn.[QCNComplexity] set Active = 0
	WHERE 
	[QCNCID] = @original_QCNCID 
		AND [Name] = @original_Name
END
GO
grant exec on sp_DeleteQCNComplexity to appusers
GO

--*****************************************************
--**************************SPROC**********************

if exists (select * from dbo.sysobjects where id = object_id(N'sp_EditQCNComplexity') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_EditQCNComplexity
GO

--exec sp_EditQCNComplexity 'TEST'

CREATE PROCEDURE sp_EditQCNComplexity
@QCNCID int
,@Name varchar (255)
,@Active int
,@Description varchar(100)


--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON
	Update qcn.QCNComplexity set Name = @Name,Active = @Active, LastUpdated = getdate(),Description = @Description where QCNCID = @QCNCID

END

GO
grant exec on sp_EditQCNComplexity to appusers
GO

--*****************************************************
--**************************SPROC**********************

if exists (select * from dbo.sysobjects where id = object_id(N'sp_SelectQCNStatus') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_SelectQCNStatus
GO

--exec sp_SelectQCNStatus '1'

CREATE PROCEDURE sp_SelectQCNStatus
@Active varchar(1)

--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON
	SELECT 
	QCNStatusID,
	[Status],
	Description,
	case 
		when Active = 1 then 'Yes' 
		Else 'No' 
		end as ActiveName,
		Active,
		LastUpdated 
		
	FROM qcn.[QCNStatus]
	where Active like '%' + @Active + '%'
	order by Status

END
GO
grant exec on sp_SelectQCNStatus to appusers
GO

--*****************************************************
--**************************SPROC**********************
if exists (select * from dbo.sysobjects where id = object_id(N'sp_SelectQCNType') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_SelectQCNType
GO

--exec sp_SelectQCNType ''

CREATE PROCEDURE sp_SelectQCNType
@Active varchar(1)
--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON
	SELECT 
	QCNTypeID,
	Name,
	Description,
	case 
		when Active = 1 then 'Yes' 
		Else 'No' 
		end as ActiveName,
	Active,
	LastUpdated 
	
	FROM qcn.[QCNType]
	where Active like '%' + @Active + '%'
END
GO
grant exec on sp_SelectQCNType to appusers
GO


--*****************************************************
--**************************SPROC**********************
if exists (select * from dbo.sysobjects where id = object_id(N'sp_UpdateGembaScores') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_UpdateGembaScores
GO

--exec sp_UpdateGembaScores

CREATE PROCEDURE sp_UpdateGembaScores


--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON
Update gemba.GembaAuditNode set PS_TotalScore = (PS_EmptyBins+PS_BackBins+PS_StockOuts+PS_ReturnVolume+PS_NonBBT)
Update gemba.GembaAuditNode set RS_TotalScore = (RS_BinsFilled+RS_BinServices+RS_NodeSwept+RS_NodeCorrections+RS_EmptiesCollected)
Update gemba.GembaAuditNode set SS_TotalScore = ISNULL((SS_Supplied+SS_KanbansPP+SS_StockoutsPT+SS_StockoutsMatch+SS_HuddleBoardMatch),0)
Update gemba.GembaAuditNode set NIS_TotalScore = (NIS_Labels+NIS_CardHolders+NIS_BinsRacks+NIS_GeneralAppearance+NIS_Signage)
Update gemba.GembaAuditNode set TotalScore = (NIS_TotalScore+PS_TotalScore+RS_TotalScore+SS_TotalScore)
				

END
GO
grant exec on sp_UpdateGembaScores to appusers
GO

--*****************************************************
--**************************SPROC**********************

if exists (select * from dbo.sysobjects where id = object_id(N'sp_UpdateImages') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_UpdateImages
GO

--exec sp_UpdateImages 'gbutler@bluebin.com','151116'
CREATE PROCEDURE sp_UpdateImages
@GembaAuditNodeID int,
@UserLogin varchar(60),
@ImageSourceIDPH int 


--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON
if exists(select * from bluebin.[Image] where ImageSourceID = (select convert(int,(convert(varchar,(select BlueBinUserID from bluebin.BlueBinUser where LOWER(UserLogin) = LOWER(@UserLogin)))+convert(varchar,@ImageSourceIDPH)))))
	BEGIN
	update [bluebin].[Image] set ImageSourceID = @GembaAuditNodeID where ImageSourceID = (select convert(int,(convert(varchar,(select BlueBinUserID from bluebin.BlueBinUser where LOWER(UserLogin) = LOWER(@UserLogin)))+convert(varchar,@ImageSourceIDPH))))
	END

END

GO
grant exec on sp_UpdateImages to appusers
GO

--*****************************************************
--**************************SPROC**********************

if exists (select * from dbo.sysobjects where id = object_id(N'sp_InsertUser') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_InsertUser
GO

--exec sp_InsertUser 'gbutler2@bluebin.com','G','But','','BlueBelt','','Tier2'  


CREATE PROCEDURE sp_InsertUser
@UserLogin varchar(60),
@FirstName varchar(30), 
@LastName varchar(30), 
@MiddleName varchar(30), 
@RoleName  varchar(30),
@Email varchar(60),
@Title varchar(50),
@GembaTier varchar(50),
@ERPUser varchar(60),
@AssignToQCN int
	
--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON
declare @newpwdHash varbinary(max), @RoleID int, @NewBlueBinUserID int, @message varchar(255), @fakelogin varchar(50),@RandomPassword varchar(20),@DefaultExpiration int
select @RoleID = RoleID from bluebin.BlueBinRoles where RoleName = @RoleName
select @DefaultExpiration = ConfigValue from bluebin.Config where ConfigName = 'PasswordExpires' and Active = 1


declare @table table (p varchar(50))
insert @table exec sp_GeneratePassword 8 
set @RandomPassword = (Select p from @table)
set @newpwdHash = convert(varbinary(max),rtrim(@RandomPassword))

if not exists (select BlueBinUserID from bluebin.BlueBinUser where LOWER(UserLogin) = LOWER(@UserLogin))
	BEGIN
	insert into bluebin.BlueBinUser (UserLogin,FirstName,LastName,MiddleName,RoleID,MustChangePassword,PasswordExpires,[Password],Email,Active,LastUpdated,LastLoginDate,Title,GembaTier,ERPUser,AssignToQCN)
	VALUES
	(LOWER(@UserLogin),@FirstName,@LastName,@MiddleName,@RoleID,1,@DefaultExpiration,(HASHBYTES('SHA1', @newpwdHash)),LOWER(@UserLogin),1,getdate(),getdate(),@Title,@GembaTier,@ERPUser,@AssignToQCN)
	;
	SET @NewBlueBinUserID = SCOPE_IDENTITY()
	set @message = 'New User Created - '+ LOWER(@UserLogin)
	select @fakelogin = 'gbutler@bluebin.com'
		exec sp_InsertMasterLog @UserLogin,'Users',@message,@NewBlueBinUserID      
	;
	Select p from @table
	END
	ELSE
	BEGIN
	Select 'exists'
	END
	
	if not exists (select BlueBinResourceID from bluebin.BlueBinResource where FirstName = @FirstName and LastName = @LastName)--select * from bluebin.BlueBinResource
	BEGIN
	exec sp_InsertBlueBinResource @LastName,@FirstName,@MiddleName,@UserLogin,@UserLogin,'','',@Title
	END
END
GO
grant exec on sp_InsertUser to appusers
GO


--*****************************************************
--**************************SPROC**********************

if exists (select * from dbo.sysobjects where id = object_id(N'sp_EditUser') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_EditUser
GO

--exec sp_EditConfig 'TEST'

CREATE PROCEDURE sp_EditUser
@BlueBinUserID int,
@UserLogin varchar(60),
@FirstName varchar(30), 
@LastName varchar(30), 
@MiddleName varchar(30), 
@Active int,
@Email varchar(60), 
@MustChangePassword int,
@PasswordExpires int,
@Password varchar(50),
@RoleName  varchar(30),
@Title varchar(50),
@GembaTier varchar(50),
@ERPUser varchar(60),
@AssignToQCN int


--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON
declare @newpwdHash varbinary(max),@message varchar(255), @fakelogin varchar(50)
set @newpwdHash = convert(varbinary(max),rtrim(@Password))

IF (@Password = '' or @Password is null)
	BEGIN
	update bluebin.BlueBinUser set 
        FirstName = @FirstName, 
        LastName = @LastName, 
        MiddleName = @MiddleName, 
        Active = @Active,
        Email = LOWER(@UserLogin),--@Email, 
        LastUpdated = getdate(), 
        MustChangePassword = @MustChangePassword,
        PasswordExpires = @PasswordExpires,
        RoleID = (select RoleID from bluebin.BlueBinRoles where RoleName = @RoleName),
		Title = @Title,
		GembaTier = @GembaTier,
		ERPUser = @ERPUser,
		AssignToQCN = @AssignToQCN
		Where BlueBinUserID = @BlueBinUserID
	END
	ELSE
	BEGIN
		update bluebin.BlueBinUser set 
        FirstName = @FirstName, 
        LastName = @LastName, 
        MiddleName = @MiddleName, 
        Active = @Active,
        Email = @UserLogin,--@Email, 
        LastUpdated = getdate(), 
        MustChangePassword = @MustChangePassword,
        PasswordExpires = @PasswordExpires,
		[Password] = (HASHBYTES('SHA1', @newpwdHash)),
        RoleID = (select RoleID from bluebin.BlueBinRoles where RoleName = @RoleName),
		Title = @Title,
		GembaTier = @GembaTier,
		ERPUser = @ERPUser,
		AssignToQCN = @AssignToQCN
		Where BlueBinUserID = @BlueBinUserID
	END

	;
	set @message = 'User Updated - '+ @UserLogin
	select @fakelogin = 'gbutler@bluebin.com'
	exec sp_InsertMasterLog @fakelogin,'Users',@message,@BlueBinUserID
END
GO
grant exec on sp_EditUser to appusers
GO

--*****************************************************
--**************************SPROC**********************

if exists (select * from dbo.sysobjects where id = object_id(N'sp_SelectUsers') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_SelectUsers
GO

--exec sp_EditConfig 'TEST'

CREATE PROCEDURE sp_SelectUsers
@Name varchar(50)


--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON
	SELECT 
	[BlueBinUserID]
      ,[UserLogin]
      ,[FirstName]
      ,[LastName]
      ,[MiddleName]
      ,	case 
		when Active = 1 then 'Yes' 
		Else 'No' 
		end as ActiveName
	  ,[Active]
      ,[LastUpdated]
      ,bbur.RoleID
	  ,bbur.RoleName
	  ,[Title]
      ,[LastLoginDate]
      ,[MustChangePassword]
	  ,	case 
		when [MustChangePassword] = 1 then 'Yes' 
		Else 'No' 
		end as [MustChangePasswordName]
      ,[PasswordExpires]
      ,'' as [Password]
      ,[Email]
	  ,GembaTier
	  ,ERPUser
	  ,case 
		when [AssignToQCN] = 1 then 'Yes' 
		Else 'No' 
		end as AssignToQCNName
		,AssignToQCN
  FROM [bluebin].[BlueBinUser] bbu
  inner join bluebin.BlueBinRoles bbur on bbu.RoleID = bbur.RoleID
  where UserLogin <> ''
  and
  ([LastName] like '%' + @Name + '%' 
	OR [FirstName] like '%' + @Name + '%' )
  order by LastName

END
GO
grant exec on sp_SelectUsers to appusers
GO


--*****************************************************
--**************************SPROC**********************
if exists (select * from dbo.sysobjects where id = object_id(N'sp_SelectRoles') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_SelectRoles
GO

--exec sp_SelectRoles 'Blue'
CREATE PROCEDURE sp_SelectRoles
@RoleName varchar(50)


--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON
Select RoleID,RoleName from bluebin.BlueBinRoles
where RoleName like '%' + @RoleName + '%'
order by RoleName

END
GO
grant exec on sp_SelectRoles to appusers
GO


--*****************************************************
--**************************SPROC**********************
if exists (select * from dbo.sysobjects where id = object_id(N'sp_InsertRoles') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_InsertRoles
GO


CREATE PROCEDURE sp_InsertRoles
@RoleName varchar(50)


--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON
insert into bluebin.BlueBinRoles select @RoleName

END
GO
grant exec on sp_InsertRoles to appusers
GO



--*****************************************************
--**************************SPROC**********************

if exists (select * from dbo.sysobjects where id = object_id(N'sp_EditRoles') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_EditRoles
GO


CREATE PROCEDURE sp_EditRoles
@RoleID int,
@RoleName varchar(50)


--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON

update bluebin.BlueBinRoles set RoleName = @RoleName where RoleID = @RoleID
END
GO
grant exec on sp_EditRoles to appusers
GO

--*****************************************************
--**************************SPROC**********************

if exists (select * from sysobjects where id = object_id(N'sp_GeneratePassword') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_GeneratePassword
GO
CREATE PROCEDURE sp_GeneratePassword
(
    @Length int
)

AS

declare @ch varchar (8000),@ch2 varchar (8000),@ch3 varchar (8000),@ch4 varchar (8000), @ps  varchar (10)

select @ps = '', @ch =
replicate('ABCDEFGHJKLMNPQURSUVWXYZ',8), @ch2 =replicate('0123456789',9), @ch3 =
replicate('abcdefghjkmnpqursuvwxyz',8), @ch4 =replicate('~!@#$%^&()_',6)

while len(@ps)<@length 
	begin 
set @ps=@ps+substring(@ch,convert(int,rand()*len(@ch)-1),1)
+substring(@ch3,convert(int,rand()*len(@ch2)-1),1)
+substring(@ch2,convert(int,rand()*len(@ch3)-1),1)
+substring(@ch4,convert(int,rand()*len(@ch4)-1),1) 
	end

select [Password] = left(@ps,@length)

GO
grant exec on sp_GeneratePassword to appusers
GO

--*****************************************************
--**************************SPROC**********************


if exists (select * from dbo.sysobjects where id = object_id(N'sp_ForgotPasswordBlueBinUser') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_ForgotPasswordBlueBinUser
GO
CREATE PROCEDURE sp_ForgotPasswordBlueBinUser
      @UserLogin NVARCHAR(60)
AS
BEGIN
      SET NOCOUNT ON;
      DECLARE @BlueBinUserID INT, @LastUpdated DATETIME,@RandomPassword varchar(20), @newpwdHash varbinary(max)
	  
     
      SELECT @BlueBinUserID = BlueBinUserID
      FROM [bluebin].[BlueBinUser] WHERE LOWER(UserLogin) = LOWER(@UserLogin) --(HASHBYTES('SHA1', @oldpwdHash))--@Password
     
      IF @BlueBinUserID IS NOT NULL  
      BEGIN
            DECLARE @UserTable TABLE (BlueBinUserID int, UserLogin varchar(60), pwd varchar(10),created datetime)
			declare @table table (p varchar(50))

			insert @table exec sp_GeneratePassword 8 
			set @RandomPassword = (Select p from @table)
			insert @UserTable (BlueBinUserID,UserLogin,pwd,created) VALUES (@BlueBinUserID,LOWER(@UserLogin),@RandomPassword,getdate())
			set @newpwdHash = convert(varbinary(max),rtrim(@RandomPassword))

						UPDATE [bluebin].[BlueBinUser]
						SET MustChangePassword = 1,LastUpdated = getdate(), [Password] = (HASHBYTES('SHA1', @newpwdHash))
						WHERE BlueBinUserID = @BlueBinUserID

			Select pwd from @UserTable
			--Select @newpwdHash
			--select (HASHBYTES('SHA1', @newpwdHash))
	--
	END
END
	
GO
grant exec on sp_ForgotPasswordBlueBinUser to appusers
GO




--*****************************************************
--**************************SPROC**********************

if exists (select * from dbo.sysobjects where id = object_id(N'sp_ValidateBlueBinUser') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_ValidateBlueBinUser
GO

--exec sp_ValidateBlueBinUser 'gbutler@bluebin.com','12345'
--grant exec on sp_ValidateBlueBinUser to appusers

CREATE PROCEDURE [dbo].[sp_ValidateBlueBinUser]
      @UserLogin NVARCHAR(60),
      @Password varchar(max)
AS
BEGIN
      SET NOCOUNT ON;
      DECLARE @BlueBinUserID INT, @LastLoginDate DATETIME, @pwdHash varbinary(max), @MustChangePassword int
	  set @pwdHash = convert(varbinary(max),rtrim(@Password))
     
      SELECT 
	  @BlueBinUserID = BlueBinUserID, 
	  @LastLoginDate = LastLoginDate, 
	  @MustChangePassword = 
		case when LastUpdated  + PasswordExpires < getdate() then 1 else MustChangePassword end  --Password Expiration Date or if flag set
      FROM [bluebin].[BlueBinUser] WHERE LOWER(UserLogin) = LOWER(@UserLogin) AND [Password] = (HASHBYTES('SHA1', @pwdHash))--@Password
     
      IF @UserLogin IS NOT NULL  
      BEGIN
            IF EXISTS(SELECT BlueBinUserID FROM [bluebin].[BlueBinUser] WHERE BlueBinUserID = @BlueBinUserID)
            BEGIN
				IF EXISTS(SELECT BlueBinUserID FROM [bluebin].[BlueBinUser] WHERE BlueBinUserID = @BlueBinUserID and Active = 1)
					BEGIN
					  IF EXISTS(SELECT BlueBinUserID FROM [bluebin].[BlueBinUser] WHERE BlueBinUserID = @BlueBinUserID and Active = 1 and MustChangePassword = 0)
						BEGIN
						UPDATE [bluebin].[BlueBinUser]
						SET LastLoginDate = GETDATE()
						WHERE BlueBinUserID = @BlueBinUserID
						SELECT @BlueBinUserID [BlueBinUserID] -- User Valid
						END
						ELSE
						BEGIN
						SELECT -3 -- Must Change Password
						END
					END
					ELSE
					BEGIN
						SELECT -2 -- User not active.
					END
			END
			ELSE
			BEGIN
				SELECT -1 -- User invalid.
			END
	END
--select * from bluebin.BlueBinUser where [Password] = HASHBYTES('SHA1', @Password)
END
GO
grant exec on sp_ValidateBlueBinUser to appusers
GO






--*****************************************************
--**************************SPROC**********************


if exists (select * from dbo.sysobjects where id = object_id(N'sp_ChangePasswordBlueBinUser') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_ChangePasswordBlueBinUser
GO

CREATE PROCEDURE [dbo].[sp_ChangePasswordBlueBinUser]
      @UserLogin NVARCHAR(60),
      @OldPassword varchar(max),
	  @NewPassword varchar(max),
	  @ConfirmNewPassword varchar(max)
AS
BEGIN
      SET NOCOUNT ON;
      DECLARE @BlueBinUserID INT, @LastLoginDate DATETIME, @newpwdHash varbinary(max), @oldpwdHash varbinary(max)
	  set @oldpwdHash = convert(varbinary(max),rtrim(@OldPassword))
	  set @newpwdHash = convert(varbinary(max),rtrim(@NewPassword))
     
      SELECT @BlueBinUserID = BlueBinUserID, @LastLoginDate = LastLoginDate
      FROM [bluebin].[BlueBinUser] WHERE LOWER(UserLogin) = LOWER(@UserLogin) AND [Password] = (HASHBYTES('SHA1', @oldpwdHash))--@Password
     
      IF @BlueBinUserID IS NOT NULL  
      BEGIN
            IF @NewPassword = @ConfirmNewPassword
            BEGIN
				IF @OldPassword <> @NewPassword
					BEGIN
					  IF (@NewPassword like '%[0-9]%')
						BEGIN
						UPDATE [bluebin].[BlueBinUser]
						SET LastLoginDate = GETDATE(), MustChangePassword = 0,LastUpdated = getdate(), [Password] = (HASHBYTES('SHA1', @newpwdHash))
						WHERE BlueBinUserID = @BlueBinUserID

						SELECT @BlueBinUserID [BlueBinUserID] -- User Valid
						END
						ELSE
						BEGIN
						SELECT -3 -- Must use at least one number in Password
						END
					END
					ELSE
					BEGIN
						SELECT -2 -- Must use a different password than previous.
					END
			END
			ELSE
			BEGIN
				SELECT -1 -- Passwords don't match.
			END
	END
	ELSE
	BEGIN
	 SELECT -4 -- Old Password does not match with our database records.
	END

END
GO
grant exec on sp_ChangePasswordBlueBinUser to appusers
GO


--*****************************************************
--**************************SPROC**********************


if exists (select * from dbo.sysobjects where id = object_id(N'sp_EditGembaAuditNode') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_EditGembaAuditNode
GO

--exec sp_EditGembaAuditNode 'TEST'

CREATE PROCEDURE sp_EditGembaAuditNode
@GembaAuditNodeID int,
@Location varchar(10),
@AdditionalComments varchar(max),
@PS_EmptyBins int,
@PS_BackBins int,
@PS_StockOuts int,
@PS_ReturnVolume int,
@PS_NonBBT int,
@PS_OrangeCones int,
@PS_Comments varchar(max),
@RS_BinsFilled int,
@RS_EmptiesCollected int,
@RS_BinServices int,
@RS_NodeSwept int,
@RS_NodeCorrections int,
@RS_ShadowedUser varchar(255),
@RS_Comments varchar(max),
@SS_Supplied int,
@SS_KanbansPP int,
@SS_StockoutsPT int,
@SS_StockoutsMatch int,
@SS_HuddleBoardMatch int,
@SS_Comments varchar(max),
@NIS_Labels int,
@NIS_CardHolders int,
@NIS_BinsRacks int,
@NIS_GeneralAppearance int,
@NIS_Signage int,
@NIS_Comments varchar(max),
@PS_TotalScore int,
@RS_TotalScore int,
@SS_TotalScore int,
@NIS_TotalScore int,
@TotalScore int
			,@Auditer varchar(255),@ImageSourceIDPH int


--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON
Update [gemba].[GembaAuditNode] SET

           [LocationID] = @Location
           ,[AdditionalComments] = @AdditionalComments
           ,[PS_EmptyBins] = @PS_EmptyBins
           ,[PS_BackBins] = @PS_BackBins
           ,[PS_StockOuts] = @PS_StockOuts
           ,[PS_ReturnVolume] = @PS_ReturnVolume
           ,[PS_NonBBT] = @PS_NonBBT
		   ,[PS_OrangeCones] = @PS_OrangeCones
           ,[PS_Comments] = @PS_Comments
           ,[RS_BinsFilled] = @RS_BinsFilled
		   ,[RS_EmptiesCollected] = @RS_EmptiesCollected
           ,[RS_BinServices] = @RS_BinServices
           ,[RS_NodeSwept] = @RS_NodeSwept
           ,[RS_NodeCorrections] = @RS_NodeCorrections
           ,[RS_ShadowedUserID] = (select BlueBinResourceID from bluebin.BlueBinResource where LastName + ', ' + FirstName + ' (' + Login + ')' = @RS_ShadowedUser)
           ,[RS_Comments] = @RS_Comments
           ,[SS_Supplied] = @SS_Supplied
		   ,[SS_KanbansPP] = @SS_KanbansPP
		   ,[SS_StockoutsPT] = @SS_StockoutsPT
		   ,[SS_StockoutsMatch] = @SS_StockoutsMatch
		   ,[SS_HuddleBoardMatch] = @SS_HuddleBoardMatch
		   ,[SS_Comments] = @SS_Comments
		   ,[NIS_Labels] = @NIS_Labels
           ,[NIS_CardHolders] = @NIS_CardHolders
           ,[NIS_BinsRacks] = @NIS_BinsRacks
           ,[NIS_GeneralAppearance] = @NIS_GeneralAppearance
           ,[NIS_Signage] = @NIS_Signage
           ,[NIS_Comments] = @NIS_Comments
           ,[PS_TotalScore] = @PS_TotalScore
           ,[RS_TotalScore] = @RS_TotalScore
		   ,[SS_TotalScore] = @SS_TotalScore
           ,[NIS_TotalScore] = @NIS_TotalScore
           ,[TotalScore] = @TotalScore
           ,[LastUpdated] = getdate()
WHERE [GembaAuditNodeID] = @GembaAuditNodeID
;--Insert New entry for Gemba into MasterLog
exec sp_InsertMasterLog @Auditer,'Gemba','Update Gemba Node Audit',@GembaAuditNodeID
;--Update the Images uploaded from the PlaceHolderID to the real entryID
exec sp_UpdateImages @GembaAuditNodeID,@Auditer,@ImageSourceIDPH
;--Update the master Log for images from the PlaceHolderID to the real entryID
update bluebin.MasterLog 
set ActionID = @GembaAuditNodeID 
where ActionType = 'Gemba' and 
		BlueBinUserID = (select BlueBinUserID from bluebin.BlueBinUser where LOWER(UserLogin) = LOWER(@Auditer)) and 
			ActionID = (select convert(int,(convert(varchar,(select BlueBinUserID from bluebin.BlueBinUser where LOWER(UserLogin) = LOWER(@Auditer)))+convert(varchar,@ImageSourceIDPH))))
--if exists(select * from bluebin.[Image] where ImageSourceID = (select convert(int,(convert(varchar,(select BlueBinUserID from bluebin.BlueBinUser where LOWER(UserLogin) = LOWER(@UserLogin)))+convert(varchar,@ImageSourceIDPH))))
--	BEGIN
--	update [bluebin].[Image] set ImageSourceID = @GembaAuditNodeID where ImageSourceID = (select convert(int,(convert(varchar,(select BlueBinUserID from bluebin.BlueBinUser where LOWER(UserLogin) = LOWER(@UserLogin)))+convert(varchar,@ImageSourceIDPH))))
--	END
END
GO
grant exec on sp_EditGembaAuditNode to appusers
GO


--*****************************************************
--**************************SPROC**********************

if exists (select * from dbo.sysobjects where id = object_id(N'sp_InsertGembaAuditNode') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_InsertGembaAuditNode
GO

--exec sp_InsertGembaAuditNode 'TEST'

CREATE PROCEDURE sp_InsertGembaAuditNode
@Location varchar(10),
@Auditer varchar(255),
@AdditionalComments varchar(max),
@PS_EmptyBins int,
@PS_BackBins int,
@PS_StockOuts int,
@PS_ReturnVolume int,
@PS_NonBBT int,
@PS_OrangeCones int,
@PS_Comments varchar(max),
@RS_BinsFilled int,
@RS_EmptiesCollected int,
@RS_BinServices int,
@RS_NodeSwept int,
@RS_NodeCorrections int,
@RS_ShadowedUser varchar(255),
@RS_Comments varchar(max),
@SS_Supplied int,
@SS_KanbansPP int,
@SS_StockoutsPT int,
@SS_StockoutsMatch int,
@SS_HuddleBoardMatch int,
@SS_Comments varchar(max),
@NIS_Labels int,
@NIS_CardHolders int,
@NIS_BinsRacks int,
@NIS_GeneralAppearance int,
@NIS_Signage int,
@NIS_Comments varchar(max),
@PS_TotalScore int,
@RS_TotalScore int,
@SS_TotalScore int,
@NIS_TotalScore int,
@TotalScore int
			,@ImageSourceIDPH int



--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON
declare @GembaAuditNodeID int

Insert into [gemba].[GembaAuditNode]
(
	Date,
	LocationID,
	AuditerUserID,
	AdditionalComments,
	PS_EmptyBins,
	PS_BackBins,
	PS_StockOuts,
	PS_ReturnVolume,
	PS_NonBBT,
	PS_OrangeCones,
	PS_Comments,
	RS_BinsFilled,
	RS_EmptiesCollected,
	RS_BinServices,
	RS_NodeSwept,
	RS_NodeCorrections,
	RS_ShadowedUserID,
	RS_Comments,
	SS_Supplied,
	SS_KanbansPP,
	SS_StockoutsPT,
	SS_StockoutsMatch,
	SS_HuddleBoardMatch,
	SS_Comments,
	NIS_Labels,
	NIS_CardHolders,
	NIS_BinsRacks,
	NIS_GeneralAppearance,
	NIS_Signage,
	NIS_Comments,
	PS_TotalScore,
	RS_TotalScore,
	SS_TotalScore,
	NIS_TotalScore,
	TotalScore,
	Active,
	LastUpdated)
VALUES 
(
getdate(),  --Date
@Location,
(select BlueBinUserID from bluebin.BlueBinUser where LOWER(UserLogin) = LOWER(@Auditer)),
@AdditionalComments,
@PS_EmptyBins,
@PS_BackBins,
@PS_StockOuts,
@PS_ReturnVolume,
@PS_NonBBT,
@PS_OrangeCones,
@PS_Comments,
@RS_BinsFilled,
@RS_EmptiesCollected,
@RS_BinServices,
@RS_NodeSwept,
@RS_NodeCorrections,
(select BlueBinResourceID from bluebin.BlueBinResource where LastName + ', ' + FirstName + ' (' + Login + ')' = @RS_ShadowedUser ),
@RS_Comments,
@SS_Supplied,
@SS_KanbansPP,
@SS_StockoutsPT,
@SS_StockoutsMatch,
@SS_HuddleBoardMatch,
@SS_Comments,
@NIS_Labels,
@NIS_CardHolders,
@NIS_BinsRacks,
@NIS_GeneralAppearance,
@NIS_Signage,
@NIS_Comments,
@PS_TotalScore,
@RS_TotalScore,
@SS_TotalScore,
@NIS_TotalScore,
@TotalScore,
1, --Active
getdate() --Last Updated
)
;--Insert New entry for Gemba into MasterLog with  Scope Identity of the newly created ID
	SET @GembaAuditNodeID = SCOPE_IDENTITY()
	exec sp_InsertMasterLog @Auditer,'Gemba','New Gemba Node Audit',@GembaAuditNodeID
;--Update the Images uploaded from the PlaceHolderID to the real entryID
exec sp_UpdateImages @GembaAuditNodeID,@Auditer,@ImageSourceIDPH
;--Update the master Log for images from the PlaceHolderID to the real entryID
update bluebin.MasterLog 
set ActionID = @GembaAuditNodeID 
where ActionType = 'Gemba' and 
		BlueBinUserID = (select BlueBinUserID from bluebin.BlueBinUser where LOWER(UserLogin) = LOWER(@Auditer)) and 
			ActionID = (select convert(int,(convert(varchar,(select BlueBinUserID from bluebin.BlueBinUser where LOWER(UserLogin) = LOWER(@Auditer)))+convert(varchar,@ImageSourceIDPH))))
--if exists(select * from bluebin.[Image] where ImageSourceID = (select convert(int,(convert(varchar,(select BlueBinUserID from bluebin.BlueBinUser where LOWER(UserLogin) = LOWER(@UserLogin)))+convert(varchar,@ImageSourceIDPH))))
--	BEGIN
--	update [bluebin].[Image] set ImageSourceID = @GembaAuditNodeID where ImageSourceID = (select convert(int,(convert(varchar,(select BlueBinUserID from bluebin.BlueBinUser where LOWER(UserLogin) = LOWER(@UserLogin)))+convert(varchar,@ImageSourceIDPH))))
--	END

END
GO
grant exec on sp_InsertGembaAuditNode to appusers
GO


--*****************************************************
--**************************SPROC**********************

if exists (select * from dbo.sysobjects where id = object_id(N'sp_InsertGembaAuditStage') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_InsertGembaAuditStage
GO

--exec sp_InsertGembaAuditStage 'TEST'

CREATE PROCEDURE sp_InsertGembaAuditStage
	@Auditer varchar(255),
	@KanbansFilled int,
	@KanbansFilledText varchar(max),
	@LeftBehind int,
	@FollowUpDistrib int,
	@FollowUpDistribText varchar(max),
	@Concerns varchar(max),
	@DirectOrderBins int,
	@OldestBin datetime,
	@CheckedOpenOrders int,
	@CheckedOpenOrdersText varchar(max),
	@HowManyLate int,
	@FollowUpBuyers int,
	@FollowUpBuyersText varchar(max),
	@UpdatedStatusTag int,
	@UpdatedStatusTagText varchar(max),
	@ReqsSubmitted int,
	@ReqsSubmittedText varchar(max),
	@BinsInOrder int,
	@BinsInOrderText varchar(max),
	@AreaNeatTidy int,
	@AreaNeatTidyText varchar(max),
	@CartsClean int,
	@CartsCleanText varchar(max),
	@AdditionalCommentsText varchar(max)


--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON

declare @GembaAuditStageID int

insert into [gemba].[GembaAuditStage] (
    [Date],
	[AuditerUserID],
	[KanbansFilled],
	[KanbansFilledText],
	[LeftBehind],
	[FollowUpDistrib],
	[FollowUpDistribText],
	[Concerns],
	[DirectOrderBins],
	[OldestBin],
	[CheckOpenOrders],
	[CheckOpenOrdersText],
	[HowManyLate],
	[FollowUpBuyers],
	[FollowUpBuyersText],
	[UpdatedStatusTag],
	[UpdatedStatusTagText],
	[ReqsSubmitted],
	[ReqsSubmittedText],
	[BinsInOrder],
	[BinsInOrderText],
	[AreaNeatTidy],
	[AreaNeatTidyText],
	[CartsClean],
	[CartsCleanText],
	[AdditionalComments],
	[Active],
	[LastUpdated]
)
VALUES (
getdate(), --Date
(select BlueBinUserID from bluebin.BlueBinUser where LOWER(UserLogin) = LOWER(@Auditer)),
@KanbansFilled,
@KanbansFilledText,
@LeftBehind,
@FollowUpDistrib,
@FollowUpDistribText,
@Concerns,
@DirectOrderBins,
@OldestBin,
@CheckedOpenOrders,
@CheckedOpenOrdersText,
@HowManyLate,
@FollowUpBuyers,
@FollowUpBuyersText,
@UpdatedStatusTag,
@UpdatedStatusTagText,
@ReqsSubmitted,
@ReqsSubmittedText,
@BinsInOrder,
@BinsInOrderText,
@AreaNeatTidy,
@AreaNeatTidyText,
@CartsClean,
@CartsCleanText,
@AdditionalCommentsText,
1, --Active
getdate())	--Last Updated

	SET @GembaAuditStageID = SCOPE_IDENTITY()
	exec sp_InsertMasterLog @Auditer,'Gemba','New Gemba Stage Audit',@GembaAuditStageID


END
GO
grant exec on sp_InsertGembaAuditStage to appusers
GO


--*****************************************************
--**************************SPROC**********************

if exists (select * from dbo.sysobjects where id = object_id(N'sp_InsertQCN') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_InsertQCN
GO

--exec sp_InsertQCN 

CREATE PROCEDURE sp_InsertQCN
@DateRequested datetime,
@FacilityID int,
@LocationID varchar(10),
@ItemID varchar(32),
@ClinicalDescription varchar(30),
@Sequence varchar(30),
@Requester varchar(255),
@ApprovedBy varchar(255),
@Assigned int,
@QCNComplexity varchar(255),
@QCNType varchar(255),
@Details varchar(max),
@Updates varchar(max),
@QCNStatus varchar(255),
@UserLogin varchar (60),
@InternalReference varchar(50),
@ManuNumName varchar(60),
@Par int,
@UOM varchar(10)


--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON
set @UserLogin = LOWER(@UserLogin)
Declare @QCNID int, @LoggedUserID int
set @LoggedUserID = (select BlueBinUserID from bluebin.BlueBinUser where LOWER(UserLogin) = LOWER(@UserLogin))

insert into [qcn].[QCN] 
(FacilityID,
[LocationID],
	[ItemID],
		[ClinicalDescription],
		[Sequence],
		[RequesterUserID],
		[ApprovedBy],
			[AssignedUserID],
				[QCNCID],
				[QCNTypeID],
					[Details],
						[Updates],
							[DateRequested],
							[DateEntered],
								[DateCompleted],
									[QCNStatusID],
										[Active],
											[LastUpdated],
												[InternalReference],
												ManuNumName,
													[LoggedUserID],
													Par,
													UOM)

select 
@FacilityID,
@LocationID,
case when @ItemID = '' then NULL else @ItemID end,
@ClinicalDescription,
@Sequence,
@Requester,
@ApprovedBy,
case when @Assigned = '' then NULL else @Assigned end,
@QCNComplexity,
(select max([QCNTypeID]) from [qcn].[QCNType] where [Name] = @QCNType),
@Details,
@Updates,
@DateRequested,
getdate(),
Case when @QCNStatus in('Rejected','Completed') then getdate() else NULL end,
(select max([QCNStatusID]) from [qcn].[QCNStatus] where [Status] = @QCNStatus),
1, --Active
getdate(), --LastUpdated
@InternalReference,
@ManuNumName,
@LoggedUserID,
@Par,
@UOM


SET @QCNID = SCOPE_IDENTITY()
	exec sp_InsertMasterLog @UserLogin,'QCN','Submit QCN Form',@QCNID

END

GO
grant exec on sp_InsertQCN to appusers
GO
--*****************************************************
--**************************SPROC**********************

if exists (select * from dbo.sysobjects where id = object_id(N'sp_SelectVersion') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_SelectVersion
GO


CREATE PROCEDURE sp_SelectVersion

--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON
	select ConfigValue from bluebin.Config where ConfigName = 'Version'

END

GO
grant exec on sp_SelectVersion to appusers
GO


--*****************************************************
--**************************SPROC**********************

if exists (select * from dbo.sysobjects where id = object_id(N'sp_SelectTableauURL') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_SelectTableauURL
GO


CREATE PROCEDURE sp_SelectTableauURL

--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON
	select ConfigValue from bluebin.Config where ConfigName = 'TableauURL'

END

GO
grant exec on sp_SelectTableauURL to appusers
GO

--*****************************************************
--**************************SPROC**********************

if exists (select * from dbo.sysobjects where id = object_id(N'sp_SelectConesLocation') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_SelectConesLocation
GO

--exec sp_SelectQCNLocation
CREATE PROCEDURE sp_SelectConesLocation

--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON
Select distinct a.LocationID,rTrim(a.ItemID) as ItemID,COALESCE(b.ItemClinicalDescription,b.ItemDescription,'No Description'),rTrim(a.ItemID)+ ' - ' + COALESCE(b.ItemClinicalDescription,b.ItemDescription,'No Description') as ExtendedDescription 
from [bluebin].[DimBin] a 
                                inner join [bluebin].[DimItem] b on rtrim(a.ItemID) = rtrim(b.ItemID)  
								UNION 
								select distinct LocationID,'' as ItemID,'' as ItemClinicalDescription, ''  as ExtendedDescription from [bluebin].[DimBin]
                                       
								UNION 
								select distinct q.LocationID,rTrim(q.ItemID) as ItemID,COALESCE(di.ItemClinicalDescription,di.ItemDescription,'No Description'),rTrim(q.ItemID)+ ' - ' + COALESCE(di.ItemClinicalDescription,di.ItemDescription,'No Description') as ExtendedDescription  
								from qcn.QCN q
								inner join bluebin.DimItem di on q.ItemID = di.ItemID
								inner join bluebin.DimLocation dl on q.LocationID = dl.LocationID
                                       order by 4 asc

END
GO
grant exec on sp_SelectConesLocation to appusers
GO



--*****************************************************
--**************************SPROC**********************


if exists (select * from dbo.sysobjects where id = object_id(N'sp_SelectQCNFacility') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_SelectQCNFacility
GO

--exec sp_SelectQCNFacility
CREATE PROCEDURE sp_SelectQCNFacility

--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON

select 
	distinct 
	q.[FacilityID],
    df.FacilityName as FacilityName
	from qcn.QCN q
	left join [bluebin].[DimFacility] df on q.FacilityID = df.FacilityID 
	order by df.FacilityName
END
GO
grant exec on sp_SelectQCNFacility to appusers
GO



--*****************************************************
--**************************SPROC**********************


if exists (select * from dbo.sysobjects where id = object_id(N'sp_SelectQCNLocation') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_SelectQCNLocation
GO

--exec sp_SelectQCNLocation
CREATE PROCEDURE sp_SelectQCNLocation

--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON

select 
	distinct 
	q.[LocationID],
    case
		when q.[LocationID] = 'Multiple' then q.LocationID
		else case	when dl.LocationID = dl.LocationName then dl.LocationID
					else dl.LocationID + ' - ' + dl.[LocationName] end end as LocationName
	from qcn.QCN q
	left join [bluebin].[DimLocation] dl on q.LocationID = dl.LocationID and dl.BlueBinFlag = 1
	order by LocationID
END
GO
grant exec on sp_SelectQCNLocation to appusers
GO



--*****************************************************
--**************************SPROC**********************

if exists (select * from dbo.sysobjects where id = object_id(N'sp_InsertImage') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_InsertImage
GO

--exec sp_SelectQCN ''
CREATE PROCEDURE sp_InsertImage
@ImageName varchar(100),
@ImageType varchar(10),
@ImageSource varchar(100),
@UserLogin varchar(60),
@ImageSourceID int,
@Image varbinary(max)

--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON
insert into bluebin.[Image] 
(ImageName,ImageType,ImageSource,ImageSourceID,[Image],[Active],[DateCreated],[LastUpdated])        
VALUES 
(@ImageName,@ImageType,@ImageSource,(select convert(int,(convert(varchar,(select BlueBinUserID from bluebin.BlueBinUser where LOWER(UserLogin) = LOWER(@UserLogin)))+convert(varchar,@ImageSourceID)))),@Image,1,getdate(),getdate())

;
declare @ImageSourcePH int = (select convert(int,(convert(varchar,(select BlueBinUserID from bluebin.BlueBinUser where LOWER(UserLogin) = LOWER(@UserLogin)))+convert(varchar,@ImageSourceID))))
declare @Text varchar(60) = 'Insert Image - '+@ImageName

exec sp_InsertMasterLog @UserLogin,'Gemba',@Text,@ImageSourcePH

END
GO
grant exec on sp_InsertImage to appusers
GO



--*****************************************************
--**************************SPROC**********************

if exists (select * from dbo.sysobjects where id = object_id(N'sp_SelectImages') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_SelectImages
GO

--exec sp_SelectImages '','gbutler@bluebin.com','151116'
CREATE PROCEDURE sp_SelectImages
@GembaAuditNodeID int,
@UserLogin varchar(60),
@ImageSourceIDPH int 



--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON
Select ImageID,ImageName,ImageType,ImageSource,ImageSourceID,Active,DateCreated 
from bluebin.[Image]    
where 
(ImageSourceID = @GembaAuditNodeID and ImageSource like 'GembaAuditNode%') 
or 
(ImageSourceID = (select convert(int,(convert(varchar,(select BlueBinUserID from bluebin.BlueBinUser where LOWER(UserLogin) = LOWER(@UserLogin)))+convert(varchar,@ImageSourceIDPH)))))
order by DateCreated desc


END
GO
grant exec on sp_SelectImages to appusers
GO


--*****************************************************
--**************************SPROC**********************

if exists (select * from dbo.sysobjects where id = object_id(N'sp_DeleteImages') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_DeleteImages
GO

--exec sp_DeleteImages 'gbutler@bluebin.com','151116'
CREATE PROCEDURE sp_DeleteImages
@UserLogin varchar(60),
@ImageSourceIDPH int 


--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON
Delete 
from bluebin.[Image]
where 
ImageSourceID = (select convert(int,(convert(varchar,(select BlueBinUserID from bluebin.BlueBinUser where LOWER(UserLogin) = LOWER(@UserLogin)))+convert(varchar,@ImageSourceIDPH))))
;
Delete from bluebin.MasterLog 
where ActionType = 'Gemba' and 
		BlueBinUserID = (select BlueBinUserID from bluebin.BlueBinUser where LOWER(UserLogin) = LOWER(@UserLogin)) and 
			ActionID = (select convert(int,(convert(varchar,(select BlueBinUserID from bluebin.BlueBinUser where LOWER(UserLogin) = LOWER(@UserLogin)))+convert(varchar,@ImageSourceIDPH))))

END
GO
grant exec on sp_DeleteImages to appusers
GO


--*****************************************************
--**************************SPROC**********************


if exists (select * from dbo.sysobjects where id = object_id(N'sp_SelectFacilities') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_SelectFacilities
GO

--exec sp_SelectFacilities 
CREATE PROCEDURE sp_SelectFacilities


--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON

SELECT DISTINCT rtrim(df.[FacilityID]) as FacilityID,df.[FacilityName] 
FROM bluebin.[DimFacility] df

inner join bluebin.DimLocation dl on df.FacilityID = dl.LocationFacility and dl.BlueBinFlag = 1
order by df.[FacilityName] asc

END 
GO
grant exec on sp_SelectFacilities to public
GO



--*****************************************************
--**************************SPROC**********************

if exists (select * from dbo.sysobjects where id = object_id(N'sp_SelectBlueBinLocationMaster') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_SelectBlueBinLocationMaster
GO

--exec sp_SelectBlueBinLocationMaster '',''
CREATE PROCEDURE sp_SelectBlueBinLocationMaster
@LocationName varchar(255),
@AcctUnit varchar(40)


--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON

IF exists (select * from sys.tables where name = 'RQLOC')
BEGIN
select
LocationKey,
LocationID,
LocationName,
isnull(gl.ACCT_UNIT,'') as AcctUnit,
isnull(gl.DESCRIPTION,'') as AcctUnitDesc,
case
	when rl.REQ_LOCATION is null then 'No' else 'Yes'
	end as Updated
FROM 
[bluebin].[DimLocation] dl
left join dbo.RQLOC rl on dl.LocationID = rl.REQ_LOCATION
left join dbo.GLNAMES gl on rl.ISS_ACCT_UNIT = gl.ACCT_UNIT and rl.COMPANY = gl.COMPANY
WHERE 
LocationName LIKE '%' + @LocationName + '%' and BlueBinFlag = 1 and isnull(gl.ACCT_UNIT,'') LIKE '%' + @AcctUnit + '%' 
order by LocationID
END
ELSE 
	BEGIN
	select
	LocationKey,
	LocationID,
	LocationName,
	'N/A' as AcctUnit,
	'N/A' as AcctUnitDesc,
	'Yes' as Updated
	FROM 
	[bluebin].[DimLocation] dl
	WHERE 
	LocationName LIKE '%' + @LocationName + '%' and BlueBinFlag = 1  
	order by LocationID
	END


END
GO
grant exec on sp_SelectBlueBinLocationMaster to appusers
GO

--*****************************************************
--**************************SPROC**********************

if exists (select * from dbo.sysobjects where id = object_id(N'sp_InsertBlueBinLocationMaster') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_InsertBlueBinLocationMaster
GO

--exec sp_InsertBlueBinLocationMaster 'BB'
CREATE PROCEDURE sp_InsertBlueBinLocationMaster
@LocationID varchar(10),
@LocationName varchar(255)


--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON
if not exists (select * from bluebin.DimLocation where rtrim(LocationID) = rtrim(@LocationID))
BEGIN
insert [bluebin].[DimLocation] (LocationKey,LocationID,LocationName,LocationFacility,BlueBinFlag)
VALUES ((select max(LocationKey)+1 from bluebin.DimLocation),@LocationID,@LocationName,1,1)
END

END
GO
grant exec on sp_InsertBlueBinLocationMaster to appusers
GO

--*****************************************************
--**************************SPROC**********************


if exists (select * from dbo.sysobjects where id = object_id(N'sp_SelectConfigValues') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_SelectConfigValues
GO

--exec sp_SelectConfigValues 'TableauSiteName'  exec sp_SelectConfigValues 'TableauDefaultUser'

CREATE PROCEDURE sp_SelectConfigValues
	@ConfigName NVARCHAR(50)

--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON
	SELECT 
	ConfigValue
	FROM bluebin.[Config] 
	where ConfigName = @ConfigName

END
GO
grant exec on sp_SelectConfigValues to appusers
GO



--*****************************************************
--**************************SPROC**********************

if exists (select * from dbo.sysobjects where id = object_id(N'sp_DeleteBlueBinLocationMaster') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_DeleteBlueBinLocationMaster 

GO

--exec sp_DeleteBlueBinLocationMaster NULL 
CREATE PROCEDURE sp_DeleteBlueBinLocationMaster
@LocationKey int

--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON
delete from [bluebin].[DimLocation]  
where LocationKey = @LocationKey

if exists (select * from bluebin.BlueBinParMaster where LocationID = (select LocationID from [bluebin].[DimLocation] where LocationKey = @LocationKey))
BEGIN
delete from [bluebin].[BlueBinParMaster]
where LocationID = (select LocationID from [bluebin].[DimLocation] where LocationKey = @LocationKey)
END
END
GO
grant exec on sp_DeleteBlueBinLocationMaster to appusers
GO
--*****************************************************
--**************************SPROC**********************

if exists (select * from dbo.sysobjects where id = object_id(N'sp_EditBlueBinLocationMaster') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_EditBlueBinLocationMaster
GO

--exec sp_EditBlueBinLocationMaster 'DN000','Testing'
CREATE PROCEDURE sp_EditBlueBinLocationMaster
@LocationKey int,
@LocationID varchar(10),
@LocationName varchar(255)

--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON

update [bluebin].[DimLocation]  
set LocationName=@LocationName
where LocationKey = @LocationKey

END
GO
grant exec on sp_EditBlueBinLocationMaster to appusers
GO



--*****************************************************
--**************************SPROC**********************


if exists (select * from dbo.sysobjects where id = object_id(N'sp_SelectBlueBinItemMasterDetail') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_SelectBlueBinItemMasterDetail
GO

--exec sp_SelectBlueBinItemMaster '2601'
CREATE PROCEDURE sp_SelectBlueBinItemMasterDetail
@ItemKey int

--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON
select 
ItemKey,
[ItemID],
ItemDescription,
ItemClinicalDescription,
ActiveStatus,
ISNULL(ItemManufacturer,'') as ItemManufacturer,
ISNULL(ItemManufacturerNumber,'') as ItemManufacturerNumber,
ISNULL(ItemVendor,'') as ItemVendor,
ISNULL(ItemVendorNumber,'') as ItemVendorNumber,
ISNULL(VendorItemNumber,'') as VendorItemNumber,
LastPODate,
StockUOM,
BuyUOM,
PackageString,
StockLocation
from  [bluebin].[DimItem] 

WHERE ([ItemKey] = @ItemKey)


END
GO
grant exec on sp_SelectBlueBinItemMasterDetail to appusers
GO


--*****************************************************
--**************************SPROC**********************


if exists (select * from dbo.sysobjects where id = object_id(N'sp_SelectBlueBinItemMaster') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_SelectBlueBinItemMaster
GO

--exec sp_SelectBlueBinItemMaster '2601'
CREATE PROCEDURE sp_SelectBlueBinItemMaster
@ItemDescription varchar(255),
@Manufacturer varchar(255)

--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON
select
ItemKey,
[ItemID],
ItemDescription,
ItemClinicalDescription,
ActiveStatus,
ISNULL(ItemManufacturer,'') as Manufacturer,
ISNULL(ItemManufacturerNumber,'') as ManufacturerNo,
ISNULL(ItemVendor,'') as Vendor,
ISNULL(ItemVendorNumber,'') as VendorNo,
ISNULL(VendorItemNumber,'') as VendorItemID,
LastPODate,
StockUOM,
BuyUOM,
PackageString,
StockLocation
from  [bluebin].[DimItem]
WHERE 
	rtrim(ItemManufacturerNumber) +' - ' + rtrim(ItemManufacturer) like '%' + @Manufacturer + '%'
	AND
	rtrim(ItemID) +' - ' + rtrim(ItemDescription) like '%' + @ItemDescription + '%'
OR
	rtrim(ItemManufacturerNumber) +' - ' + rtrim(ItemManufacturer) like '%' + @Manufacturer + '%'
	AND
	rtrim(ItemID) +' - ' + rtrim(ItemClinicalDescription) like '%' + @ItemDescription + '%'
order by ItemID

END
GO
grant exec on sp_SelectBlueBinItemMaster to appusers
GO


--*****************************************************
--**************************SPROC**********************

if exists (select * from dbo.sysobjects where id = object_id(N'sp_InsertBlueBinItemMaster') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_InsertBlueBinItemMaster
GO

--exec sp_InsertBlueBinItemMaster '2601'
CREATE PROCEDURE sp_InsertBlueBinItemMaster
@ItemID varchar(32),
@ItemDescription varchar(255),
@ItemClinicalDescription varchar(255),
@ItemManufacturer char(30),
@ItemManufacturerNumber char(35),
@ItemVendor char(30),
@ItemVendorNumber char(9),
@VendorItemNumber char(32),
@StockUOM char(4)




--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON

if not exists(select * from bluebin.DimItem where ItemID = @ItemID)
BEGIN
set @ItemManufacturerNumber = isnull(@ItemManufacturerNumber,'None')

insert into [bluebin].[DimItem] (ItemKey,ActiveStatus,[ItemID],ItemDescription,ItemDescription2,ItemClinicalDescription,ItemManufacturer,ItemManufacturerNumber,ItemVendor,ItemVendorNumber,VendorItemNumber,StockUOM)

VALUES ((Select max(ItemKey) + 1 from bluebin.DimItem),'A',rtrim(@ItemID),@ItemDescription,@ItemClinicalDescription,@ItemClinicalDescription,@ItemManufacturer,@ItemManufacturerNumber,@ItemVendor,@ItemVendorNumber,@VendorItemNumber,@StockUOM)
END

END
GO
grant exec on sp_InsertBlueBinItemMaster to appusers
GO


--*****************************************************
--**************************SPROC**********************

if exists (select * from dbo.sysobjects where id = object_id(N'sp_DeleteBlueBinItemMaster') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_DeleteBlueBinItemMaster
GO

--exec sp_DeleteBlueBinItemMaster '2601'
CREATE PROCEDURE sp_DeleteBlueBinItemMaster
@ItemKey int

--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON
delete from [bluebin].[DimItem] 

where ItemKey = @ItemKey


END
GO
grant exec on sp_DeleteBlueBinItemMaster to appusers
GO



--*****************************************************
--**************************SPROC**********************


if exists (select * from dbo.sysobjects where id = object_id(N'sp_EditBlueBinItemMaster') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_EditBlueBinItemMaster
GO

--exec sp_EditBlueBinItemMaster '0000001','Test','Test2'
CREATE PROCEDURE sp_EditBlueBinItemMaster
@ItemKey int,
@ItemID varchar(32),
@ItemDescription varchar(255),
@ItemClinicalDescription varchar(255),
@ItemManufacturer char(30),
@ItemManufacturerNumber char(35),
@ItemVendor char(30),
@ItemVendorNumber char(9),
@VendorItemNumber char(32),
@StockUOM char(4),
@ActiveStatus char(1),
@BuyUOM char(4),
@PackageString varchar(38),
@StockLocation char(7)


--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON

update [bluebin].[DimItem] 
set 
ItemDescription = @ItemDescription,
ItemClinicalDescription = @ItemClinicalDescription,
ItemManufacturer = @ItemManufacturer,
ItemManufacturerNumber = @ItemManufacturerNumber,
ItemVendor = @ItemVendor,
ItemVendorNumber = @ItemVendorNumber,
VendorItemNumber = @VendorItemNumber,
StockUOM = @StockUOM,
ActiveStatus = @ActiveStatus,
BuyUOM=@BuyUOM,
PackageString=@PackageString,
StockLocation=@StockLocation

where ItemKey = @ItemKey


END
GO
grant exec on sp_EditBlueBinItemMaster to appusers
GO


--*****************************************************
--**************************SPROC**********************


if exists (select * from dbo.sysobjects where id = object_id(N'sp_SelectBlueBinParMaster') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_SelectBlueBinParMaster
GO

--exec sp_SelectBlueBinParMaster '','','17'
CREATE PROCEDURE sp_SelectBlueBinParMaster
@FacilityName varchar(255)
,@LocationName varchar(255)
,@ItemDescription varchar(255)

--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON


select
bbpm.[ParMasterID],
bbpm.[FacilityID],
bbf.[FacilityName],
rtrim(bbpm.[LocationID]) as LocationID,
ISNULL((rtrim(bblm.[LocationName])),'') as LocationName,
rtrim(bbpm.[ItemID]) as ItemID,
ISNULL((COALESCE(bbim.ItemClinicalDescription,bbim.ItemDescription,'None')),'') as ItemDescription,
bbpm.[BinSequence],
bbpm.[BinSize],
bbpm.[BinUOM],
bbpm.[BinQuantity],
bbpm.[LeadTime],
bbpm.[ItemType],
isnull(bbim.VendorItemNumber,'') as VendorItemNumber,
bbpm.[WHSequence],
bbpm.[PatientCharge],
case when bbpm.[PatientCharge] = 1 then 'Yes' else 'No' end as PatientChargeName,
case when bbpm.[Updated] = '1' then 'Yes' else 'No' end as Updated,
bbpm.[LastUpdated]
from [bluebin].[BlueBinParMaster] bbpm
	inner join [bluebin].[DimItem] bbim on rtrim(bbpm.ItemID) = rtrim(bbim.ItemID)
		inner join [bluebin].[DimLocation] bblm on rtrim(bbpm.LocationID) = rtrim(bblm.LocationID) and bblm.BlueBinFlag = 1
			inner join bluebin.DimFacility bbf on rtrim(bbpm.FacilityID) = rtrim(bbf.FacilityID)
				
				
WHERE 
rtrim(bblm.LocationName) LIKE '%' + @LocationName + '%' 
		and bbf.FacilityName LIKE '%' + @FacilityName + '%' 
			and (rtrim(bbim.ItemID) +' - ' + rtrim(bbim.ItemDescription) like '%' + @ItemDescription + '%'
					OR
						rtrim(bbim.ItemID) +' - ' + rtrim(bbim.ItemClinicalDescription) like '%' + @ItemDescription + '%')
order by LocationID,ItemID

END
GO
grant exec on sp_SelectBlueBinParMaster to appusers
GO

--*****************************************************
--**************************SPROC**********************


if exists (select * from dbo.sysobjects where id = object_id(N'sp_InsertBlueBinParMaster') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_InsertBlueBinParMaster
GO

--exec sp_InsertBlueBinParMaster '','',''
CREATE PROCEDURE sp_InsertBlueBinParMaster
@FacilityID int
,@LocationID varchar(10)
,@ItemID varchar(32)
,@BinSequence varchar(50)
,@BinUOM varchar(10)
,@BinQuantity int
,@LeadTime int
,@ItemType varchar(10)
,@WHSequence varchar(50)
,@PatientCharge int

--& txtFacilityName & "','" & txtLocationName & "','" & txtItemDescription & "','" & txtItemDescription & "','" & txtBinSequence & "','" & txtBinUOM & "','" & txtBinQuantity & "','" & txtLeadTime & "','" & txtItemType & "','" & txtWHLocationID & "','" & txtWHSequence & "','" & txtPatientCharge & "'"
--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON
if not exists(select * from [bluebin].[BlueBinParMaster] WHERE rtrim(LocationID) = rtrim(@LocationID) and rtrim(ItemID) = rtrim(@ItemID) and FacilityID = @FacilityID)
BEGIN

declare @BinSize varchar(5) = right(@BinSequence,3)
insert [bluebin].[BlueBinParMaster] (FacilityID,LocationID,ItemID,BinSequence,BinSize,BinUOM,BinQuantity,LeadTime,ItemType,WHLocationID,WHSequence,PatientCharge,Updated,LastUpdated)
VALUES(
@FacilityID,
@LocationID,
@ItemID,
@BinSequence,
@BinSize,
@BinUOM,
@BinQuantity,
@LeadTime,
@ItemType,
'',
@WHSequence,
@PatientCharge,
0,
getdate()

) 
END


END
GO
grant exec on sp_InsertBlueBinParMaster to appusers
GO

--*****************************************************
--**************************SPROC**********************


if exists (select * from dbo.sysobjects where id = object_id(N'sp_DeleteBlueBinParMaster') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_DeleteBlueBinParMaster
GO

--exec sp_DeleteBlueBinParMaster '','',''
CREATE PROCEDURE sp_DeleteBlueBinParMaster
@ParMasterID int
--@FacilityID int
--,@LocationID varchar(10)
--,@ItemID varchar(32)

--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON
delete from [bluebin].[BlueBinParMaster] 
WHERE ParMasterID = @ParMasterID 
--WHERE rtrim(LocationID) = rtrim(@LocationID)
--	and rtrim(ItemID) = rtrim(@ItemID)
--		and FacilityID = @FacilityID 


END
GO
grant exec on sp_DeleteBlueBinParMaster to appusers
GO

--*****************************************************
--**************************SPROC**********************


if exists (select * from dbo.sysobjects where id = object_id(N'sp_EditBlueBinParMaster') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_EditBlueBinParMaster
GO

--exec sp_EditBlueBinParMaster '','',''
CREATE PROCEDURE sp_EditBlueBinParMaster
@ParMasterID int
,@FacilityID int
,@LocationID varchar(10)
,@ItemID varchar(32)
, @BinSequence varchar(15)
,@BinUOM varchar(10)
,@BinQuantity decimal(13,4)
,@LeadTime int
,@ItemType varchar(20)
,@WHSequence varchar(50)
,@PatientCharge int

--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON
update [bluebin].[BlueBinParMaster] 
set BinSequence = @BinSequence,
	BinSize = right(@BinSequence,3),
	BinUOM = @BinUOM,
	BinQuantity = @BinQuantity,
	LeadTime = @LeadTime,
	ItemType = @ItemType,
	WHSequence = @WHSequence,
	PatientCharge = @PatientCharge,
	LastUpdated = getdate()
	WHERE ParMasterID = @ParMasterID
--WHERE rtrim(LocationID) = rtrim(@LocationID)
--	and rtrim(ItemID) = rtrim(@ItemID)
--		and FacilityID = @FacilityID 
update bluebin.BlueBinParMaster set Updated = 0 FROM
	(select LocationID as L,ItemID as I,BinFacility,BinSequence as BS,BinQty as BQ,BinSize as Size,BinLeadTime from bluebin.DimBin) as db

where 
	rtrim(ItemID) = rtrim(db.I) 
	and rtrim(LocationID) = rtrim(db.L) 
	and FacilityID = db.BinFacility 
	and Updated = 1 
	and (BinSequence <> db.BS OR BinQuantity <> convert(int,db.BQ) OR BinSize <> db.Size OR LeadTime <> db.BinLeadTime)

END
GO
grant exec on sp_EditBlueBinParMaster to appusers
GO

--*****************************************************
--**************************SPROC**********************

if exists (select * from dbo.sysobjects where id = object_id(N'sp_SelectItemIDDescription') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_SelectItemIDDescription
GO

--exec sp_SelectItemIDDescription
CREATE PROCEDURE sp_SelectItemIDDescription



--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON
SELECT 
DISTINCT rtrim([ItemID]) as ItemID,
[ItemDescription],rTrim(ItemID)
	+ ' - ' + 
		COALESCE(ItemDescription,ItemClinicalDescription,'No Description') as ExtendedDescription 
FROM bluebin.[DimItem]
order by ItemID
END
GO
grant exec on sp_SelectItemIDDescription to appusers
GO

--*****************************************************
--**************************SPROC**********************

if exists (select * from dbo.sysobjects where id = object_id(N'sp_SelectTrainingModule') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_SelectTrainingModule
GO


--exec sp_SelectTrainingModule 
CREATE PROCEDURE sp_SelectTrainingModule
@Module varchar (50)


--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON
select 
TrainingModuleID,
ModuleName,
ModuleDescription,
Active,
[Required],
LastUpdated
 from bluebin.TrainingModule
WHERE
ModuleName like '%' + @Module + '%'
and Active = 1
END

GO
grant exec on sp_SelectTrainingModule to appusers
GO


--*****************************************************
--**************************SPROC**********************

if exists (select * from dbo.sysobjects where id = object_id(N'sp_InsertTrainingModule') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_InsertTrainingModule
GO

--exec sp_InsertTrainingModule '',''
--select * from bluebin.TrainingModule

CREATE PROCEDURE sp_InsertTrainingModule 
@ModuleName varchar(50),
@ModuleDescription varchar(255),
@Required int


--WITH ENCRYPTION 
AS
BEGIN
SET NOCOUNT ON

if not exists (select * from bluebin.TrainingModule where ModuleName = @ModuleName)
	BEGIN
	insert into bluebin.TrainingModule (ModuleName,ModuleDescription,[Active],Required,[LastUpdated])
	select 
		@ModuleName,
		@ModuleDescription,
		1, --Default Active to Yes
		@Required,
		getdate()

		END
END
GO

grant exec on sp_InsertTrainingModule to appusers
GO


--*****************************************************
--**************************SPROC**********************

if exists (select * from dbo.sysobjects where id = object_id(N'sp_InsertTrainingModule') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_InsertTrainingModule
GO

--exec sp_InsertTrainingModule '',''
--select * from bluebin.TrainingModule

CREATE PROCEDURE sp_InsertTrainingModule 
@ModuleName varchar(50),
@ModuleDescription varchar(255),
@Required int


--WITH ENCRYPTION 
AS
BEGIN
SET NOCOUNT ON

if not exists (select * from bluebin.TrainingModule where ModuleName = @ModuleName)
	BEGIN
	insert into bluebin.TrainingModule (ModuleName,ModuleDescription,[Active],Required,[LastUpdated])
	select 
		@ModuleName,
		@ModuleDescription,
		1, --Default Active to Yes
		@Required,
		getdate()

		END
END
GO

grant exec on sp_InsertTrainingModule to appusers
GO



--*****************************************************
--**************************SPROC**********************

if exists (select * from dbo.sysobjects where id = object_id(N'sp_DeleteTrainingModule') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_DeleteTrainingModule
GO

CREATE PROCEDURE sp_DeleteTrainingModule
@TrainingModuleID int

--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON
Update [bluebin].[TrainingModule] set [Active] = 0, [LastUpdated] = getdate() where TrainingModuleID = @TrainingModuleID
update bluebin.Training set [Active] = 0, [LastUpdated] = getdate() where TrainingModuleID = @TrainingModuleID
END
GO
grant exec on sp_DeleteTrainingModule to appusers
GO


if exists (select * from dbo.sysobjects where id = object_id(N'sp_EditTrainingModule') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_EditTrainingModule
GO

--exec sp_EditTrainingModule ''
--select * from [bluebin].[TrainingModule]


CREATE PROCEDURE sp_EditTrainingModule
@TrainingModuleID int, 
@ModuleName varchar(50),
@ModuleDescription varchar(255),
@Required int

--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON


update [bluebin].[TrainingModule]
set
ModuleName=@ModuleName,
ModuleDescription=@ModuleDescription,
[Required]=@Required,
LastUpdated = getdate()
where TrainingModuleID = @TrainingModuleID
	;

END
GO

grant exec on sp_EditTrainingModule to appusers
GO

--*****************************************************
--**************************SPROC**********************

if exists (select * from dbo.sysobjects where id = object_id(N'sp_SelectConesDeployed') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_SelectConesDeployed
GO

--exec sp_SelectConesDeployed '',''

CREATE PROCEDURE sp_SelectConesDeployed
@Location varchar(10),
@Item varchar(32)

--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON
	SELECT 
	cd.ConesDeployedID,
	cd.Deployed,
	cd.ExpectedDelivery,
	df.FacilityID,
	df.FacilityName,
	dl.LocationID,
	dl.LocationName,
	di.ItemID,
	di.ItemDescription,
	cd.SubProduct,
	db.BinSequence,
	case when so.ItemID is not null then 'Yes' else 'No' end as DashboardStockout,
	cd.Details as DetailsText,
	case when Details is null or Details = '' then 'No' else 'Yes' end as Details
	
	FROM bluebin.[ConesDeployed] cd
	inner join bluebin.DimFacility df on cd.FacilityID = df.FacilityID
	inner join bluebin.DimLocation dl on cd.LocationID = dl.LocationID
	inner join bluebin.DimItem di on cd.ItemID = di.ItemID
	inner join bluebin.DimBin db on df.FacilityID = db.BinFacility and dl.LocationID = db.LocationID and di.ItemID = db.ItemID
	left outer join (select distinct FacilityID,LocationID,ItemID from tableau.Kanban where StockOut = 1 and [Date] = (select max([Date]) from tableau.Kanban)) so 
		on cd.FacilityID = so.FacilityID and cd.LocationID = so.LocationID and cd.ItemID = so.ItemID
	where cd.Deleted = 0 and cd.ConeReturned = 0
	and
		(dl.LocationName like '%' + @Location + '%' or dl.LocationID like '%' + @Location + '%')
	and 
		(di.ItemID like '%' + @Item + '%' or di.ItemDescription like '%' + @Item + '%')
	order by cd.Deployed desc
	
END
GO
grant exec on sp_SelectConesDeployed to appusers
GO


--*****************************************************
--**************************SPROC**********************

if exists (select * from dbo.sysobjects where id = object_id(N'sp_InsertConesDeployed') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_InsertConesDeployed
GO

--exec sp_InsertConesDeployed '6','BB006','0044100'


CREATE PROCEDURE sp_InsertConesDeployed
@FacilityID int
,@LocationID varchar (10)
,@ItemID varchar (32)
,@ExpectedDelivery datetime
,@SubProduct varchar(3)
,@Details varchar(255)


--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON
select @ExpectedDelivery = case
							when @ExpectedDelivery < getdate() then NULL else @ExpectedDelivery end 

insert into bluebin.ConesDeployed (FacilityID,LocationID,ItemID,ConeDeployed,Deployed,ConeReturned,Deleted,LastUpdated,ExpectedDelivery,SubProduct,Details) VALUES
(@FacilityID,@LocationID,@ItemID,1,getdate(),0,0,getdate(),@ExpectedDelivery,@SubProduct,@Details) 

END


GO
grant exec on sp_InsertConesDeployed to appusers
GO
--*****************************************************
--**************************SPROC**********************


if exists (select * from dbo.sysobjects where id = object_id(N'sp_DeleteConesDeployed') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_DeleteConesDeployed
GO

--exec sp_EditConesDeployed'TEST'

CREATE PROCEDURE sp_DeleteConesDeployed
@ConesDeployedID int


--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON
	Update bluebin.[ConesDeployed] 
	set Deleted = 1, LastUpdated = getdate()
	WHERE [ConesDeployedID] = @ConesDeployedID 

				

END
GO
grant exec on sp_DeleteConesDeployed to appusers
GO


--*****************************************************
--**************************SPROC**********************

if exists (select * from dbo.sysobjects where id = object_id(N'sp_EditConesDeployed') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_EditConesDeployed
GO

--exec sp_EditConesDeployed 


CREATE PROCEDURE sp_EditConesDeployed
@ConesDeployedID int



--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON
	Update bluebin.ConesDeployed set 
	ConeReturned = 1,
	Returned = getdate(),
	LastUpdated = getdate() 
	where ConesDeployedID = @ConesDeployedID

END
GO
grant exec on sp_EditConesDeployed to appusers
GO

--*****************************************************
--**************************SPROC**********************

if exists (select * from dbo.sysobjects where id = object_id(N'sp_SelectConfigType') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_SelectConfigType
GO

--exec sp_SelectConfigType

CREATE PROCEDURE sp_SelectConfigType


--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON
	
	declare @ConfigType Table (ConfigType varchar(50))

	insert into @ConfigType (ConfigType) VALUES
	('Tableau'),
	('Reports'),
	('DMS'),
	('Interface'),
	('Other'),
	('TimeStudy')

	SELECT * from @ConfigType order by 1 asc
	

END
GO
grant exec on sp_SelectConfigType to appusers
GO

--*****************************************************
--**************************SPROC**********************


if exists (select * from dbo.sysobjects where id = object_id(N'sp_SelectScanLocations') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_SelectScanLocations
GO

--exec sp_SelectScanLocations 
CREATE PROCEDURE sp_SelectScanLocations


--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON

SELECT DISTINCT 
convert(varchar(7),dl.LocationID) +' - '+ dl.LocationName as LocationLongName,
sb.LocationID
from scan.ScanBatch sb
inner join bluebin.DimLocation dl on sb.LocationID = dl.LocationID
WHERE Active = 1 --and convert(Date,ScanDateTime) = @ScanDate 
order by sb.LocationID asc

END 
GO
grant exec on sp_SelectScanLocations to public
GO

--*****************************************************
--**************************SPROC**********************



if exists (select * from dbo.sysobjects where id = object_id(N'sp_SelectScanLinesOpen') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_SelectScanLinesOpen
GO

--exec sp_SelectScanLinesOpen '','',''

CREATE PROCEDURE sp_SelectScanLinesOpen
@ScanDate varchar(20),
@Facility varchar(50),
@Location varchar(50)


--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON
select 
sb.ScanBatchID,
db.BinKey,
db.BinSequence,
rtrim(sb.LocationID) as LocationID,
dl.LocationName as LocationName,
sl.ItemID,
di.ItemDescription,
sl.Qty,
sl.Line,
sb.ScanDateTime as [DateScanned],
case when se.ScanLineID is not null then 'Yes' else 'No' end as Extracted,
convert(int,(getdate() - sb.ScanDateTime)) as DaysOpen

from scan.ScanLine sl
inner join scan.ScanBatch sb on sl.ScanBatchID = sb.ScanBatchID
inner join bluebin.DimBin db on sb.LocationID = db.LocationID and sl.ItemID = db.ItemID
inner join bluebin.DimItem di on sl.ItemID = di.ItemID
inner join bluebin.DimLocation dl on sb.LocationID = dl.LocationID
inner join bluebin.DimFacility df on sb.FacilityID = df.FacilityID
left join (select distinct ScanLineID from scan.ScanExtract) se on sl.ScanLineID = se.ScanLineID
where sl.Active = 1 and sb.ScanType like '%Order' 

and sl.ScanLineID not in (select ScanLineOrderID from scan.ScanMatch)
and convert(varchar,(convert(Date,sb.ScanDateTime)),111) LIKE '%' + @ScanDate + '%'  
and sb.FacilityID like '%' + @Facility + '%' 
and sb.LocationID like '%' + @Location + '%'
order by DateScanned,LocationID,Line

END
GO
grant exec on sp_SelectScanLinesOpen to public
GO


--*****************************************************
--**************************SPROC**********************
if exists (select * from dbo.sysobjects where id = object_id(N'sp_SelectUsersShort') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_SelectUsersShort
GO

--exec sp_SelectUsersShort

CREATE PROCEDURE sp_SelectUsersShort



--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON
	SELECT 
	[BlueBinUserID]
      ,[UserLogin]
      ,[FirstName]
      ,[LastName]
      ,[MiddleName]
      ,LastName + ', ' + FirstName as Name
  FROM [bluebin].[BlueBinUser] bbu
  where UserLogin <> ''
  and Active = 1
  order by LastName,[FirstName]

END
GO
grant exec on sp_SelectUsersShort to appusers
GO

--*****************************************************
--**************************SPROC**********************

if exists (select * from dbo.sysobjects where id = object_id(N'sp_SelectResourcesShort') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_SelectResourcesShort
GO

--exec sp_SelectResourcesShort ''

CREATE PROCEDURE sp_SelectResourcesShort
@Title varchar(20)


--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON
	SELECT 
	[BlueBinResourceID]
      ,[FirstName]
      ,[LastName]
      ,[MiddleName]
      ,LastName + ', ' + FirstName as Name
	  ,Title
  FROM [bluebin].[BlueBinResource] bbu
  where 
	Active = 1 and Title like '%' + @Title + '%'
  order by LastName,[FirstName]

END
GO
grant exec on sp_SelectResourcesShort to appusers
GO


--*****************************************************
--**************************SPROC**********************

if exists (select * from dbo.sysobjects where id = object_id(N'sp_SelectConfigDetail') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_SelectConfigDetail
GO

--select * from bluebin.TimeStudyProcess
--exec sp_SelectConfigDetail 'TimeStudy','Double Bin StockOut'

CREATE PROCEDURE sp_SelectConfigDetail
@ConfigType varchar(30),
@ConfigName varchar(30)
--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON

select
ConfigID,
ConfigType,
ConfigName,
ConfigValue,
Description,
LastUpdated

FROM bluebin.Config

where Active = 1 and ConfigType = @ConfigType and ConfigName like '%' + @ConfigName + '%'

END
GO
grant exec on sp_SelectConfigDetail to appusers
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
--exec sp_SelectTimeStudyGroup 

CREATE PROCEDURE sp_SelectTimeStudyGroup
@FacilityName varchar(50)
,@LocationName varchar(50)
,@GroupName varchar(50)

--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON

select
df.FacilityName,
dl.LocationID,
dl.LocationName,
t.GroupName,
t.Active,
t.LastUpdated,
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
	
UPDATE bluebin.[TimeStudyGroup] 
set Active = 0, LastUpdated = getdate()
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




--*****************************************************
--**************************SPROC**********************

--*****************************************************
--**************************SPROC**********************

--*****************************************************
--**************************SPROC**********************

--*****************************************************--*****************************************************--*****************************************************--*****************************************************--*****************************************************
Print 'Main Sproc Add/Updates Complete'

--*****************************************************
--**************************SPROC**********************



if exists (select * from dbo.sysobjects where id = object_id(N'ssp_TableSize') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure ssp_TableSize
GO

--exec ssp_TableSize ''

CREATE PROCEDURE ssp_TableSize
@schema varchar(20)

--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON

--Table Rowcount Query
select 
ss.name as [Schema]
,st.name as [Table]
,ddps.row_count

from sys.tables st
	inner join sys.dm_db_partition_stats ddps on st.object_id = ddps.object_id
	left outer join sys.schemas ss on st.schema_id = ss.schema_id
	where ss.name like '%' + @schema + '%'
order by ss.name,st.name


END
GO
grant exec on ssp_TableSize to public
GO




--*****************************************************
--**************************SPROC**********************


if exists (select * from dbo.sysobjects where id = object_id(N'ssp_Versions') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure ssp_Versions
GO

--exec ssp_Versions

CREATE PROCEDURE ssp_Versions
--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON
DECLARE @DBTable TABLE (iid int identity (1,1) PRIMARY KEY,dbname varchar(50));
DECLARE @DBUpdate TABLE (iid int identity (1,1) PRIMARY KEY,dbname varchar(50));
Create table #Versions (dbname varchar(100),[Version] varchar(100))

declare @iid int, @dbname varchar(50), @sql varchar(max), @sql2 varchar(max)


insert @DBTable (dbname) select name from sys.databases 


set @iid = 1
While @iid <= (select MAX(iid) from @DBTable)
BEGIN
select @dbname = dbname from @DBTable where iid = @iid
set @sql = 'Use ' + @DBName + 

' 
	if exists (select * from sys.tables where name = ''Config'')
	BEGIN
	insert into #versions (dbname,[Version])
	select 
		''' + @dbname + ''',
		ConfigValue as Version
	 from bluebin.Config where ConfigName = ''Version''
	END
'
exec (@sql) 

delete from #Versions where [Version] = ''
set @iid = @iid +1
END


select * from #Versions order by 2 desc
drop table #Versions

END 
GO
grant exec on ssp_Versions to public
GO

--*****************************************************
--**************************SPROC**********************
if exists (select * from dbo.sysobjects where id = object_id(N'ssp_BBSDMSScanning') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure ssp_BBSDMSScanning
GO

--exec ssp_BBSDMSScanning 'Caldwell'

CREATE PROCEDURE ssp_BBSDMSScanning
@DB varchar(10)

--WITH ENCRYPTION
AS
BEGIN


IF Exists (select * from sys.databases where name = @DB)
BEGIN
DECLARE @DBTable Table (Name varchar(20),[id] int)
declare @SQL nvarchar(max)

set @SQL = 'USE ['+@DB+']

DECLARE @Status Table (Client varchar(20),QueryRunDateTime datetime,MaxReqDate datetime,[SourceUpToDate] varchar(3),MaxSnapshotDate datetime,[DBUpToDate] varchar(3))

insert into @Status
select 
	DB_NAME(),
	getdate(),
	convert(date,max(ScanDateTime)) as [MaxReqDate],
	case when convert(date,max(ScanDateTime)) > getdate() -2 then ''YES'' else ''NO'' end,
	db.[MaxSnapshotDate],
	db.[DBUpToDate?]
from scan.ScanLine,
		(select 
		DB_NAME() as Client,
		convert(date,max(LastScannedDate)) as [MaxSnapshotDate],
		case when convert(date,max(LastScannedDate)) > getdate() -2 then ''YES'' else ''NO'' end as [DBUpToDate?]
		from bluebin.FactBinSnapshot
		where LastScannedDate > getdate() -7
		) db 
where ScanDateTime > getdate() -7
group by 	
	db.[MaxSnapshotDate],
	db.[DBUpToDate?]


	select * from @Status

	'

EXEC (@SQL)

END
END
GO
grant exec on ssp_BBSDMSScanning to public
GO

--*****************************************************
--**************************SPROC**********************

if exists (select * from dbo.sysobjects where id = object_id(N'ssp_BBS') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure ssp_BBS
GO

--exec ssp_BBS 'Demo'

CREATE PROCEDURE ssp_BBS
@DB varchar(10)

--WITH ENCRYPTION
AS
BEGIN


IF Exists (select * from sys.databases where name = @DB)
BEGIN
DECLARE @DBTable Table (Name varchar(20),[id] int)
declare @SQL nvarchar(max)

set @SQL = 'USE ['+@DB+']

DECLARE @Status Table (Client varchar(20),QueryRunDateTime datetime,MaxReqDate datetime,[SourceUpToDate] varchar(3),MaxSnapshotDate datetime,[DBUpToDate] varchar(3))

insert into @Status
select 
	DB_NAME(),
	getdate(),
	convert(date,max(CREATION_DATE)) as [MaxReqDate],
	case when convert(date,max(CREATION_DATE)) > getdate() -2 then ''YES'' else ''NO'' end,
	db.[MaxSnapshotDate],
	db.[DBUpToDate?]
from dbo.REQLINE,
		(select 
		DB_NAME() as Client,
		convert(date,max(LastScannedDate)) as [MaxSnapshotDate],
		case when convert(date,max(LastScannedDate)) > getdate() -2 then ''YES'' else ''NO'' end as [DBUpToDate?]
		from bluebin.FactBinSnapshot
		where LastScannedDate > getdate() -7
		) db 
where CREATION_DATE > getdate() -7 and (left(REQ_LOCATION,2) in (select ConfigValue from bluebin.Config where ConfigName = ''REQ_LOCATION'') or REQ_LOCATION in (Select REQ_LOCATION from bluebin.ALT_REQ_LOCATION))
group by 	
	db.[MaxSnapshotDate],
	db.[DBUpToDate?]


	select * from @Status

	'

EXEC (@SQL)

END
END
GO
grant exec on ssp_BBS to public
GO

--*****************************************************
--**************************SPROC**********************

IF EXISTS ( SELECT  *
            FROM    sys.objects
            WHERE   object_id = OBJECT_ID(N'ssp_ReqLookup')
                    AND type IN ( N'P', N'PC' ) ) 

DROP PROCEDURE  ssp_ReqLookup
GO

--exec ssp_ReqLookup '180'
CREATE PROCEDURE ssp_ReqLookup
@ReqNumber varchar(30)
AS

select 'REQLINE',* from REQLINE where REQ_NUMBER = @ReqNumber
select 'ICTRANS',* from ICTRANS where DOCUMENT like '%' + @ReqNumber + '%'
select 'POLINESRC',* from POLINESRC where SOURCE_DOC_N like '%' + @ReqNumber + '%'
select 'POLINE',* from POLINE where PO_NUMBER in (select PO_NUMBER from POLINESRC where SOURCE_DOC_N like '%' + @ReqNumber + '%')
select 'PORECLINE',* from PORECLINE where PO_NUMBER in (select PO_NUMBER from POLINESRC where SOURCE_DOC_N like '%' + @ReqNumber + '%')

select 'FactScan',* from bluebin.FactScan where OrderNum like '%' + @ReqNumber + '%'


GO

grant exec on ssp_ReqLookup to public
GO

--*****************************************************
--**************************SPROC**********************


if exists (select * from dbo.sysobjects where id = object_id(N'sp_CleanLawsonTables') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_CleanLawsonTables
GO

--exec sp_CleanLawsonTables

CREATE PROCEDURE sp_CleanLawsonTables
--WITH ENCRYPTION
AS
BEGIN

if exists (select * from sys.tables where name = 'APCOMPANY')
BEGIN
truncate table dbo.APCOMPANY
END

if exists (select * from sys.tables where name = 'APVENMAST')
BEGIN
truncate table dbo.APVENMAST
END

if exists (select * from sys.tables where name = 'BUYER')
BEGIN
truncate table dbo.BUYER
END

if exists (select * from sys.tables where name = 'GLCHARTDTL')
BEGIN
truncate table dbo.GLCHARTDTL
END

if exists (select * from sys.tables where name = 'GLNAMES')
BEGIN
truncate table dbo.GLNAMES
END

if exists (select * from sys.tables where name = 'GLTRANS')
BEGIN
truncate table dbo.GLTRANS
END

if exists (select * from sys.tables where name = 'ICCATEGORY')
BEGIN
truncate table dbo.ICCATEGORY
END

if exists (select * from sys.tables where name = 'ICMANFCODE')
BEGIN
truncate table dbo.ICMANFCODE
END

if exists (select * from sys.tables where name = 'ICLOCATION')
BEGIN
truncate table dbo.ICLOCATION
END

if exists (select * from sys.tables where name = 'ICTRANS')
BEGIN
truncate table dbo.ICTRANS
END

if exists (select * from sys.tables where name = 'ITEMLOC')
BEGIN
truncate table dbo.ITEMLOC
END

if exists (select * from sys.tables where name = 'ITEMMAST')
BEGIN
truncate table dbo.ITEMMAST
END

if exists (select * from sys.tables where name = 'ITEMSRC')
BEGIN
truncate table dbo.ITEMSRC
END

if exists (select * from sys.tables where name = 'MAINVDTL')
BEGIN
truncate table dbo.MAINVDTL
END

if exists (select * from sys.tables where name = 'MAINVMSG')
BEGIN
truncate table dbo.MAINVMSG
END

if exists (select * from sys.tables where name = 'MMDIST')
BEGIN
truncate table dbo.MMDIST
END

if exists (select * from sys.tables where name = 'POCODE')
BEGIN
truncate table dbo.POCODE
END

if exists (select * from sys.tables where name = 'POLINE')
BEGIN
truncate table dbo.POLINE
END

if exists (select * from sys.tables where name = 'POLINESRC')
BEGIN
truncate table dbo.POLINESRC
END

if exists (select * from sys.tables where name = 'PORECLINE')
BEGIN
truncate table dbo.PORECLINE
END

if exists (select * from sys.tables where name = 'POVAGRMTLN')
BEGIN
truncate table dbo.POVAGRMTLN
END

if exists (select * from sys.tables where name = 'PURCHORDER')
BEGIN
truncate table dbo.PURCHORDER
END

if exists (select * from sys.tables where name = 'REQHEADER')
BEGIN
truncate table dbo.REQHEADER
END

if exists (select * from sys.tables where name = 'REQLINE')
BEGIN
truncate table dbo.REQLINE
END

if exists (select * from sys.tables where name = 'REQUESTER')
BEGIN
truncate table dbo.REQUESTER
END

if exists (select * from sys.tables where name = 'RQLOC')
BEGIN
truncate table dbo.RQLOC
END

if exists (select * from sys.tables where name = 'RQLMXVAL')
BEGIN
truncate table dbo.RQLMXVAL
END

END

GO
grant exec on sp_CleanLawsonTables to public
GO




--*****************************************************
--**************************SPROC**********************


if exists (select * from dbo.sysobjects where id = object_id(N'sp_CleanPeoplesoftTables') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_CleanPeoplesoftTables
GO

--exec sp_CleanPeoplesoftTables

CREATE PROCEDURE sp_CleanPeoplesoftTables
--WITH ENCRYPTION
AS
BEGIN

if exists (select * from sys.tables where name = 'BRAND_NAMES_INV')
BEGIN
truncate table dbo.BRAND_NAMES_INV
END

if exists (select * from sys.tables where name = 'BU_ATTRIB_INV')
BEGIN
truncate table dbo.BU_ATTRIB_INV
END

if exists (select * from sys.tables where name = 'BU_ITEMS_INV')
BEGIN
truncate table dbo.BU_ITEMS_INV
END

if exists (select * from sys.tables where name = 'CART_ATTRIB_INV')
BEGIN
truncate table dbo.CART_ATTRIB_INV
END

if exists (select * from sys.tables where name = 'CART_CF_INF_INV')
BEGIN
truncate table dbo.CART_CF_INF_INV
END

if exists (select * from sys.tables where name = 'DEMAND_INF_INV')
BEGIN
truncate table dbo.DEMAND_INF_INV
END

if exists (select * from sys.tables where name = 'CART_TEMP_INV')
BEGIN
truncate table dbo.CART_TEMP_INV
END

if exists (select * from sys.tables where name = 'IN_DEMAND')
BEGIN
truncate table dbo.IN_DEMAND
END

if exists (select * from sys.tables where name = 'ITEM_MFG')
BEGIN
truncate table dbo.ITEM_MFG
END

if exists (select * from sys.tables where name = 'ITM_VENDOR')
BEGIN
truncate table dbo.ITM_VENDOR
END

if exists (select * from sys.tables where name = 'LOCATION_TBL')
BEGIN
truncate table dbo.LOCATION_TBL
END

if exists (select * from sys.tables where name = 'MANUFACTURER')
BEGIN
truncate table dbo.MANUFACTURER
END

if exists (select * from sys.tables where name = 'MASTER_ITEM_TBL')
BEGIN
truncate table dbo.MASTER_ITEM_TBL
END

if exists (select * from sys.tables where name = 'PO_HDR')
BEGIN
truncate table dbo.PO_HDR
END

if exists (select * from sys.tables where name = 'PO_LINE')
BEGIN
truncate table dbo.PO_LINE
END

if exists (select * from sys.tables where name = 'PO_LINE_DISTRIB')
BEGIN
truncate table dbo.PO_LINE_DISTRIB
END

if exists (select * from sys.tables where name = 'PURCH_ITEM_ATTRIB')
BEGIN
truncate table dbo.PURCH_ITEM_ATTRIB
END

if exists (select * from sys.tables where name = 'PURCH_ITEM_BU')
BEGIN
truncate table dbo.PURCH_ITEM_BU
END

if exists (select * from sys.tables where name = 'RECV_HDR')
BEGIN
truncate table dbo.RECV_HDR
END

if exists (select * from sys.tables where name = 'RECV_LN_DISTRIB')
BEGIN
truncate table dbo.RECV_LN_DISTRIB
END

if exists (select * from sys.tables where name = 'RECV_LN_SHIP')
BEGIN
truncate table dbo.RECV_LN_SHIP
END

if exists (select * from sys.tables where name = 'REQ_HDR')
BEGIN
truncate table dbo.REQ_HDR
END

if exists (select * from sys.tables where name = 'REQ_LINE')
BEGIN
truncate table dbo.REQ_LINE
END

if exists (select * from sys.tables where name = 'REQ_LN_DISTRIB')
BEGIN
truncate table dbo.REQ_LN_DISTRIB
END

if exists (select * from sys.tables where name = 'VENDOR')
BEGIN
truncate table dbo.VENDOR
END



END

GO
grant exec on sp_CleanPeoplesoftTables to public
GO






--*****************************************************
--**************************SPROC**********************

if exists (select * from dbo.sysobjects where id = object_id(N'ssp_CleanLawson') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure ssp_CleanLawson
GO

--exec ssp_Versions

CREATE PROCEDURE ssp_CleanLawson
--WITH ENCRYPTION
AS
BEGIN

truncate table bluebin.DimBin
truncate table bluebin.FactIssue
truncate table bluebin.FactScan
truncate table tableau.Kanban
truncate table tableau.Sourcing
truncate table dbo.APCOMPANY
truncate table dbo.APVENMAST
truncate table dbo.BUYER
truncate table dbo.GLCHARTDTL
truncate table dbo.GLNAMES
truncate table dbo.GLTRANS
truncate table dbo.ICCATEGORY
truncate table dbo.ICMANFCODE
truncate table dbo.ICLOCATION
truncate table dbo.ICTRANS
truncate table dbo.ITEMLOC
truncate table dbo.ITEMMAST
truncate table dbo.ITEMSRC
truncate table dbo.MAINVDTL
truncate table dbo.MAINVMSG
truncate table dbo.MMDIST
truncate table dbo.POCODE
truncate table dbo.POLINE
truncate table dbo.POLINESRC
truncate table dbo.PORECLINE
truncate table dbo.POVAGRMTLN
truncate table dbo.PURCHORDER
truncate table dbo.REQHEADER
truncate table dbo.REQLINE
truncate table dbo.REQUESTER
truncate table dbo.RQLOC

END 
GO
grant exec on ssp_CleanLawson to public
GO


--*****************************************************
--**************************SPROC**********************

if exists (select * from dbo.sysobjects where id = object_id(N'ssp_CleanDB') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure ssp_CleanDB
GO

--exec ssp_Versions

CREATE PROCEDURE ssp_CleanDB
--WITH ENCRYPTION
AS
BEGIN
truncate table bluebin.MasterLog
truncate table bluebin.Image
truncate table gemba.GembaAuditNode

truncate table qcn.QCN
truncate table bluebin.Training
update bluebin.BlueBinResource set Active = 0
delete from bluebin.BlueBinUser where UserLogin not like '%@bluebin.com%'
truncate table bluebin.BlueBinParMaster
truncate table scan.ScanLine
truncate table scan.ScanBatch


truncate table bluebin.DimBin
truncate table bluebin.DimFacility
truncate table bluebin.DimBinStatus
truncate table bluebin.DimDate
truncate table bluebin.DimItem
truncate table bluebin.DimLocation
truncate table bluebin.DimSnapshotDate
truncate table bluebin.FactBinSnapshot
truncate table bluebin.DimWarehouseItem
truncate table bluebin.FactBinSnapshot
truncate table bluebin.FactIssue
truncate table bluebin.FactScan
truncate table bluebin.FactWarehouseSnapshot

truncate table dbo.APCOMPANY
truncate table dbo.APVENMAST
truncate table dbo.BUYER
truncate table dbo.GLCHARTDTL
truncate table dbo.GLNAMES
truncate table dbo.GLTRANS
truncate table dbo.ICCATEGORY
truncate table dbo.ICMANFCODE
truncate table dbo.ICLOCATION
truncate table dbo.ICTRANS
truncate table dbo.ITEMLOC
truncate table dbo.ITEMMAST
truncate table dbo.ITEMSRC
truncate table dbo.MAINVDTL
truncate table dbo.MAINVMSG
truncate table dbo.MMDIST
truncate table dbo.POCODE
truncate table dbo.POLINE
truncate table dbo.POLINESRC
truncate table dbo.PORECLINE
truncate table dbo.POVAGRMTLN
truncate table dbo.PURCHORDER
truncate table dbo.REQHEADER
truncate table dbo.REQLINE
truncate table dbo.REQUESTER
truncate table dbo.RQLOC

truncate table etl.JobHeader
truncate table etl.JobDetails

truncate table tableau.Kanban
truncate table tableau.Contracts
truncate table tableau.Sourcing

update scan.ScanBatch set Active =0
END 
GO
grant exec on ssp_CleanDB to public
GO

--*****************************************************
--**************************SPROC**********************

if exists (select * from dbo.sysobjects where id = object_id(N'ssp_DBInfo') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure ssp_DBInfo
GO

--exec ssp_DBInfo 'dbo'

CREATE PROCEDURE ssp_DBInfo
@schema varchar(20)

--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON

select 
ss.name as [Schema]
,st.name as [Table]
,ddps.row_count

from sys.tables st
	inner join sys.dm_db_partition_stats ddps on st.object_id = ddps.object_id
	left outer join sys.schemas ss on st.schema_id = ss.schema_id
where ss.name like '%' + @schema + '%'
order by ss.name,st.name

--Schema, Table, Column query
select 
ss.name as [Schema]
,st.name as [Table]
,sc.name as [Column]
,stt.name as [Type]
,case
	when sc.is_identity = 1 then 'PK'
	else ''
	end as 'PK'
,sc.max_length
,case
	when sc.is_nullable = 1 then ''
	when sc.is_nullable = 0 then 'NOT NULL'
end as [Null]

from sys.tables st
	left outer join sys.schemas ss on st.schema_id = ss.schema_id
	inner join sys.columns sc on st.object_id = sc.object_id
	inner join sys.types stt on sc.system_type_id = stt.system_type_id

where ss.name like '%' + @schema + '%' --and (sc.Name like '%DATE%' or sc.Name like '%DT%')

order by ss.name,st.name,sc.column_id


END
GO
grant exec on ssp_DBInfo to public
GO



Print 'SSP Sproc Add/Updates Complete'



--*************************************************************************************************************************************************
--Interface Sproc
--*************************************************************************************************************************************************

/*
if exists (select * from dbo.sysobjects where id = object_id(N'xp_RQ500ScanBatchS') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure xp_RQ500ScanBatchS
GO

--exec xp_RQ500ScanBatchS ''

CREATE PROCEDURE xp_RQ500ScanBatchS
@Facility varchar(4)
--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON

--If there is nothing to extract skip to the end
if not exists(select * from scan.ScanLine where Extract = 1) 
BEGIN
GOTO THEEND
END

--Declare all paramters and parameter table
Declare @RQ500User varchar(100), @RQ500FromLoc varchar(5), @RQ500FromComp varchar(5), @RQ500Account varchar(6), @RQ500SubAccount varchar(4), @RQ500AccountCat varchar(5), @RQ500AccountUnit varchar(15)
DECLARE @Batch TABLE (iid int identity (1,1) PRIMARY KEY,ScanBatchID int,FacilityID int,LocationID char(7),RQ500User varchar(100),Extract int,ScanDateTime datetime,RQ500FromLoc varchar(5),RQ500FromComp varchar(4))
declare @iid int, @ScanBatchID int

--Set The REQUESTER for the batch to be a generic value in bluebin.Config if set
select @RQ500User = ConfigValue from bluebin.Config where ConfigName = 'RQ500User'
--Set the From Location for the requisition
select @RQ500FromLoc = ConfigValue from bluebin.Config where ConfigName = 'RQ500FromLoc'
--Set Company that is the source of the items.
select @RQ500FromComp = ConfigValue from bluebin.Config where ConfigName = 'RQ500FromComp'

--Set The Account for the GL for the PO
select @RQ500Account = ConfigValue from bluebin.Config where ConfigName = 'RQ500Account'
--Set the Account Category code (used for reporting on ERP)
select @RQ500AccountCat = ConfigValue from bluebin.Config where ConfigName = 'RQ500AccountCat'
--Set the Posting Account Unit
select @RQ500AccountUnit = ConfigValue from bluebin.Config where ConfigName = 'RQ500AccountUnit'
--Set the Sub Account for the general ledger for the req
select @RQ500SubAccount = ConfigValue from bluebin.Config where ConfigName = 'RQ500SubAccount'


--Create data set of all the Batches that need to be extracted
insert into @Batch (ScanBatchID,FacilityID,LocationID,RQ500User,ScanDateTime,RQ500FromLoc,RQ500FromComp) 
select 
	sb.ScanBatchID,
	sb.FacilityID,
	--sb.LocationID,  --Used for real Sprocs
	REPLACE(sb.LocationID,'BB','DS') as LocationID,--Used for Testing in Demo
	case 
		when bu.ERPUser = '' or bu.ERPUser is null then 
			case when @RQ500User = '' or @RQ500User is null then 'Invalid Requester' else @RQ500User end 
			else bu.ERPUser end
			,
	ScanDateTime,
	@RQ500FromLoc,
	@RQ500FromComp
from scan.ScanBatch sb
	left join bluebin.BlueBinUser bu on sb.BlueBinUserID = bu.BlueBinUserID 
where ScanType like '%Order'
		and sb.ScanBatchID in (select ScanBatchID from scan.ScanLine where Extract = 1)
			and convert(varchar(4),FacilityID) like '%' + @Facility + '%'

;
	
	--Create RQ500 Header out of the ScanBatch
With C as (
	select 
	sb.ScanBatchID,1 as Line,
	left((
	'H'+																		--Record Type 1, 1
	right((REPLICATE('0',4) + rtrim(convert(varchar(4),sb.FacilityID))),4)+		--Company 4, 2-5
	REPLICATE('0',7)+															--Req Number 7, 6-12
	REPLICATE('0',6)+															--LineNumber 6, 13-18
	left(sb.RQ500User+SPACE(10),10)+											--Requester 10, 19-28
	left(sb.LocationID+SPACE(5),5)+												--Req Location 5, 29-33
	convert(varchar, sb.ScanDateTime, 112)+										--Req Delete Date 8, 34-41								
	convert(varchar, sb.ScanDateTime, 112)+										--Creation Date 8, 42-49
	right((REPLICATE('0',4) + rtrim(convert(varchar(4),rtrim(sb.RQ500FromComp)))),4)+--From Company 4, 50-53
	left(sb.RQ500FromLoc+SPACE(5),5)+											--From Location 5, 54-58
	SPACE(76)+																	--76 Spaces, 59-134
	'N'+																		--Print ReqFI  Should we print Req.  Default to N 1, 135
	SPACE(87)+																	--87 Spaces, 136-222
	'01'+																		--Priority 2, 223-224, default it to 01
	SPACE(16)+																	--16 Spaces, 225-240
	left(@RQ500AccountCat+SPACE(5),5)+											--Accounting Category 5, 241-245
	SPACE(32)+																	--32 Spaces, 246-277
	left(@RQ500AccountUnit+SPACE(15),15)+										--Account Unit 15, 278-292
	right((REPLICATE('0',6) + @RQ500Account),6)+								--Account 6, 293-298
	right((REPLICATE('0',4) + @RQ500SubAccount),4)+								--Sub Account 4, 299-302
	SPACE(320)+																	--320 Spaces, 303-622
	'1'+																		--One Source One PO, 1, 623.  default it to 1
	SPACE(115)+																	--115 Spaces, 624-738
	'A'+																		--FUNCTION CODE, 1, 739.  default it to A
	SPACE(503)+																	--503 Spaces, 740-1242
	'00000000'+																	--Default Procedure Date, 8, 1243-1250
	SPACE(382)+																	--382 Spaces, 1251-1632
	'00000000'+																	--Default Birthdate, 8, 1633-1640
	SPACE(2000)																	--Extra Spaces to fill out
	),2000) as Content
	from @Batch sb 
	where sb.RQ500User <> 'Invalid Requester'
	
	UNION

	--Create RQ500 Lines out of the ScanLines
	select 
	sb.ScanBatchID,Line+1 as Line,
	left((
	'L'+																		--Record Type 1, 1
	right((REPLICATE('0',4) + rtrim(convert(varchar(4),sb.FacilityID))),4)+		--Company 4, 2-5
	REPLICATE('0',7)+															--Req Number 7, 6-12 
	right(REPLICATE('0',6)+rtrim(sl.Line),6)+									--LineNumber 6, 13-18
	left(sl.ItemID+SPACE(32),32)+												--Item 32, 19-50
	SPACE(1)+																	--ItemType 1, 51
	SPACE(1)+																	--ServiceCode 1, 52
	SPACE(30)+																	--Service Code Description 30, 53-82
	right(REPLICATE('0',9)+rtrim(sl.Qty),9)+REPLICATE('0',4)+					--Quantity decimal 9,4, overall 13, 83-95
	left(di.StockUOM+SPACE(4),4)+												--Entered UOM 4, 96-99
	REPLICATE('0',18)+															--Transaction Cost, 100-117
	SPACE(56)+																	--Space for Override Cst, 56, 118-173Create PO,Agreement,Vendor,VendorLocation,Purchase Classes,Buyer
	right((REPLICATE('0',4) + rtrim(convert(varchar(4),rtrim(sb.RQ500FromComp)))),4)+		--From Company 4, 174-177
	left(sb.RQ500FromLoc+SPACE(5),5)+												--From Location 5, 178-182
	left(sb.LocationID+SPACE(5),5)+												--Req Location 5, 183-187
	convert(varchar, sb.ScanDateTime, 112)+										--Req Delivery Date 8, 188-195
	convert(varchar, sb.ScanDateTime+1, 112)+									--Late Delivery Date 8, 196-203
	SPACE(8)+																	--Creation Date 8, 204-211
	--convert(varchar, sb.ScanDateTime, 112)+									--Creation Date 8, 204-211
	SPACE(89)+																	--Spaces 89, 212-300
	'01'+																		--Priority 2, 301-302, default it to 01
	SPACE(80)+																	--80 Spaces, 303-382
	left(@RQ500AccountUnit+SPACE(15),15)+										--Account Unit 15, 383-397
	right((REPLICATE('0',6) + @RQ500Account),6)+								--Account 6, 398-403
	right((REPLICATE('0',4) + @RQ500SubAccount),4)+								--Sub Account 4, 404-407
	SPACE(103)+																	--Spaces 103, 408-510
	right((REPLICATE('0',4) + rtrim(convert(varchar(4),rtrim(sb.RQ500FromComp)))),4)+--Distribution (From) Company 4, 511-514
	SPACE(15)+																	--Spaces 15, 515-529
	left(@RQ500AccountCat+SPACE(5),5)+											--Accounting Category 5, 530-534
	SPACE(42)+																	--Spaces 42, 535-576
	'0000000000'+																--Asset Number 10, 577-586 default all zeroes
	SPACE(27)+																	--Spaces 27,587-613
	'0'+																		--Strategic Sourcing Event 1, 614. default to 0
	SPACE(2000)																	--Extra Spaces to fill out	
	),2000) as Content
	from @Batch sb
	inner join scan.ScanLine sl on sb.ScanBatchID = sl.ScanBatchID
	inner join bluebin.DimItem di on sl.ItemID = di.ItemID
	where sl.Extract = 1 and sb.RQ500User <> 'Invalid Requester' and sl.Line <> 0 
	
	) 
	select Content from C order by ScanBatchID,Line
	;
	update scan.ScanBatch set Extract = 0 where ScanBatchID in (select ScanBatchID from @Batch where RQ500User <> 'Invalid Requester')
	update scan.ScanLine set Extract = 0 where ScanBatchID  in (select ScanBatchID from @Batch where RQ500User <> 'Invalid Requester')
THEEND:

/*
select * from scan.ScanBatch
select * from scan.ScanLine
select * from bluebin.DimLocation
update scan.ScanBatch set Extract = 1 where ScanBatchID in (10,11,12)
update scan.ScanLine set Extract = 1 where ScanBatchID in (10,11,12)
exec xp_RQ500ScanBatchS ''
declare @ScanBatchID int 
select @ScanBatchID = min(ScanBatchID) from scan.ScanBatch where Active = 1 and Extract = 1
*/

END
GO

grant exec on xp_RQ500ScanBatchS to BlueBin_RQ500User
GO
*/

Print 'Interface Sproc Updates Complete'

--*************************************************************************************************************************************
--*************************************************************************************************************************************

--Key and Constraint Updates

--*************************************************************************************************************************************
--*************************************************************************************************************************************


Print 'Keys and Constraints Complete'



--*************************************************************************************************************************************
--*************************************************************************************************************************************

--General Cleanup

--*************************************************************************************************************************************
--*************************************************************************************************************************************

if not exists (select * from sys.indexes where name = 'DimItemIndex')
BEGIN
CREATE INDEX DimItemIndex ON bluebin.DimItem (ItemKey,ItemID)
END
GO
if not exists (select * from sys.indexes where name = 'DimLocationIndex')
BEGIN
CREATE INDEX DimLocationIndex ON bluebin.DimLocation (LocationKey,LocationID)
END
GO
if not exists (select * from sys.indexes where name = 'ParMasterIndex')
BEGIN
	if exists (select * from sys.tables where name = 'BlueBinParMaster')
	BEGIN
	CREATE INDEX ParMasterIndex ON bluebin.BlueBinParMaster (LocationID,ItemID)
	END
END
GO


Print 'General Cleanup Complete'


--*************************************************************************************************************************************
--*************************************************************************************************************************************

--Job Updates

--*************************************************************************************************************************************
--*************************************************************************************************************************************



Print 'Job Updates Complete'





--*************************************************************************************************************************************
--*************************************************************************************************************************************

--Version Updates

--*************************************************************************************************************************************
--*************************************************************************************************************************************



declare @version varchar(50) = '2.4.20161014' --Update Version Number here


if not exists (select * from bluebin.Config where ConfigName = 'Version')
BEGIN
insert into bluebin.Config (ConfigName,ConfigValue,ConfigType,Active,LastUpdated) VALUES ('Version',@version,'DMS',1,getdate())
END
ELSE
Update bluebin.Config set ConfigValue = @version where ConfigName = 'Version'

Print 'Version Updated to ' + @version
Print 'DB: ' + DB_NAME() + ' updated'
GO
