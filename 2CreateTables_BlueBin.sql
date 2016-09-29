

/****** Object:  Table [bluebin].[BlueBinUser]    Script Date: 10/2/2015 8:34:27 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO


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


if not exists (select * from sys.tables where name = 'Walkthrough')
BEGIN
CREATE TABLE [bluebin].[Walkthrough](
	[WalkthroughID] INT NOT NULL IDENTITY(1,1)  PRIMARY KEY,
	Client varchar(100) NULL,
	Building varchar(100) NULL,
	RoomName varchar(100) NULL,
	RoomNumber varchar(50) NULL,
	Rack int NULL,
	Weeks int NULL,
	ImageID int NULL,
	Other varchar(max) NULL
	
)


END
GO

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
	LastUpdated datetime not null,
	ExpectedDelivery datetime null,
	SubProduct varchar(3) not null,
	Details varchar(255) null
	
)

END
GO



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
('ADMIN-PARMASTER',0,'DMS',1,getdate(),''),
('GembaShadowTitle','Tech','DMS',1,getdate(),'BlueBin Resource Title that is available in Shadowed User section of Gemba Audit'),
('GembaShadowTitle','Strider','DMS',1,getdate(),'BlueBin Resource Title that is available in Shadowed User section of Gemba Audit'),
('ReportDateStart','-90','Tableau',1,getdate(),'This value is how many days back to start the analytics for something like the Kanban table'),
('SlowBinDays','90','Tableau',1,getdate(),'This is a configuarble value for how many days you want to configure for a bin to be slow.  Default is 90'),
('StaleBinDays','180','Tableau',1,getdate(),'This is a configuarble value for how many days you want to configure for a bin to be stale.  Default is 180')
	

END
GO


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


if not exists (select * from sys.tables where name = 'BlueBinUser')
BEGIN
CREATE TABLE [bluebin].[BlueBinUser](
	[BlueBinUserID] INT NOT NULL IDENTITY(1,1)  PRIMARY KEY,
	[UserLogin] varchar (60) NOT NULL,
	[FirstName] varchar (30) NOT NULL,
	[LastName] varchar (30) NOT NULL,
	[MiddleName] varchar (30) NULL,
	[Title] varchar (50) NULL,
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
	AssignToQCN int
)

ALTER TABLE [bluebin].[MasterLog] WITH CHECK ADD FOREIGN KEY([BlueBinUserID])
REFERENCES [bluebin].[BlueBinUser] ([BlueBinUserID])

ALTER TABLE [bluebin].[BlueBinUser] ADD CONSTRAINT U_Login UNIQUE(UserLogin)

END
GO


if not exists (select * from sys.tables where name = 'BlueBinOperations')
BEGIN
CREATE TABLE [bluebin].[BlueBinOperations](
	[OpID] INT NOT NULL IDENTITY(1,1)  PRIMARY KEY,
	[OpName] varchar (50) NOT NULL,
	[Description] varchar (255) NULL
)

Insert into bluebin.BlueBinOperations (OpName,[Description]) VALUES
('ADMIN-PARMASTER','Give User ability to see Custom BlueBin Par Master'),
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
--DROP TABLE [bluebin].[Image]
--select * from  [bluebin].[Image]


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
('OP-Pick Line Volume','1',1,getdate(),'Reports','Setting for whether to display the Pick Line Volume Report'),
('OP-Supply Spend','1',1,getdate(),'Reports','Setting for whether to display the Supply Spend Report'),
('OP-Overall Line Volume','1',1,getdate(),'Reports','Setting for whether to display the Overall Line Volume Report'),
('OP-Kanbans Adjusted','1',1,getdate(),'Reports','Setting for whether to display the Kanbans Adjusted Report'),
('OP-Stat Calls','1',1,getdate(),'Reports','Setting for whether to display the Stat Calls Report'),
('OP-Warehouse Detail','1',1,getdate(),'Reports','Setting for whether to display the Warehouse Size Report'),
('OP-Warehouse Volume','1',1,getdate(),'Reports','Setting for whether to display the Warehouse Value Report'),
('OP-Huddle Board','1',1,getdate(),'Reports','Setting for whether to display the Huddle Board Report'),
('OP-QCN Dashboard','1',1,getdate(),'Reports','Setting for whether to display the QCN DB'),
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

SET ANSI_PADDING OFF
GO



