/*
drop table [bluebin].[TimeStudyStageScan]
drop table [bluebin].[TimeStudyStockOut]
drop table [bluebin].[TimeStudyNodeService]
drop table [bluebin].[TimeStudyBinFill]
drop table [bluebin].[TimeStudyGroup]
*/

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
	[BlueBinResourceID] int NOT NULL,
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
	[BlueBinResourceID] int NOT NULL,
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
	[LocationID] varchar(10) NOT NULL,	
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
	[BlueBinResourceID] int NOT NULL,
	[MostRecent] int NOT NULL,
	[Active] int NOT NULL,
	[LastUpdated] datetime NOT NULL
)


END
GO

/****** Object:  Table [bluebin].[TimeStudyProcess]     ******/
if not exists (select * from sys.tables where name = 'TimeStudyProcess')
BEGIN
CREATE TABLE [bluebin].[TimeStudyProcess](
	[TimeStudyProcessID] INT NOT NULL IDENTITY(1,1)  PRIMARY KEY,
	[ProcessType] varchar (100) NOT NULL,
	[ProcessName] varchar (100) NOT NULL,
	[ProcessValue] varchar (100) NULL,
	[Description] varchar(255) NULL,
	[Active] int NOT NULL,
	[LastUpdated] datetime NOT NULL
)


END
GO



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
