
/****** Object:  QCN Tables    Script Date: 10/2/2015 8:34:27 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

if not exists (select * from sys.tables where name = 'QCN')
BEGIN
CREATE TABLE [qcn].[QCN](
	[QCNID] INT NOT NULL IDENTITY(1,1)  PRIMARY KEY,
	[LocationID] varchar(10) not null,
	[ItemID] char(32) null,
	[RequesterUserID] varchar(65) NOT NULL,
	[ApprovedUserID] varchar(65) NULL,
	[LoggedUserID] int NOT NULL,
	[AssignedUserID] int NULL,
	[QCNTypeID] int NOT NULL,
	[Details] varchar(max) NULL,
	[Updates] varchar(max) NULL,
	[InternalReference] varchar(50) NULL,
	[DateRequested] datetime not null
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

--ALTER TABLE [qcn].[QCNRequest] WITH CHECK ADD FOREIGN KEY([LocationID])
--REFERENCES [bluebin].[DimBin] ([LocationID])

--ALTER TABLE [qcn].[QCNRequest] WITH CHECK ADD FOREIGN KEY([ItemID])
--REFERENCES [bluebin].[DimBin] ([ItemID])








