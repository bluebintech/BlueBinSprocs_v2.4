BEGIN TRY
DROP TABLE DimBinStatus
END TRY

BEGIN CATCH
END CATCH
GO

CREATE TABLE [dbo].[DimBinStatus](
	[BinStatusKey] [int] NULL,
	[BinStatus] [varchar](50) NULL
) ON [PRIMARY]

GO



INSERT INTO dbo.DimBinStatus (	BinStatusKey,	BinStatus	) VALUES( 1, 'Healthy')
INSERT INTO dbo.DimBinStatus (	BinStatusKey,	BinStatus	) VALUES( 2, 'Hot')
INSERT INTO dbo.DimBinStatus (	BinStatusKey,	BinStatus	) VALUES( 3, 'Very Hot' )
INSERT INTO dbo.DimBinStatus (	BinStatusKey,	BinStatus	) VALUES( 4, 'Extremely Hot' )
INSERT INTO dbo.DimBinStatus (	BinStatusKey,	BinStatus	) VALUES( 5, 'Slow' )
INSERT INTO dbo.DimBinStatus (	BinStatusKey,	BinStatus	) VALUES( 6, 'Stale')
INSERT INTO dbo.DimBinStatus (	BinStatusKey,	BinStatus	) VALUES( 7, 'Never Scanned')