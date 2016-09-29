

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

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
	[ScanDateTime] datetime not null,
	[ScanType] varchar(50) not null
)
END
GO


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

