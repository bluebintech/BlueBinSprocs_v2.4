

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
	[FacilityID] int NOT NULL,
	[LocationID] varchar(10) NOT NULL,
	[BlueBinUserID] int NULL,
	[LastUpdated] datetime NOT NULL
)
END
GO


/****** Object:  Table [bluebin].[TimeStudyStockOut]     ******/
if not exists (select * from sys.tables where name = 'TimeStudyStockOut')
BEGIN
CREATE TABLE [bluebin].[TimeStudyStockOut](
	[TimeStudyStockOutID] INT NOT NULL IDENTITY(1,1)  PRIMARY KEY,
	[FacilityID] int NOT NULL,
	[LocationID] varchar(10) NOT NULL,
	[BlueBinUserID] int NULL,
    [LastUpdated] datetime NOT NULL
)


END
GO

/****** Object:  Table [bluebin].[TimeStudyNodeService]     ******/
if not exists (select * from sys.tables where name = 'TimeStudyNodeService')
BEGIN
CREATE TABLE [bluebin].[TimeStudyNodeService](
	[TimeStudyNodeServiceID] INT NOT NULL IDENTITY(1,1)  PRIMARY KEY,
	[FacilityID] int NOT NULL,
	[LocationID] varchar(10) NOT NULL,
	[BlueBinUserID] int NULL,
	[LastUpdated] datetime NOT NULL
)


END
GO

/****** Object:  Table [bluebin].[TimeStudyBinFill]     ******/
if not exists (select * from sys.tables where name = 'TimeStudyBinFill')
BEGIN
CREATE TABLE [bluebin].[TimeStudyBinFill](
	[TimeStudyBinFillID] INT NOT NULL IDENTITY(1,1)  PRIMARY KEY,
	[FacilityID] int NOT NULL,
	[LocationID] varchar(10) NOT NULL,
	[BlueBinUserID] int NULL,
	[LastUpdated] datetime NOT NULL
)


END
GO

