/*
--*************************
PEOPLSOFT SPECIFIC UPGRADE SCRIPTS
--*************************

Upgrade Script to copy in the etl_ and tb_ sprocs used in both the daily etl and to populate data sources in the Tableau WOrkbooks
20160927 - Updated by Gery Butler

*/




SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

SET NOCOUNT ON
GO

/*********************************************************************
--tableau schema
*********************************************************************/
if not exists (select * from sys.schemas where name = 'tableau')
BEGIN
EXEC sp_executesql N'Create SCHEMA tableau AUTHORIZATION  dbo'
Print 'Schema tableau created'
END
GO

/*********************************************************************
--etl schema
*********************************************************************/
if not exists (select * from sys.schemas where name = 'etl')
BEGIN
EXEC sp_executesql N'Create SCHEMA etl AUTHORIZATION  dbo'
Print 'Schema etl created'
END
GO


/*********************************************************************
--Dim and Fact Tables
*********************************************************************/
if not exists (select * from sys.tables where name = 'DimItem')
BEGIN
CREATE TABLE [bluebin].[DimItem](
	[ItemKey] [bigint] NULL,
	[ItemID] [char](32) NOT NULL,
	[ItemDescription] [char](30) NOT NULL,
	[ItemDescription2] [char](30) NOT NULL,
	[ItemClinicalDescription] [char](30) NULL,
	[ActiveStatus] [char](1) NOT NULL,
	[ItemManufacturer] [char](30) NULL,
	[ItemManufacturerNumber] [char](35) NOT NULL,
	[ItemVendor] [char](30) NULL,
	[ItemVendorNumber] [char](9) NULL,
	[LastPODate] [datetime] NULL,
	[StockLocation] [varchar](50) NULL,
	[VendorItemNumber] [char](32) NULL,
	[StockUOM] [char](4) NOT NULL,
	[BuyUOM] [char](4) NULL,
	[PackageString] [varchar](38) NULL
) ON [PRIMARY]
END





/*********************************************************************
--etl tables
*********************************************************************/


/****** Object:  Table [etl].[JobHeader]    Script Date: 12/11/2015 2:43:36 PM ******/
if not exists (select * from sys.tables where name = 'JobHeader')
BEGIN
CREATE TABLE [etl].[JobHeader](
	[ProcessID] [int] NULL,
	[StartTime] [datetime] NULL,
	[EndTime] [datetime] NULL,
	[Duration]  AS ((((right('0'+CONVERT([varchar],datediff(hour,[StartTime],[EndTime]),(0)),(2))+':')+right('0'+CONVERT([varchar],datediff(minute,[StartTime],[EndTime]),(0)),(2)))+':')+right('0'+CONVERT([varchar],datediff(second,[StartTime],[EndTime])%(60),(0)),(2))),
	[Result] [varchar](50) NULL
) ON [PRIMARY]
END

GO

/****** Object:  Table [etl].[JobDetails]    Script Date: 12/11/2015 2:43:36 PM ******/
if not exists (select * from sys.tables where name = 'JobDetails')
BEGIN
CREATE TABLE [etl].[JobDetails](
	[ProcessID] [int] NULL,
	[StepName] [varchar](50) NULL,
	[StartTime] [datetime] NULL,
	[EndTime] [datetime] NULL,
	[Duration]  AS ((((right('0'+CONVERT([varchar],datediff(hour,[StartTime],isnull([EndTime],getdate())),(0)),(2))+':')+right('0'+CONVERT([varchar],round(datediff(second,[StartTime],isnull([EndTime],getdate()))/(60),(0)),(0)),(2)))+':')+right('0'+CONVERT([varchar],datediff(second,[StartTime],isnull([EndTime],getdate()))%(60),(0)),(2))),
	[RowCount] [int] NULL,
	[Result] [varchar](50) NULL,
	[Message] [varchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
END

if not exists(select * from sys.columns where name = 'Message' and object_id = (select object_id from sys.tables where name = 'JobDetails'))
BEGIN
ALTER TABLE [etl].[JobDetails] ADD [Message] varchar(max);
END
GO



/****** Object:  Table [etl].[JobSteps]    Script Date: 12/11/2015 2:43:36 PM ******/
if not exists (select * from sys.tables where name = 'JobSteps')
BEGIN

CREATE TABLE [etl].[JobSteps](
	[StepNumber] [int] NOT NULL,
	[StepName] [varchar](255) NOT NULL,
	[StepProcedure] [varchar](255) NOT NULL,
	[StepTable] [varchar](255) NULL,
	[ActiveFlag] [int] NOT NULL,
	[LastModifiedDate] [datetime] NULL
) ON [PRIMARY]
;  
insert into etl.JobSteps (StepNumber,StepName,StepProcedure,StepTable,ActiveFlag,LastModifiedDate) VALUES

('1','DimItem','etl_DimItem','bluebin.DimItem',0,getdate()),
('2','DimLocation','etl_DimLocation','bluebin.DimLocation',0,getdate()),
('3','DimDate','etl_DimDate','bluebin.DimDate',0,getdate()),
('4','DimBinStatus','etl_DimBinStatus','bluebin.DimBinStatus',0,getdate()),
('5','DimBin','etl_DimBin','bluebin.DimBin',0,getdate()),
('6','FactScan','etl_FactScan','bluebin.FactScan',0,getdate()),
('7','FactBinSnapshot','etl_FactBinSnapshot','bluebin.FactBinSnapshot',0,getdate()),
('8','Update Bin Status','etl_UpdateBinStatus','bluebin.DimBin',0,getdate()),
('9','FactIssue','etl_FactIssue','bluebin.FactIssue',0,getdate()),
('10','FactWarehouseSnapshot','etl_FactWarehouseSnapshot','bluebin.FactWarehouseSnapshot',0,getdate()),
('11','Kanban','tb_Kanban','tableau.Kanban',0,getdate()),
('12','Sourcing','tb_Sourcing','tableau.Sourcing',0,getdate()),
('13','Contracts','tb_Contracts','tableau.Contracts',0,getdate()),
('14','Warehouse Item','etl_DimWarehouseItem','bluebin.DimWarehouseItem',0,getdate()),
('15','DimFacility','etl_DimFacility','bluebin.DimFacility',0,getdate()),
('16','BlueBinParMaster','etl_BlueBinParMaster','bluebin.BlueBinParMaster',0,getdate()),
('17','DimBinHistory','etl_DimBinHistory','bluebin.DimBinHistory',0,getdate()),
('18','FactWHHistory','etl_FactWHHistory','bluebin.FactWHHistory',0,getdate())
END
GO


if not exists (select * from sys.tables where name = 'JobHeader')
BEGIN

CREATE TABLE [etl].[JobHeader](
	[ProcessID] [int] NULL,
	[StartTime] [datetime] NULL,
	[EndTime] [datetime] NULL,
	[Duration]  AS ((((right('0'+CONVERT([varchar],datediff(hour,[StartTime],[EndTime]),(0)),(2))+':')+right('0'+CONVERT([varchar],datediff(minute,[StartTime],[EndTime]),(0)),(2)))+':')+right('0'+CONVERT([varchar],datediff(second,[StartTime],[EndTime])%(60),(0)),(2))),
	[Result] [varchar](50) NULL
) ON [PRIMARY]

END
GO


if not exists (select * from sys.tables where name = 'JobDetails')
BEGIN

CREATE TABLE [etl].[JobDetails](
	[ProcessID] [int] NULL,
	[StepName] [varchar](50) NULL,
	[StartTime] [datetime] NULL,
	[EndTime] [datetime] NULL,
	[Duration]  AS ((((right('0'+CONVERT([varchar],datediff(hour,[StartTime],isnull([EndTime],getdate())),(0)),(2))+':')+right('0'+CONVERT([varchar],round(datediff(second,[StartTime],isnull([EndTime],getdate()))/(60),(0)),(0)),(2)))+':')+right('0'+CONVERT([varchar],datediff(second,[StartTime],isnull([EndTime],getdate()))%(60),(0)),(2))),
	[RowCount] [int] NULL,
	[Result] [varchar](50) NULL,
	[Message] [varchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
END
GO

/****** Object:  Table [bluebin].[DimFacility]    Script Date: 12/11/2015 2:43:36 PM ******/
if not exists (select * from sys.tables where name = 'DimFacility')
BEGIN
CREATE TABLE [bluebin].[DimFacility](
	[FacilityID] smallint NOT NULL,
	[FacilityName] varchar (255) NOT NULL
) 
END
GO


/****** Object:  Table [bluebin].[DimWarehouseItem]    Script Date: 12/11/2015 2:43:36 PM ******/
if not exists (select * from sys.tables where name = 'DimWarehouseItem')
BEGIN
CREATE TABLE [bluebin].[DimWarehouseItem](
	[LocationID] [varchar](10) NULL,
	[LocationName] [char](30) NULL,
	[ItemKey] [bigint] NULL,
	[ItemID] [char](32) NOT NULL,
	[ItemDescription] [char](30) NOT NULL,
	[ItemClinicalDescription] [char](30) NULL,
	[ItemManufacturer] [char](30) NULL,
	[ItemManufacturerNumber] [char](35) NOT NULL,
	[ItemVendor] [char](30) NULL,
	[ItemVendorNumber] [char](9) NULL,
	[StockLocation] [char](10) NOT NULL,
	[SOHQty] [decimal](13, 4) NOT NULL,
	[ReorderQty] [decimal](13, 4) NOT NULL,
	[ReorderPoint] [decimal](13, 4) NOT NULL,
	[UnitCost] [decimal](18, 5) NOT NULL,
	[StockUOM] [char](4) NOT NULL,
	[BuyUOM] [char](4) NULL,
	[PackageString] [varchar](38) NULL
) ON [PRIMARY]
END
GO

SET ANSI_PADDING OFF
GO


Print 'Tables Updated'
GO

/*********************************************************************
--etl sprocs
*********************************************************************/





--/******************************************

--			DimItem

--******************************************/

IF EXISTS ( SELECT  *
            FROM    sys.objects
            WHERE   object_id = OBJECT_ID(N'etl_DimItem')
                    AND type IN ( N'P', N'PC' ) ) 

DROP PROCEDURE  etl_DimItem
GO

--exec etl_DimItem
CREATE PROCEDURE etl_DimItem

AS

/**************		SET BUSINESS RULES		***************/




/**************		DROP DimItem			***************/

BEGIN Try
    DROP TABLE bluebin.DimItem
END Try

BEGIN Catch
END Catch



/*********************		CREATE DimItem		**************************************/
Declare @UseClinicalDescription int
select @UseClinicalDescription = ConfigValue from bluebin.Config where ConfigName = 'UseClinicalDescription'         
		
SELECT Row_number()
         OVER(
           ORDER BY a.INV_ITEM_ID) AS ItemKey,
       a.INV_ITEM_ID               AS ItemID,
       DESCR                       AS ItemDescription,
	   ''							AS ItemDescription2,--****
	   DESCR                       AS ItemClinicalDescription,--****
	   'A'							AS ActiveStatus,--****
       b.MFG_ID                    AS ItemManufacturer,
       b.MFG_ITM_ID                AS ItemManufacturerNumber,
       d.NAME1                     AS ItemVendor,
       c.ITM_ID_VNDR               AS ItemVendorNumber,
	   
	   ''							AS LastPODate,--****
       ''							AS StockLocation,--****
       ''							AS VendorItemNumber,--****
	   UNIT_MEASURE_STD			   AS StockUOM,
       UNIT_MEASURE_STD            AS BuyUOM,
       ''							AS PackageString--****
INTO   bluebin.DimItem
FROM   dbo.MASTER_ITEM_TBL a
       LEFT JOIN dbo.ITEM_MFG b
              ON a.INV_ITEM_ID COLLATE DATABASE_DEFAULT = b.INV_ITEM_ID
                 AND b.PREFERRED_MFG = 'Y'
       LEFT JOIN dbo.ITM_VENDOR c
              ON a.INV_ITEM_ID COLLATE DATABASE_DEFAULT = c.INV_ITEM_ID
                 AND c.ITM_VNDR_PRIORITY = 1
       LEFT JOIN dbo.VENDOR d
              ON c.VENDOR_ID COLLATE DATABASE_DEFAULT = d.VENDOR_ID 
GO
--exec etl_DimItem


UPDATE etl.JobSteps
SET LastModifiedDate = GETDATE()
WHERE StepName = 'DimItem'
GO





/********************************************************************

					DimLocation

********************************************************************/

IF EXISTS ( SELECT  *
            FROM    sys.objects
            WHERE   object_id = OBJECT_ID(N'etl_DimLocation')
                    AND type IN ( N'P', N'PC' ) ) 

DROP PROCEDURE  etl_DimLocation
GO
--exec etl_DimLocation
--select * from bluebin.DimLocation where BlueBinFlag = 1

CREATE PROCEDURE etl_DimLocation
AS

/********************		DROP DimLocation	***************************/
  BEGIN TRY
      DROP TABLE bluebin.DimLocation
  END TRY

  BEGIN CATCH
  END CATCH

/*********************		CREATE DimLocation	****************************/
   declare @Facility int
   select @Facility = ConfigValue from bluebin.Config where ConfigName = 'PS_DefaultFacility'
   
   
   SELECT Row_number()
         OVER(
           ORDER BY a.LOCATION) AS LocationKey,
       a.LOCATION            AS LocationID,
       UPPER(DESCR)          AS LocationName,
	   case when @Facility is not null or @Facility <> '' then @Facility else df.FacilityID	end AS LocationFacility,
		CASE
             WHEN a.EFF_STATUS = 'A' and (
											LEFT(a.LOCATION, 2) COLLATE DATABASE_DEFAULT IN (SELECT [ConfigValue] 
                                            FROM   [bluebin].[Config]
                                            WHERE  [ConfigName] = 'REQ_LOCATION'
                                                   AND Active = 1) 
										or a.LOCATION COLLATE DATABASE_DEFAULT in (Select REQ_LOCATION from bluebin.ALT_REQ_LOCATION)
											)		   
												   
										THEN 1
             ELSE 0
           END                        AS BlueBinFlag,
		   a.EFF_STATUS as ACTIVE_STATUS
INTO bluebin.DimLocation
FROM   dbo.LOCATION_TBL a 
INNER JOIN (SELECT LOCATION, MIN(EFFDT) AS EFFDT FROM dbo.LOCATION_TBL GROUP BY LOCATION) b ON a.LOCATION  = b.LOCATION AND a.EFFDT = b.EFFDT 
LEFT JOIN bluebin.DimFacility df on a.SETID COLLATE DATABASE_DEFAULT = df.FacilityName

WHERE  a.EFF_STATUS = 'A'

GO

UPDATE etl.JobSteps
SET LastModifiedDate = GETDATE()
WHERE StepName = 'DimLocation'
GO


/***********************************************************

			DimDate

***********************************************************/


IF EXISTS ( SELECT  *
            FROM    sys.objects
            WHERE   object_id = OBJECT_ID(N'etl_DimDate')
                    AND type IN ( N'P', N'PC' ) ) 

DROP PROCEDURE  etl_DimDate
GO
--exec etl_DimDate
CREATE PROCEDURE etl_DimDate
AS
  BEGIN TRY
      DROP TABLE bluebin.DimDate
  END TRY

  BEGIN CATCH
  /*No Action*/
  END CATCH

  BEGIN TRY
      DROP TABLE bluebin.DimSnapshotDate
  END TRY

  BEGIN CATCH
  /*No Action*/
  END CATCH

    /********************		CREATE DimDate Table		*****************************/
    CREATE TABLE bluebin.DimDate
      (
         [DateKey] INT PRIMARY KEY,
         [Date]    DATETIME
      )

    /***************************	SET Date Range for DimDate (2 years back, 1 year forward)		*****************************/
    DECLARE @StartDate DATETIME = Dateadd(yy, -2, Dateadd(yy, Datediff(yy, 0, Getdate()), 0)) --Starting value of Date Range
    DECLARE @EndDate DATETIME = Dateadd(yy, 1, Dateadd(yy, Datediff(yy, 0, Getdate()) + 1, -1)) --End Value of Date Range
    --Extract and assign various parts of Values from Current Date to Variable
    DECLARE @CurrentDate AS DATETIME = @StartDate

    --Proceed only if Start Date(Current date ) is less than End date you specified above
    WHILE @CurrentDate < @EndDate
      BEGIN
          --Populate Your Dimension Table with values
          INSERT INTO bluebin.DimDate
          SELECT CONVERT (CHAR(8), @CurrentDate, 112) AS DateKey,
                 @CurrentDate                         AS Date

          SET @CurrentDate = Dateadd(DD, 1, @CurrentDate)
      END

    /********************************		CREATE DimDateSnapshot		***************************************/
    CREATE TABLE bluebin.DimSnapshotDate
      (
         [DateKey] INT PRIMARY KEY,
         [Date]    DATETIME
      )

    /*************************************		SET Date Range values (Configurable window based on bluebin.Config = 'ReportDateStart')					***********************/

	DECLARE @StartDateConfig int
	select @StartDateConfig = ConfigValue from bluebin.Config where ConfigName = 'ReportDateStart'
	SET @StartDate = Dateadd(dd, @StartDateConfig, Dateadd(dd, Datediff(dd, 0, Getdate()), 0)) --Starting value of Date Range

	SET @EndDate = Dateadd(dd, Datediff(dd, 0, Getdate()), 0) --End Value of Date Range
    --Extract and assign various parts of Values from Current Date to Variable
    SET @CurrentDate = @StartDate

    --Proceed only if Start Date(Current date ) is less than End date you specified above
    WHILE @CurrentDate < @EndDate
      BEGIN
          /* Populate Your Dimension Table with values*/
          INSERT INTO bluebin.DimSnapshotDate
          SELECT CONVERT (CHAR(8), @CurrentDate, 112) AS DateKey,
                 @CurrentDate                         AS Date

          SET @CurrentDate = Dateadd(DD, 1, @CurrentDate)
      END 
GO


	  UPDATE etl.JobSteps
SET LastModifiedDate = GETDATE()
WHERE StepName = 'DimDate'

GO

/***********************************************************

			DimBinStatus

***********************************************************/

IF EXISTS ( SELECT  *
            FROM    sys.objects
            WHERE   object_id = OBJECT_ID(N'etl_DimBinStatus')
                    AND type IN ( N'P', N'PC' ) ) 

DROP PROCEDURE  etl_DimBinStatus
GO

CREATE PROCEDURE etl_DimBinStatus

AS

BEGIN TRY
DROP TABLE bluebin.DimBinStatus
END TRY

BEGIN CATCH
END CATCH


CREATE TABLE [bluebin].[DimBinStatus](
	[BinStatusKey] [int] NULL,
	[BinStatus] [varchar](50) NULL
) ON [PRIMARY]



INSERT INTO bluebin.DimBinStatus (	BinStatusKey,	BinStatus	) VALUES( 1, 'Critical')
INSERT INTO bluebin.DimBinStatus (	BinStatusKey,	BinStatus	) VALUES( 2, 'Hot')
INSERT INTO bluebin.DimBinStatus (	BinStatusKey,	BinStatus	) VALUES( 3, 'Healthy' )
INSERT INTO bluebin.DimBinStatus (	BinStatusKey,	BinStatus	) VALUES( 4, 'Slow' )
INSERT INTO bluebin.DimBinStatus (	BinStatusKey,	BinStatus	) VALUES( 5, 'Stale' )
INSERT INTO bluebin.DimBinStatus (	BinStatusKey,	BinStatus	) VALUES( 6, 'Never Scanned')

GO

UPDATE etl.JobSteps
SET LastModifiedDate = GETDATE()
WHERE StepName = 'DimBinStatus'
GO



/***********************************************************

			DimBin

***********************************************************/

IF EXISTS ( SELECT  *
            FROM    sys.objects
            WHERE   object_id = OBJECT_ID(N'etl_DimBin')
                    AND type IN ( N'P', N'PC' ) ) 

DROP PROCEDURE  etl_DimBin
GO

CREATE PROCEDURE etl_DimBin

AS

--exec etl_DimBin
/***************************		DROP DimBin		********************************/
BEGIN TRY
    DROP TABLE bluebin.DimBin
END TRY

BEGIN CATCH
END CATCH


--/***************************		CREATE Temp Tables		*************************/


/***********************************		CREATE	DimBin		***********************************/
declare @Facility int
   select @Facility = ConfigValue from bluebin.Config where ConfigName = 'PS_DefaultFacility'
  


SELECT Row_number()
         OVER(
           ORDER BY Locations.LOCATION, Bins.INV_ITEM_ID) AS BinKey,
       --Bins.INV_CART_ID                                 AS CartID,
	   case when @Facility is not null or @Facility <> '' then @Facility else ''end	as BinFacility,
       Bins.INV_ITEM_ID                                 AS ItemID,
       Locations.LOCATION                               AS LocationID,
       Bins.COMPARTMENT                                 AS BinSequence,
		CASE WHEN ISNUMERIC(left(Bins.COMPARTMENT,1))=1 then LEFT(Bins.COMPARTMENT,2) 
				else CASE WHEN Bins.COMPARTMENT LIKE '[A-Z][A-Z]%' THEN LEFT(Bins.COMPARTMENT, 2) ELSE LEFT(Bins.COMPARTMENT, 1) END END as BinCart,
			CASE WHEN ISNUMERIC(left(Bins.COMPARTMENT,1))=1 then SUBSTRING(Bins.COMPARTMENT, 3, 1) 
				else CASE WHEN Bins.COMPARTMENT LIKE '[A-Z][A-Z]%' THEN SUBSTRING(Bins.COMPARTMENT, 3, 1) ELSE SUBSTRING(Bins.COMPARTMENT, 2,1) END END as BinRow,
			CASE WHEN ISNUMERIC(left(Bins.COMPARTMENT,1))=1 then SUBSTRING(Bins.COMPARTMENT, 4, 2)
				else CASE WHEN Bins.COMPARTMENT LIKE '[A-Z][A-Z]%' THEN SUBSTRING (Bins.COMPARTMENT,4,2) ELSE SUBSTRING(Bins.COMPARTMENT, 3,2) END END as BinPosition,	
			
           CASE
             WHEN Bins.COMPARTMENT LIKE 'CARD%' THEN 'WALL'
             ELSE 
				case when LEN(Bins.COMPARTMENT) = 6 then RIGHT(Bins.COMPARTMENT, 2)
				else RIGHT(Bins.COMPARTMENT, 3) end
           END                                           AS BinSize,
       Bins.UNIT_OF_MEASURE                             AS BinUOM,
       Cast(Bins.QTY_OPTIMAL AS INT)                    AS BinQty,
       convert(int,(Select max(ConfigValue) from bluebin.Config where ConfigName = 'DefaultLeadTime') )        AS BinLeadTime,
	   Locations.EFFDT									AS BinGoLiveDate,
	   
		bu.LAST_PRICE_PAID AS BinCurrentCost,
       bu.CONSIGNED_FLAG AS BinConsignmentFlag,
       '' AS BinGLAccount,
	   'Awaiting Updated Status'						 AS BinCurrentStatus


INTO   bluebin.DimBin
FROM   
	(select distinct 
	INV_CART_ID, 
	INV_ITEM_ID,
	--COMPARTMENT,
	case when LEN(COMPARTMENT) < 6 then '' else COMPARTMENT end as COMPARTMENT,
	QTY_OPTIMAL,
	UNIT_OF_MEASURE
	
	 from dbo.CART_TEMPL_INV ) Bins
	          
	  LEFT JOIN dbo.CART_ATTRIB_INV Carts
              ON Bins.INV_CART_ID = Carts.INV_CART_ID
        LEFT JOIN dbo.LOCATION_TBL Locations
              ON Carts.LOCATION = Locations.LOCATION
		INNER JOIN bluebin.DimLocation dl
              ON Locations.LOCATION COLLATE DATABASE_DEFAULT = dl.LocationID
		INNER JOIN dbo.BU_ITEMS_INV bu on Bins.INV_ITEM_ID = bu.INV_ITEM_ID  and bu.BUSINESS_UNIT in (select ConfigValue from bluebin.Config where ConfigName = 'PS_BUSINESSUNIT')
WHERE  
		dl.BlueBinFlag = 1 and
		LEN(COMPARTMENT) >=6 and 
		(LEFT(Locations.LOCATION, 2) COLLATE DATABASE_DEFAULT IN (SELECT [ConfigValue] FROM   [bluebin].[Config] WHERE  [ConfigName] = 'REQ_LOCATION' AND Active = 1) 
		or Locations.LOCATION COLLATE DATABASE_DEFAULT in (Select REQ_LOCATION from bluebin.ALT_REQ_LOCATION))


		--and Bins.INV_ITEM_ID = '0301101' and Bins.INV_CART_ID = '99059BB10C'
		order by Locations.LOCATION,Bins.INV_ITEM_ID 

/*****************************************		DROP Temp Tables	**************************************/


GO

UPDATE etl.JobSteps
SET LastModifiedDate = GETDATE()
WHERE StepName = 'DimBin'


GO

/*************************************************

			FactScan

*************************************************/

IF EXISTS ( SELECT  *
            FROM    sys.objects
            WHERE   object_id = OBJECT_ID(N'etl_FactScan')
                    AND type IN ( N'P', N'PC' ) ) 

DROP PROCEDURE  etl_FactScan
GO

CREATE PROCEDURE etl_FactScan
--exec etl_FactScan
AS

/*****************************		DROP FactScan		*******************************/

BEGIN Try
    DROP TABLE bluebin.FactScan
END Try

BEGIN Catch
END Catch

--select * from PO_LINE_DISTRIB where LOCATION like '%BB%'
--select * from PO_LINE where PO_ID in (select PO_ID from PO_LINE_DISTRIB where LOCATION like '%BB%')
--select * from PO_HDR where PO_ID in (select PO_ID from PO_LINE_DISTRIB where LOCATION like '%BB%')


--**************************
declare @DefaultLT int = (Select max(ConfigValue) from bluebin.Config where ConfigName = 'DefaultLeadTime')
;
WITH FirstScans
     AS (SELECT INV_CART_ID      AS LocationID,
                INV_ITEM_ID      AS ItemID,
                Min(DEMAND_DATE) AS FirstScanDate
         FROM   dbo.CART_CT_INF_INV
         WHERE  CART_COUNT_QTY > 0
                AND PROCESS_INSTANCE > 0
         GROUP  BY INV_CART_ID,
                   INV_ITEM_ID),
--**************************
Orders
     AS (SELECT Row_number()
                  OVER(
                    PARTITION BY PO_LN.INV_ITEM_ID, PO_LN_DST.LOCATION, PO_HDR.PO_DT
                    ORDER BY PO_LN.PO_ID, PO_LN.LINE_NBR) AS DailySeq,
                Bins.BinKey,
				--Bins.BinGoLiveDate,
                PO_LN.INV_ITEM_ID                         AS ItemID,
                PO_LN_DST.LOCATION                        AS LocationID,
                PO_LN.PO_ID                               AS OrderNum,
                PO_LN.LINE_NBR                            AS LineNum,
                RECEIPT_DTTM                              AS CloseDate,
                QTY_PO                                    AS OrderQty,
                PO_LN.UNIT_OF_MEASURE                     AS OrderUOM,
                PO_HDR.PO_DT
         FROM   dbo.PO_LINE_DISTRIB PO_LN_DST
                INNER JOIN dbo.PO_LINE PO_LN
                        ON PO_LN_DST.PO_ID = PO_LN.PO_ID
                           AND PO_LN_DST.LINE_NBR = PO_LN.LINE_NBR
                INNER JOIN dbo.PO_HDR
                        ON PO_LN.PO_ID = PO_HDR.PO_ID
                INNER JOIN bluebin.DimBin Bins
                        ON PO_LN.INV_ITEM_ID = Bins.ItemID
                           AND Bins.LocationID = PO_LN_DST.LOCATION
                LEFT JOIN dbo.RECV_LN_SHIP SHIP
                       ON PO_LN.PO_ID = SHIP.PO_ID
                          AND PO_LN.LINE_NBR = SHIP.LINE_NBR
                LEFT JOIN FirstScans
                       ON PO_LN.INV_ITEM_ID = FirstScans.ItemID
                          AND PO_LN_DST.LOCATION = FirstScans.LocationID
         WHERE  (LEFT(PO_LN_DST.LOCATION, 2) COLLATE DATABASE_DEFAULT IN (SELECT [ConfigValue] FROM   [bluebin].[Config] WHERE  [ConfigName] = 'REQ_LOCATION' AND Active = 1) 
				or PO_LN_DST.LOCATION COLLATE DATABASE_DEFAULT in (Select REQ_LOCATION from bluebin.ALT_REQ_LOCATION))
                AND PO_LN.CANCEL_STATUS NOT IN ( 'X', 'D' )
                --AND PO_LN_DST.BUSINESS_UNIT_GL = 209
				)
				,



--**************************
CartCounts
     AS (SELECT Row_number()
                  OVER(
                    PARTITION BY INV_CART_ID, INV_ITEM_ID, DEMAND_DATE
                    ORDER BY LAST_DTTM_UPDATE) AS DailySeq,
                INV_CART_ID                    AS LocationID,
                INV_ITEM_ID					   AS ItemID,
                DEMAND_DATE                    AS PO_DT,
                LAST_DTTM_UPDATE               AS SCAN_DATE
         FROM   dbo.CART_CT_INF_INV
         WHERE  --CART_COUNT_QTY <> 0
                --AND CART_REPLEN_OPT = '02'
				(LEFT(INV_CART_ID, 2) COLLATE DATABASE_DEFAULT IN (SELECT [ConfigValue] FROM   [bluebin].[Config] WHERE  [ConfigName] = 'REQ_LOCATION' AND Active = 1) 
				or INV_CART_ID COLLATE DATABASE_DEFAULT in (Select REQ_LOCATION from bluebin.ALT_REQ_LOCATION))),
--**************************
tmpLines AS (
SELECT a.BinKey,
       --a.BinGoLiveDate,
	   a.ItemID,
       a.LocationID,
       a.OrderNum,
       a.LineNum,
       b.SCAN_DATE                 AS OrderDate,
       a.CloseDate,
       a.OrderQty,
       a.OrderUOM
FROM   Orders a
       INNER JOIN CartCounts b
               ON a.LocationID = b.LocationID
                  AND a.ItemID = b.ItemID
                  AND a.PO_DT = b.PO_DT
                  AND a.DailySeq = b.DailySeq 

UNION ALL
SELECT Bins.BinKey,
--Bins.BinGoLiveDate,
       INV_ITEM_ID as ItemID,
       LOCATION as LocationID,
       Picks.ORDER_NO as OrderNum,
       Picks.ORDER_INT_LINE_NO as LineNum,
       Picks.SCHED_DTTM as OrderDate,
       Picks.PICK_CONFIRM_DTTM as CloseDate,
       Cast(Picks.QTY_PICKED AS INT) AS OrderQty,
UNIT_OF_MEASURE as OrderUOM

FROM   dbo.IN_DEMAND Picks
       INNER JOIN bluebin.DimBin Bins
               ON Picks.LOCATION = Bins.LocationID
                  AND Picks.INV_ITEM_ID = Bins.ItemID
		LEFT JOIN FirstScans
		ON Picks.INV_ITEM_ID = FirstScans.ItemID AND Picks.LOCATION = FirstScans.LocationID
WHERE  (LEFT(LOCATION, 2) COLLATE DATABASE_DEFAULT IN (SELECT [ConfigValue] FROM   [bluebin].[Config] WHERE  [ConfigName] = 'REQ_LOCATION' AND Active = 1) 
		or LOCATION COLLATE DATABASE_DEFAULT in (Select REQ_LOCATION from bluebin.ALT_REQ_LOCATION))
       AND CANCEL_DTTM IS NULL
	   AND DEMAND_DATE >= FirstScanDate)
	   
	   ,
--**************************	   
tmpOrders 
	AS (
	SELECT Row_number()
         OVER(
           Partition BY BinKey
           ORDER BY OrderDate) AS OrderSeq,
       *,
       CASE
         WHEN OrderNum LIKE 'MSR%' THEN 'MSR'
         ELSE 'PO'
       END                     AS OrderType
FROM   tmpLines
),

--**************************
Scans
     AS (
  SELECT Row_number()
                  OVER(
                    Partition BY o.BinKey
                    ORDER BY o.OrderDate DESC) AS Scanseq,
					Row_number()
                  OVER(
                    Partition BY o.BinKey
                    ORDER BY o.OrderDate ASC) AS ScanHistseq,
                o.BinKey,
				--o.BinGoLiveDate,
                o.LocationID,
                o.ItemID,
                '' as OrderTypeID,
                o.OrderType,
                '' as CartCountNum,
                o.OrderNum,
                o.LineNum,
				o.OrderUOM,
                o.OrderQty,
                o.OrderDate,
                o.CloseDate
        FROM   
               tmpOrders o
			    
				)--select * from Scans where BinKey = '825' order by OrderDate


				
SELECT a.Scanseq,
		a.ScanHistseq,
	   a.BinKey,
       c.LocationKey,
       d.ItemKey,
	   db.BinGoLiveDate,
       --COALESCE(a.OrderTypeID, '-') as OrderTypeID,  
       --COALESCE(a.CartCountNum, 0) as CartCountNum --Old PS field,
       a.OrderNum,
       a.LineNum,
	   case when a.OrderType = 'MSR' then 'I'
			else 'N' end as ItemType,
	   a.OrderUOM,
       Cast(a.OrderQty AS INT) AS OrderQty,
       a.OrderDate,
       a.CloseDate as OrderCloseDate,
       b.OrderDate             AS PrevOrderDate,
       b.CloseDate             AS PrevOrderCloseDate,
	   1 as Scan,
       CASE
         WHEN Datediff(Day, b.OrderDate, a.OrderDate) < COALESCE(db.BinLeadTime,@DefaultLT,3) THEN 1
         ELSE 0
       END                     AS HotScan,
       CASE
         WHEN a.OrderDate < COALESCE(b.CloseDate, Getdate())
              AND a.ScanHistseq > (select ConfigValue + 1 from bluebin.Config where ConfigName = 'ScanThreshold') THEN 1 --When looking for stockouts you have to take the scanseq 2 after the ignored one
         ELSE 0
       END                     AS StockOut

into bluebin.FactScan
FROM   Scans a
       INNER JOIN bluebin.DimBin db on a.BinKey = db.BinKey
	   LEFT JOIN Scans b
              ON a.BinKey = b.BinKey
                 AND a.Scanseq = b.Scanseq - 1
       LEFT JOIN bluebin.DimLocation c
              ON a.LocationID = c.LocationID
       LEFT JOIN bluebin.DimItem d
              ON a.ItemID = d.ItemID
	   
WHERE  a.OrderDate >= db.BinGoLiveDate --and a.OrderDate > getdate() -360--and d.ItemKey = '18710' and 
Order by BinKey,ScanHistseq asc


GO

UPDATE etl.JobSteps
SET LastModifiedDate = GETDATE()
WHERE StepName = 'FactScan'




IF EXISTS ( SELECT  *
            FROM    sys.objects
            WHERE   object_id = OBJECT_ID(N'etl_FactBinSnapshot')
                    AND type IN ( N'P', N'PC' ) ) 

DROP PROCEDURE  etl_FactBinSnapshot
GO
--exec etl_FactBinSnapshot

CREATE PROCEDURE  etl_FactBinSnapshot

AS


/********************************		DROP FactBinSnapshot	****************************/

BEGIN Try
    DROP TABLE bluebin.FactBinSnapshot
END Try

BEGIN Catch
END Catch


/*******************************		CREATE Temp Tables		******************************/

SELECT 
       BinKey,
       MAX(OrderDate) AS LastScannedDate,
       DimSnapshotDate.Date,
	   DATEDIFF(DAY, MAX(OrderDate), Date) as DaysSinceLastScan
INTO   #LastScans
FROM   bluebin.FactScan
       INNER JOIN bluebin.DimSnapshotDate
              ON CAST(CONVERT(varchar,OrderDate,101) as datetime) <= DimSnapshotDate.Date
GROUP BY
		BinKey, Date

		
SELECT DimBin.BinKey,
       DimBin.BinLeadTime,
       DimSnapshotDate.Date,
       Sum(COALESCE(Scan, 0))                                                                          AS ScansInThreshold,
       Sum(COALESCE(HotScan, 0))                                                                       AS HotScansInThreshold,
       Sum(COALESCE(StockOut, 0))                                                                      AS StockOutsInThreshold,
       Sum(CASE
             WHEN Cast(OrderDate AS DATE) = Cast(Dateadd(Day, -1, DimSnapshotDate.Date) AS DATE) THEN StockOut
             ELSE 0
           END)                                                                                        AS StockOutsDaily,
		   AVG(DATEDIFF(HOUR, OrderDate, COALESCE(OrderCloseDate,GETDATE())))						AS TimeToFill,
       ( ( Cast(30 AS FLOAT) / Cast(CASE
                                      WHEN COALESCE(Sum(COALESCE(Scan, 0)), 1) = 0 THEN 1
                                      ELSE COALESCE(Sum(COALESCE(Scan, 0)), 1)
                                    END AS FLOAT) ) / Cast(COALESCE(DimBin.BinLeadTime, 3) AS FLOAT) ) AS BinVelocity
INTO   #ThresholdScans
FROM   bluebin.DimBin
       CROSS JOIN bluebin.DimSnapshotDate
       LEFT JOIN bluebin.FactScan
              ON Cast(DimSnapshotDate.Date AS DATE) >= Cast(OrderDate AS DATE)
                 AND Dateadd(DAY, -30, DimSnapshotDate.Date) <= Cast(OrderDate AS DATE)
                 AND DimBin.BinKey = FactScan.BinKey
WHERE  DimSnapshotDate.Date >= DimBin.BinGoLiveDate
GROUP  BY DimBin.BinKey,
          DimSnapshotDate.Date,
          DimBin.BinLeadTime 

SELECT Date,
       BinKey,
	   BinFacility,
       LocationID,
       ItemID,
       BinGoLiveDate
INTO   #tmpBinDates
FROM   bluebin.DimBin
       CROSS JOIN bluebin.DimSnapshotDate
WHERE  BinGoLiveDate <= Date 

SELECT DISTINCT BinKey
INTO #tmpScannedBins
FROM   bluebin.FactScan
where ScanHistseq > (select ConfigValue from bluebin.Config where ConfigName = 'ScanThreshold')


/***********************************		CREATE FactBinSnapshot		*******************************************/
declare @SlowBinDays int
declare @StaleBinDays int
select @SlowBinDays = ConfigValue from bluebin.Config where ConfigName = 'SlowBinDays'
select @StaleBinDays = ConfigValue from bluebin.Config where ConfigName = 'StaleBinDays'


SELECT #tmpBinDates.BinKey,
       DimLocation.LocationKey,
       DimItem.ItemKey,
       #tmpBinDates.Date                                                                 AS BinSnapshotDate,
       COALESCE(LastScannedDate, #tmpBinDates.BinGoLiveDate)                              AS LastScannedDate,
       COALESCE(DaysSinceLastScan, Datediff(Day, #tmpBinDates.BinGoLiveDate, #tmpBinDates.Date)) AS DaysSinceLastScan,
       COALESCE(ScansInThreshold, 0)                                                AS ScanSinThreshold,
       COALESCE(HotScansInThreshold, 0)                                             AS HotScanSinThreshold,
       COALESCE(StockOutsInThreshold, 0)                                            AS StockOutSinThreshold,
       COALESCE(StockOutsDaily, 0)                                                  AS StockOutsDaily,
	   TimeToFill,
	   BinVelocity,
       CASE 
	    WHEN #tmpScannedBins.BinKey IS NULL AND COALESCE(DaysSinceLastScan, Datediff(Day, #tmpBinDates.BinGoLiveDate, #tmpBinDates.Date)) < 90  THEN 6
		WHEN COALESCE(DaysSinceLastScan, Datediff(Day, #tmpBinDates.BinGoLiveDate, #tmpBinDates.Date)) >= @StaleBinDays THEN 5
		WHEN COALESCE(DaysSinceLastScan, Datediff(Day, #tmpBinDates.BinGoLiveDate, #tmpBinDates.Date)) BETWEEN @SlowBinDays AND @StaleBinDays THEN 4
		WHEN (COALESCE(DaysSinceLastScan, Datediff(Day, #tmpBinDates.BinGoLiveDate, #tmpBinDates.Date)) < 90 AND BinVelocity >= 1.25) OR #ThresholdScans.BinLeadTime > 10 THEN 3
		WHEN COALESCE(DaysSinceLastScan, Datediff(Day, #tmpBinDates.BinGoLiveDate, #tmpBinDates.Date)) < 90 AND BinVelocity BETWEEN .75 AND 1.25 THEN 2
		WHEN COALESCE(DaysSinceLastScan, Datediff(Day, #tmpBinDates.BinGoLiveDate, #tmpBinDates.Date)) < 90 AND BinVelocity < .75 THEN 1
		ELSE 0 END																	AS BinStatusKey		
		
INTO   bluebin.FactBinSnapshot

FROM   #tmpBinDates
       LEFT JOIN #LastScans
              ON #tmpBinDates.BinKey = #LastScans.BinKey
                 AND #tmpBinDates.Date = #LastScans.Date
       LEFT JOIN #ThresholdScans
              ON #tmpBinDates.BinKey = #ThresholdScans.BinKey
                 AND #tmpBinDates.Date = #ThresholdScans.Date
       LEFT JOIN bluebin.DimLocation
              ON #tmpBinDates.LocationID = DimLocation.LocationID
			  AND #tmpBinDates.BinFacility = DimLocation.LocationFacility
       LEFT JOIN bluebin.DimItem
              ON #tmpBinDates.ItemID = DimItem.ItemID
		LEFT JOIN #tmpScannedBins
			ON #tmpBinDates.BinKey = #tmpScannedBins.BinKey


/**************************************		DROP Temp Tables		********************************************/

DROP TABLE #LastScans
DROP TABLE #ThresholdScans 
DROP TABLE #tmpBinDates
DROP TABLE #tmpScannedBins

GO

UPDATE etl.JobSteps
SET LastModifiedDate = GETDATE()
WHERE StepName = 'FactBinSnapshot'
GO


/*********************************************************************

		FactIssue

*********************************************************************/

IF EXISTS ( SELECT  *
            FROM    sys.objects
            WHERE   object_id = OBJECT_ID(N'etl_FactIssue')
                    AND type IN ( N'P', N'PC' ) ) 

DROP PROCEDURE  etl_FactIssue
GO

CREATE PROCEDURE etl_FactIssue

AS

/****************************		DROP FactIssue ***********************************/
 BEGIN TRY
 DROP TABLE bluebin.FactIssue
 END TRY
 BEGIN CATCH
 END CATCH

 /*******************************	CREATE FactIssue	*********************************/
  declare @Facility int
   select @Facility = ConfigValue from bluebin.Config where ConfigName = 'PS_DefaultFacility'
  

  
  SELECT 

		case when @Facility is not null or @Facility <> '' then @Facility else '' end as FacilityKey,
		Picks.BUSINESS_UNIT AS LocationID,
       b.LocationKey AS LocationKey,
       c.LocationKey AS ShipLocationKey,
       case when @Facility is not null or @Facility <> '' then @Facility else '' end as ShipFacilityKey,
       c.BlueBinFlag,
	   d.ItemKey AS ItemKey,
       '' AS  SourceSystem,
       Picks.ORDER_NO AS ReqNumber,
       Picks.ORDER_INT_LINE_NO AS ReqLineNumber,
       Picks.SCHED_DTTM AS IssueDate,
       Picks.UNIT_OF_MEASURE AS UOM,
       '' AS UOMMult,
       Picks.QTY_PICKED AS  IssueQty,
       case when PICK_BATCH_ID = 0 then 1 else 0 end AS StatCall,
       1  AS IssueCount
--INTO bluebin.FactIssue
FROM   dbo.IN_DEMAND Picks
	  LEFT JOIN bluebin.DimLocation b
               ON Picks.BUSINESS_UNIT = b.LocationID
                  AND @Facility = b.LocationFacility
       LEFT JOIN bluebin.DimLocation c
               ON Picks.LOCATION = c.LocationID
                  AND @Facility = c.LocationFacility
       LEFT JOIN bluebin.DimItem d
               ON Picks.INV_ITEM_ID = d.ItemID

WHERE  
CANCEL_DTTM IS NULL or CANCEL_DTTM < '1900-01-02'

	
GO

UPDATE etl.JobSteps
SET LastModifiedDate = GETDATE()
WHERE StepName = 'FactIssue'

GO


/*********************************************************************

		FactWarehouseSnapshot

*********************************************************************/


IF EXISTS ( SELECT  *
            FROM    sys.objects
            WHERE   object_id = OBJECT_ID(N'etl_FactWarehouseSnapshot')
                    AND type IN ( N'P', N'PC' ) ) 

DROP PROCEDURE  etl_FactWarehouseSnapshot
GO

CREATE PROCEDURE etl_FactWarehouseSnapshot
AS
--exec etl_FactWarehouseSnapshot  

/*********************		DROP FactWarehouseSnapshot		***************************/

  BEGIN TRY
      drop table bluebin.FactWarehouseSnapshot 
  END TRY

  BEGIN CATCH
  END CATCH

/******************		QUERY				****************************/
;

	
--select 
--	LOCATION,
--	ITEM,
--       SOH_QTY       AS SOHQty,
--	   LAST_ISS_COST	AS UnitCost,
--	   convert(DATE,getdate()) as MonthEnd
--into TempA# 
--from ITEMLOC 
--where 
--	LOCATION in (Select ConfigValue from bluebin.Config where ConfigName = 'LOCATION')
--	and SOH_QTY > 0 
--	OR 
--	LOCATION in (Select ConfigValue from bluebin.Config where ConfigName = 'LOCATION') and 
--	ITEM in (select distinct ITEM from ICTRANS where LOCATION in (Select ConfigValue from bluebin.Config where ConfigName = 'LOCATION'))
--	--AND ITEM in ('0000013','0000018')


--    SELECT 
--		Row_number()
--             OVER(
--               PARTITION BY a.ITEM
--               ORDER BY a.MonthEnd DESC) as [Sequence],
--		a.MonthEnd,
--		a.ITEM,
--		case when a.MonthEnd = convert(DATE,getdate()) then TempA#.SOHQty else (ISNULL(b.QUANTITY,0)*-1) end as QUANTITY,
--		(ISNULL(c.QUANTITY,0)*-1) as QUANTITYIN

--    into TempB#
--	FROM   
--	(SELECT DISTINCT 
--		case when left(Date,11) = left(getdate(),11) then Date else Eomonth(Date) end AS MonthEnd,
--		ITEM
--		FROM   bluebin.DimDate,TempA#) a
--		LEFT JOIN
--		(select 
--			ITEM,
--			EOMONTH(DATEADD(MONTH, -1, TRANS_DATE)) as MonthEnd,
--			SUM((QUANTITY)) as QUANTITY 
--			FROM   ICTRANS 
--			where 
--				LOCATION in (Select ConfigValue from bluebin.Config where ConfigName = 'LOCATION')
--			group by ITEM,
--			EOMONTH(DATEADD(MONTH, -1, TRANS_DATE))) b on a.MonthEnd = b.MonthEnd and a.ITEM = b.ITEM 
--		LEFT JOIN
--		(select 
--			ITEM,
--			EOMONTH(DATEADD(MONTH, -1, REC_ACT_DATE)) as MonthEnd,
--			SUM((REC_QTY*EBUY_UOM_MULT)) as QUANTITY 
--			FROM   POLINE 
--			where 
--				LOCATION in (Select ConfigValue from bluebin.Config where ConfigName = 'LOCATION')
--				and CXL_QTY = 0 and REC_QTY > 0 and ITEM_TYPE = 'I'
--			group by ITEM,
--			EOMONTH(DATEADD(MONTH, -1, REC_ACT_DATE))) c on a.MonthEnd = c.MonthEnd and a.ITEM = c.ITEM 
--		left join TempA# on a.MonthEnd = TempA#.MonthEnd and a.ITEM = TempA#.ITEM
--    WHERE  a.MonthEnd <= Getdate() 



--select 
--ic.COMPANY AS FacilityKey,
--df.FacilityName,
--ic.LOCATION as LocationID,
--TempB#.MonthEnd as SnapshotDate,
--TempB#.ITEM,
--SUM(TempB#.QUANTITY+TempB#.QUANTITYIN) OVER (PARTITION BY TempB#.ITEM ORDER BY TempB#.[Sequence]) as SOH,
--ic.LAST_ISS_COST  AS UnitCost  
----,SUM(TempB#.QUANTITY+TempB#.QUANTITYIN) OVER (PARTITION BY TempB#.ITEM ORDER BY TempB#.[Sequence])*ic.LAST_ISS_COST as B
--into bluebin.FactWarehouseSnapshot
--from TempB# 
--inner join ITEMLOC ic on TempB#.ITEM = ic.ITEM
--inner join bluebin.DimFacility df on ic.COMPANY = df.FacilityID
--where ic.LOCATION in (Select ConfigValue from bluebin.Config where ConfigName = 'LOCATION')

--drop table TempA#
--drop table TempB#


select 
'' AS FacilityKey,
'' AS FacilityName,
'' AS LocationID,
'' AS SnapshotDate,
'' AS ITEM,
'' AS SOH,
'' AS UnitCost  
--,SUM(TempB#.QUANTITY+TempB#.QUANTITYIN) OVER (PARTITION BY TempB#.ITEM ORDER BY TempB#.[Sequence])*ic.LAST_ISS_COST as B
into bluebin.FactWarehouseSnapshot


/*********************	END		******************************/

GO

UPDATE etl.JobSteps
SET LastModifiedDate = GETDATE()
WHERE StepName = 'FactWarehouseSnapshot'

GO

/***************************************************************************

			Kanban

***************************************************************************/

IF EXISTS ( SELECT  *
            FROM    sys.objects
            WHERE   object_id = OBJECT_ID(N'tb_Kanban')
                    AND type IN ( N'P', N'PC' ) ) 

DROP PROCEDURE  tb_Kanban
GO
--exec tb_Kanban
CREATE PROCEDURE tb_Kanban

AS

BEGIN TRY
    DROP TABLE tableau.Kanban
END TRY

BEGIN CATCH
END CATCH


SELECT distinct DimBin.BinKey,
       df.FacilityID,
	   df.FacilityName,
	   DimBin.LocationID,
       DimBin.ItemID,
       DimBin.BinSequence,
       DimBin.BinUOM,
       DimBin.BinQty,
	   DimBin.BinCurrentCost,
	   DimBin.BinGLAccount,
	   DimBin.BinConsignmentFlag,
       DimBin.BinLeadTime,
       DimBin.BinGoLiveDate,
	   DimBin.BinCurrentStatus,
       DimSnapshotDate.Date,       
	   FactScan.ScanHistseq,
       FactScan.ItemType,       
       FactScan.OrderNum,
       FactScan.LineNum,
       FactScan.OrderUOM,
       FactScan.OrderQty,
       FactScan.OrderDate,
       FactScan.OrderCloseDate,
       FactScan.PrevOrderDate,
       FactScan.PrevOrderCloseDate,
       FactScan.Scan,
       FactScan.HotScan,
       FactScan.StockOut,
       FactBinSnapshot.BinSnapshotDate,
       FactBinSnapshot.LastScannedDate,
       FactBinSnapshot.DaysSinceLastScan,
       FactBinSnapshot.ScanSinThreshold,
       FactBinSnapshot.HotScanSinThreshold,
       FactBinSnapshot.StockOutSinThreshold,
       FactBinSnapshot.StockOutsDaily,
	   FactBinSnapshot.TimeToFill,
	   FactBinSnapshot.BinVelocity,
       DimBinStatus.BinStatus,
       DimItem.ItemDescription,
	   DimItem.ItemClinicalDescription,
       DimItem.ItemManufacturer,
       DimItem.ItemManufacturerNumber,
       DimItem.ItemVendor,
       DimItem.ItemVendorNumber,
       DimLocation.LocationName,
       1 AS TotalBins
INTO   tableau.Kanban
FROM   bluebin.DimBin
       CROSS JOIN bluebin.DimSnapshotDate
       LEFT JOIN bluebin.FactScan
              ON Cast(OrderDate AS DATE) = Cast(Date AS DATE)
                 AND DimBin.BinKey = FactScan.BinKey
       LEFT JOIN bluebin.FactBinSnapshot
              ON Date = BinSnapshotDate
                 AND DimBin.BinKey = FactBinSnapshot.BinKey
       LEFT JOIN bluebin.DimItem
              ON DimBin.ItemID = DimItem.ItemID
       LEFT JOIN bluebin.DimLocation
              ON DimBin.LocationID = DimLocation.LocationID
			  AND DimBin.BinFacility = DimLocation.LocationFacility
       LEFT JOIN bluebin.DimBinStatus
              ON FactBinSnapshot.BinStatusKey = DimBinStatus.BinStatusKey
	   left join bluebin.DimFacility df on bluebin.DimBin.BinFacility = df.FacilityID
	   --left join dbo.REQHEADER rqh on FactScan.OrderNum = rqh.REQ_NUMBER
WHERE  Date >= DimBin.BinGoLiveDate 

GO

UPDATE etl.JobSteps
SET LastModifiedDate = GETDATE()
WHERE StepName = 'Kanban'

GO
grant exec on tb_Kanban to public
GO



/*****************************************************************************

			Sourcing

*****************************************************************************/





/*******************************************************************************


			Contracts


*******************************************************************************/





/***********************************************************************

		Update Bin Status

***********************************************************************/


IF EXISTS ( SELECT  *
            FROM    sys.objects
            WHERE   object_id = OBJECT_ID(N'etl_UpdateBinStatus')
                    AND type IN ( N'P', N'PC' ) ) 

DROP PROCEDURE  etl_UpdateBinStatus
GO

CREATE PROCEDURE	etl_UpdateBinStatus

AS

UPDATE bluebin.DimBin
SET    DimBin.BinCurrentStatus = DimBinStatus.BinStatus
FROM   bluebin.DimBin
       INNER JOIN bluebin.FactBinSnapshot
               ON DimBin.BinKey = FactBinSnapshot.BinKey
       INNER JOIN bluebin.DimBinStatus
               ON FactBinSnapshot.BinStatusKey = DimBinStatus.BinStatusKey
WHERE  FactBinSnapshot.BinSnapshotDate = Cast(CONVERT(VARCHAR, Dateadd(DAY, -1, Getdate()), 101) AS DATETIME)

GO

UPDATE etl.JobSteps
SET LastModifiedDate = GETDATE()
WHERE StepName = 'Update Bin Status'
GO

/******************************************************************************

			Refresh Dashboard Data

******************************************************************************/

IF EXISTS ( SELECT  *
            FROM    sys.objects
            WHERE   object_id = OBJECT_ID(N'etl_RefreshDashboardData')
                    AND type IN ( N'P', N'PC' ) ) 

DROP PROCEDURE  etl_RefreshDashboardData
GO

CREATE PROCEDURE	etl_RefreshDashboardData

AS

DECLARE 
	@ProcessID int,
	@RowCount int,
	@StepName varchar(50),
	@StepMin	int,
	@StepMax	int,
	@Step	int,
	@StepProc varchar(255),
	@StepTable nvarchar(255),
	@SQL nvarchar(max),
	@Active int


-- Initialize etl.JobHeader and insert row for current run

SET @ProcessID = (SELECT MAX(CASE WHEN ProcessID IS NULL THEN 0 ELSE ProcessID END) + 1 FROM etl.JobHeader);

INSERT INTO [etl].[JobHeader]
           ([ProcessID]
           ,[StartTime])
     VALUES
           (@ProcessID, GETDATE())

-- Loop through Job Steps table and execute accordingly

SET @StepMin = (SELECT MIN(StepNumber) FROM etl.JobSteps)
SET @StepMax = (SELECT MAX(StepNumber) FROM etl.JobSteps)
SET @Step = @StepMin

WHILE @Step <= @StepMax

BEGIN

SET @StepName = (SELECT StepName FROM etl.JobSteps WHERE StepNumber = @Step)
SET @StepProc = (SELECT StepProcedure FROM etl.JobSteps WHERE StepNumber = @Step)
SET @StepTable = (SELECT StepTable FROM etl.JobSteps WHERE StepNumber = @Step)
SET @Active = (SELECT ActiveFlag FROM etl.JobSteps WHERE StepNumber = @Step)

INSERT INTO [etl].[JobDetails]
           ([ProcessID]
           ,[StepName]
           ,[StartTime]
		   ,Result
           )
     VALUES
           (@ProcessID, @StepName, GETDATE(),'Pending')

BEGIN TRY

IF @Active = 1
BEGIN
EXEC ('EXEC ' + @StepProc)
END

SET @SQL = 'SELECT @RowCount=COUNT(*) FROM ' + @StepTable
EXECUTE sp_executesql @SQL, N'@RowCount int OUTPUT', @RowCount = @RowCount OUTPUT


UPDATE [etl].[JobDetails]
   SET [EndTime] = GETDATE()
      ,[RowCount] = case when @Active = 0 then @Active else @RowCount end
      ,[Result] = case when @Active = 0 then 'InActive Step' else 'Success' end
	  ,[Message] = ERROR_MESSAGE()
 WHERE ProcessID = @ProcessID AND StepName = @StepName
 
  UPDATE [etl].[JobHeader]
   SET [EndTime] = GETDATE()
      ,[Result] = 'Success'
 WHERE ProcessID = @ProcessID


END TRY

BEGIN CATCH

UPDATE [etl].[JobDetails]
   SET [EndTime] = GETDATE()
      ,[RowCount] = case when @Active = 0 then @Active else @RowCount end
      ,[Result] = case when @Active = 0 then 'InActive Step' else 'Failure' end
	  ,[Message] = ERROR_MESSAGE()
 WHERE ProcessID = @ProcessID AND StepName = @StepName
 
UPDATE [etl].[JobHeader]
   SET [EndTime] = GETDATE()
      ,[Result] = 'Failure (' + @StepName + ')'
 WHERE ProcessID = @ProcessID


END CATCH


SET @Step = @Step + 1

END

GO

/************************************************************

			DimWarehouseItem

************************************************************/

IF EXISTS ( SELECT  *
            FROM    sys.objects
            WHERE   object_id = OBJECT_ID(N'etl_DimWarehouseItem')
                    AND type IN ( N'P', N'PC' ) ) 

DROP PROCEDURE  etl_DimWarehouseItem
GO

CREATE PROCEDURE	etl_DimWarehouseItem

AS
--exec etl_DimWarehouseItem
/********************************		DROP DimWarehouseItem		**********************************/

BEGIN TRY
    DROP TABLE bluebin.DimWarehouseItem
END TRY

BEGIN CATCH
END CATCH

declare @Facility int
   select @Facility = ConfigValue from bluebin.Config where ConfigName = 'PS_DefaultFacility'
   

SELECT 
		--d.LocationID,
		case when @Facility is not null or @Facility <> '' then @Facility else ''end as FacilityID,
		case when @Facility is not null or @Facility <> '' then (select FacilityName from bluebin.DimFacility where FacilityID = @Facility) else ''end as FacilityName,
		a.BUSINESS_UNIT as LocationID,
		a.BUSINESS_UNIT as LocationName,
		b.ItemKey,
       b.ItemID,
       b.ItemDescription,
       b.ItemClinicalDescription,
       b.ItemManufacturer,
       b.ItemManufacturerNumber,
       b.ItemVendor,
       b.ItemVendorNumber,
       ''    AS StockLocation,
       a.[QTY_ONHAND]       AS SOHQty,
       a.[QTY_MAXIMUM]     AS ReorderQty,
       a.[REORDER_POINT] AS ReorderPoint,
	   a.[LAST_PRICE_PAID]	AS UnitCost,
       b.StockUOM,
       b.BuyUOM,
       b.PackageString
INTO   bluebin.DimWarehouseItem
FROM   [dbo].[BU_ITEMS_INV] a
       INNER JOIN bluebin.DimItem b
               ON a.[INV_ITEM_ID] = b.ItemID
		
       --INNER JOIN ICCATEGORY c
       --        ON a.COMPANY = c.COMPANY
       --           AND a.LOCATION = c.LOCATION
       --           AND a.GL_CATEGORY = c.GL_CATEGORY
		--INNER JOIN 
		--bluebin.DimLocation d
		--ON a.LOCATION = d.LocationID
		--INNER JOIN ICLOCATION e
		--ON a.COMPANY = e.COMPANY
		--AND a.LOCATION = e.LOCATION

--WHERE a.BUSINESS_UNIT in (Select ConfigValue from bluebin.Config where ConfigName = 'LOCATION')
WHERE a.BUSINESS_UNIT in (Select ConfigValue from bluebin.Config where ConfigName = 'PS_BUSINESSUNIT')

GO

UPDATE etl.JobSteps
SET LastModifiedDate = GETDATE()
WHERE StepName = 'Warehouse Item'

GO





/********************************************************************

					DimFacility

********************************************************************/

IF EXISTS ( SELECT  *
            FROM    sys.objects
            WHERE   object_id = OBJECT_ID(N'etl_DimFacility')
                    AND type IN ( N'P', N'PC' ) ) 

DROP PROCEDURE  etl_DimFacility
GO

--drop table bluebin.DimFacility
--delete from bluebin.DimFacility where FacilityID = 2
--select * from bluebin.DimFacility  
--exec etl_DimFacility
CREATE PROCEDURE etl_DimFacility
AS


/*********************		POPULATE/update DimFacility	****************************/
if not exists (select * from sys.tables where name = 'DimFacility')
BEGIN
CREATE TABLE [bluebin].[DimFacility](
	[FacilityID] INT NOT NULL ,
	[FacilityName] varchar (50) NOT NULL
)
;
declare @DefaultFacility int = (select ConfigValue from bluebin.Config where ConfigName = 'PS_DefaultFacility')

if exists (select ConfigValue from bluebin.Config where ConfigName = 'PS_DefaultFacility' and ConfigValue > 0)
BEGIN
INSERT INTO bluebin.DimFacility 
--declare @DefaultFacility int = (select ConfigValue from bluebin.Config where ConfigName = 'PS_DefaultFacility')

select @DefaultFacility,a.SETID
from
	(select distinct SETID from LOCATION_TBL) a
	where @DefaultFacility not in (select FacilityID from bluebin.DimFacility)
	
END 
END
GO

UPDATE etl.JobSteps
SET LastModifiedDate = GETDATE()
WHERE StepName = 'DimFacility'
GO



/********************************************************************

					Warehouse History

********************************************************************/


if exists (select * from dbo.sysobjects where id = object_id(N'etl_FactWHHistory') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure etl_FactWHHistory
GO

--exec etl_FactWHHistory
CREATE PROCEDURE etl_FactWHHistory

--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON

if not exists(select * from sys.tables where name = 'FactWHHistory')
BEGIN
SELECT 
	convert(Date,getdate()) as [Date],
	FacilityName,
	SUM(SOHQty * UnitCost) as DollarsOnHand,
	LocationID,
	LocationID as LocationName,
	count(ItemID) as [SKUS]
into bluebin.FactWHHistory
FROM bluebin.DimWarehouseItem
where SOHQty > 0
GROUP BY
	FacilityName,
	LocationID
GOTO THEEND 
END
ELSE
	BEGIN
		if exists(select * from bluebin.FactWHHistory where [Date] = convert(Date,getdate()))
		BEGIN
		delete from bluebin.FactWHHistory where [Date] = convert(Date,getdate())
		
		INSERT INTO bluebin.FactWHHistory 
			SELECT 
			convert(Date,getdate()) as [Date],
			FacilityName,
			SUM(SOHQty * UnitCost) as DollarsOnHand,
			LocationID,
			LocationID as LocationName,
			count(ItemID) as [SKUS]

			FROM bluebin.DimWarehouseItem
			where SOHQty > 0
			GROUP BY
			FacilityName,
			LocationID 
		END
		ELSE
			if exists (select * from bluebin.DimWarehouseItem)
			BEGIN
			INSERT INTO bluebin.FactWHHistory 
				SELECT 
				convert(Date,getdate()) as [Date],
				i.FacilityName,
				SUM(i.SOHQty * i.UnitCost) as DollarsOnHand,
				i.LocationID,
				i.LocationID as LocationName,
				count(i.ItemID) as [SKUS]
				
				FROM bluebin.DimWarehouseItem i
				where i.SOHQty > 0
				GROUP BY
				i.FacilityName,
				i.LocationID
				
			END
			ELSE
				BEGIN
				INSERT INTO bluebin.FactWHHistory 
				SELECT 
				convert(Date,getdate()) as [Date],
				FacilityName,
				DollarsOnHand,
				LocationID,
				LocationID as LocationName,
				SKUS
				
				FROM bluebin.FactWHHistory 
				WHERE [Date] = convert(Date,getdate() -1)
				END 
	END

THEEND:
END
GO

UPDATE etl.JobSteps
SET LastModifiedDate = GETDATE()
WHERE StepName = 'FactWHHistory'
GO





/********************************************************************

					BlueBinParMaster

********************************************************************/

IF EXISTS ( SELECT  *
            FROM    sys.objects
            WHERE   object_id = OBJECT_ID(N'etl_BlueBinParMaster')
                    AND type IN ( N'P', N'PC' ) ) 

DROP PROCEDURE  etl_BlueBinParMaster
GO


CREATE PROCEDURE etl_BlueBinParMaster
AS


/*********************		UPDATE BlueBinParMaster	****************************/




--Update anything that has changed in the ERP system for items	
update bluebin.BlueBinParMaster 
set 
	BinSequence = db.BS, 
	BinQuantity = convert(int,db.BQ), 
	BinSize = db.Size, 
	LeadTime = db.BinLeadTime,
	LastUpdated = getdate()
	
FROM
	(select LocationID as L,ItemID as I,BinFacility,BinSequence as BS,BinQty as BQ,BinSize as Size,BinLeadTime from bluebin.DimBin) as db

where 
	rtrim(ItemID) = rtrim(db.I) 
	and rtrim(LocationID) = rtrim(db.L) 
	and FacilityID = db.BinFacility 
	and Updated = 1 
	and (BinSequence <> db.BS OR BinQuantity <> convert(int,db.BQ) OR BinSize <> db.Size OR LeadTime <> db.BinLeadTime)


--Update ParMaster items to reflect that the ERP is identical to the ParMaster
update bluebin.BlueBinParMaster 
set 
Updated = 1 
from 
	(select LocationID as L,ItemID as I,BinFacility,BinSequence as BS,BinQty as BQ,BinSize as Size,BinLeadTime from bluebin.DimBin) as db

where 
	rtrim(ItemID) = rtrim(db.I) 
	and rtrim(LocationID) = rtrim(db.L) 
	and FacilityID = db.BinFacility 
	and BinSequence = db.BS 
	and BinQuantity = convert(int,db.BQ) 
	and BinSize = db.Size 
	and LeadTime = db.BinLeadTime 
	and Updated = 0



--Insert values not in the ParMaster but in the ERP
insert [bluebin].[BlueBinParMaster] (FacilityID,LocationID,ItemID,BinSequence,BinSize,BinUOM,BinQuantity,LeadTime,ItemType,WHLocationID,WHSequence,PatientCharge,Updated,LastUpdated)
select 
db.BinFacility,
db.LocationID,
db.ItemID,
db.BinSequence,
db.BinSize,
db.BinUOM,
convert(int,db.BinQty),
db.BinLeadTime,
'',
'',
'',
0,
1,
getdate()
from bluebin.DimBin db
left join bluebin.BlueBinParMaster bbpm on rtrim(db.ItemID) = rtrim(bbpm.ItemID) 
												and rtrim(db.LocationID) = rtrim(bbpm.LocationID)  
													and db.BinFacility = bbpm.FacilityID 
where 
bbpm.ParMasterID is null

	
GO

UPDATE etl.JobSteps
SET LastModifiedDate = GETDATE()
WHERE StepName = 'BlueBinParMaster'
GO

Print 'ETL Sprocs updated'
GO







--*********************************************************************************************
--Tableau Sproc  These load data into the datasources for Tableau
--*********************************************************************************************

if exists (select * from dbo.sysobjects where id = object_id(N'tb_GLSpend') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure tb_GLSpend
GO

--exec tb_GLSpend

CREATE PROCEDURE tb_GLSpend

--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON

--SELECT FISCAL_YEAR                                                                                                                                                                                                  AS FiscalYear,
--       ACCT_PERIOD                                                                                                                                                                                                  AS AcctPeriod,
--       a.COMPANY,
--	   df.FacilityName,
--	   a.ACCOUNT                                                                                                                                                                                                    AS Account,
--       b.ACCOUNT_DESC                                                                                                                                                                                               AS AccountDesc,
--       a.ACCT_UNIT                                                                                                                                                                                                  AS AcctUnit,
--       c.DESCRIPTION                                                                                                                                                                                                AS AcctUnitName,
--       Cast(CONVERT(VARCHAR, CASE WHEN ACCT_PERIOD <= 3 THEN ACCT_PERIOD + 9 ELSE ACCT_PERIOD - 3 END) + '/1/' + CONVERT(VARCHAR, CASE WHEN ACCT_PERIOD <=3 THEN FISCAL_YEAR - 1 ELSE FISCAL_YEAR END) AS DATETIME) AS Date,
--       Sum(TRAN_AMOUNT)                                                                                                                                                                                             AS Amount
--FROM   GLTRANS a
--       INNER JOIN GLCHARTDTL b
--               ON a.ACCOUNT = b.ACCOUNT
--       INNER JOIN GLNAMES c
--               ON a.ACCT_UNIT = c.ACCT_UNIT
--                  AND a.COMPANY = c.COMPANY
--		left join bluebin.DimFacility df on a.COMPANY = df.FacilityID
--WHERE  SUMRY_ACCT_ID in (select ConfigValue from bluebin.Config where ConfigName = 'GLSummaryAccountID')
--GROUP  BY FISCAL_YEAR,
--          ACCT_PERIOD,
--          a.COMPANY,
--			df.FacilityName,
--			a.ACCOUNT,
--          b.ACCOUNT_DESC,
--          a.ACCT_UNIT,
--          c.DESCRIPTION 


SELECT '' AS FiscalYear,
       '' AS  AcctPeriod,
       '' AS COMPANY,
	   '' AS FacilityName,
	   '' AS  Account,
       '' AS  AccountDesc,
       '' AS  AcctUnit,
       '' AS  AcctUnitName,
       '' AS  Date,
       '' AS  Amount
 


END
GO
grant exec on tb_GLSpend to public
GO










--*********************************************************************************************
--Tableau Sproc  These load data into the datasources for Tableau
--*********************************************************************************************

if exists (select * from dbo.sysobjects where id = object_id(N'tb_ItemLocator') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure tb_ItemLocator
GO

--exec tb_ItemLocator

CREATE PROCEDURE tb_ItemLocator

--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON
Declare @UseClinicalDescription int
select @UseClinicalDescription = ConfigValue from bluebin.Config where ConfigName = 'UseClinicalDescription'         

SELECT 
	df.FacilityID,
	df.FacilityName,
	Bins.INV_ITEM_ID  as LawsonItemNumber,
	di.ItemManufacturerNumber  as ItemManufacturerNumber,
	di.ItemDescription as ClinicalDescription,
	dl.LocationID as LocationCode,
	dl.LocationName,
	CASE WHEN ISNUMERIC(left(Bins.COMPARTMENT,1))=1 then LEFT(Bins.COMPARTMENT,2) 
				else CASE WHEN Bins.COMPARTMENT LIKE '[A-Z][A-Z]%' THEN LEFT(Bins.COMPARTMENT, 2) ELSE LEFT(Bins.COMPARTMENT, 1) END END as Cart,
			CASE WHEN ISNUMERIC(left(Bins.COMPARTMENT,1))=1 then SUBSTRING(Bins.COMPARTMENT, 3, 1) 
				else CASE WHEN Bins.COMPARTMENT LIKE '[A-Z][A-Z]%' THEN SUBSTRING(Bins.COMPARTMENT, 3, 1) ELSE SUBSTRING(Bins.COMPARTMENT, 2,1) END END as Row,
			CASE WHEN ISNUMERIC(left(Bins.COMPARTMENT,1))=1 then SUBSTRING(Bins.COMPARTMENT, 4, 2)
				else CASE WHEN Bins.COMPARTMENT LIKE '[A-Z][A-Z]%' THEN SUBSTRING (Bins.COMPARTMENT,4,2) ELSE SUBSTRING(Bins.COMPARTMENT, 3,2) END END as Position

FROM   
	(select distinct 
	INV_CART_ID, 
	INV_ITEM_ID,
	--COMPARTMENT,
	case when LEN(COMPARTMENT) < 6 then '' else COMPARTMENT end as COMPARTMENT,
	QTY_OPTIMAL,
	UNIT_OF_MEASURE
	
	 from dbo.CART_TEMPL_INV
	 ) Bins
	          
	  INNER JOIN dbo.CART_ATTRIB_INV Carts
              ON Bins.INV_CART_ID = Carts.INV_CART_ID
		INNER JOIN bluebin.DimLocation dl
              ON Carts.LOCATION COLLATE DATABASE_DEFAULT = dl.LocationID
		--INNER JOIN dbo.BU_ITEMS_INV bu on Bins.INV_ITEM_ID = bu.INV_ITEM_ID
		INNER JOIN bluebin.DimFacility df on dl.LocationFacility = df.FacilityID
		inner join bluebin.DimItem di on Bins.INV_ITEM_ID = di.ItemID
WHERE LEFT(Carts.LOCATION, 2) IN (SELECT [ConfigValue] FROM   [bluebin].[Config] WHERE  [ConfigName] = 'REQ_LOCATION' AND Active = 1) or Carts.LOCATION in (Select REQ_LOCATION from bluebin.ALT_REQ_LOCATION) and Bins.COMPARTMENT <> ''
group by
df.FacilityID,
	df.FacilityName,
	Bins.INV_ITEM_ID,
	di.ItemDescription,
	di.ItemManufacturerNumber,
	dl.LocationID,
	dl.LocationName,
	Bins.COMPARTMENT


END
GO
grant exec on tb_ItemLocator to public
GO

--*********************************************************************************************
--Tableau Sproc  These load data into the datasources for Tableau
--*********************************************************************************************
if exists (select * from dbo.sysobjects where id = object_id(N'tb_LineVolume') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure tb_LineVolume
GO

--exec tb_LineVolume

CREATE PROCEDURE tb_LineVolume


AS
BEGIN
SET NOCOUNT ON


--SELECT 
--a.COMPANY,
--df.FacilityName,
--CREATION_DATE   AS Date,
--       CASE
--         WHEN LEFT(a.REQ_LOCATION, 2) IN (SELECT ConfigValue
--                                          FROM   [bluebin].[Config]
--                                          WHERE  ConfigName = 'REQ_LOCATION') 
--											or 
--										  a.REQ_LOCATION in (Select REQ_LOCATION from bluebin.ALT_REQ_LOCATION) 
--										  THEN 'BlueBin'
--         ELSE 'Non BlueBin'
--       END             AS LineType,
--       b.ISS_ACCT_UNIT AS AcctUnit,
--       ISNULL(c.DESCRIPTION,'Unknown')   AS AcctUnitName,
--       a.REQ_LOCATION  AS Location,
--       b.NAME          AS LocationName,
--       1               AS LineCount

--FROM   REQLINE a
--       INNER JOIN RQLOC b
--               ON a.COMPANY = b.COMPANY
--                  AND a.REQ_LOCATION = b.REQ_LOCATION
--       LEFT JOIN GLNAMES c
--               ON b.COMPANY = c.COMPANY
--                  AND b.ISS_ACCT_UNIT = c.ACCT_UNIT 
--	   INNER JOIN bluebin.DimFacility df on rtrim(a.COMPANY) = rtrim(df.FacilityID)
--order by 2

SELECT 
'' AS COMPANY,
'' AS FacilityName,
'' AS Date,
'' AS LineType,
'' AS AcctUnit,
'' AS AcctUnitName,
'' AS Location,
'' AS LocationName,
       1               AS LineCount




END
GO
grant exec on tb_LineVolume to public
GO


--*********************************************************************************************
--Tableau Sproc  These load data into the datasources for Tableau
--*********************************************************************************************
if exists (select * from dbo.sysobjects where id = object_id(N'tb_PickLines') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure tb_PickLines
GO
--exec tb_PickLines
CREATE PROCEDURE tb_PickLines
AS
BEGIN
SET NOCOUNT ON


SELECT 
df.FacilityName,
fi.LocationID,
fi.BlueBinFlag,
Cast(fi.IssueDate AS DATE) AS Date,
Count(*) AS PickLine
FROM   bluebin.FactIssue fi
inner join bluebin.DimFacility df on fi.ShipFacilityKey = df.FacilityID
--WHERE fi.IssueDate > getdate() -15 and fi.LocationID in (select ConfigValue from bluebin.Config where ConfigName = 'LOCATION')
GROUP  BY df.FacilityName,fi.LocationID,fi.BlueBinFlag,Cast(fi.IssueDate AS DATE)
order by 1,2,3 


END
GO
grant exec on tb_PickLines to public
GO


--*********************************************************************************************
--Tableau Sproc  These load data into the datasources for Tableau
--*********************************************************************************************


if exists (select * from dbo.sysobjects where id = object_id(N'tb_HBPickLines') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure tb_HBPickLines
GO
--exec tb_HBPickLines
CREATE PROCEDURE tb_HBPickLines
AS
BEGIN
SET NOCOUNT ON


SELECT 
df.FacilityName,
fi.LocationID,
Cast(fi.IssueDate AS DATE) AS Date,
Count(*) AS PickLine
FROM   bluebin.FactIssue fi
inner join bluebin.DimFacility df on fi.ShipFacilityKey = df.FacilityID

WHERE fi.IssueDate > getdate() -15 and fi.LocationID in (select ConfigValue from bluebin.Config where ConfigName = 'PS_BUSINESSUNIT') --Filter for HB

GROUP  BY df.FacilityName,fi.LocationID,Cast(fi.IssueDate AS DATE)
order by 1,2,3 



END
GO
grant exec on tb_HBPickLines to public
GO


--*********************************************************************************************
--Tableau Sproc  These load data into the datasources for Tableau
--*********************************************************************************************

if exists (select * from dbo.sysobjects where id = object_id(N'tb_QCNDashboard') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure tb_QCNDashboard
GO

--exec tb_QCNDashboard 
CREATE PROCEDURE tb_QCNDashboard

--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON

select 
	q.[QCNID],
	df.FacilityName,
	q.[LocationID],
        case
		when q.[LocationID] = 'Multiple' then q.LocationID
		else dl.[LocationName] end as LocationName,
		db.BinSequence,
	q.RequesterUserID  as RequesterUserName,
        '' as RequesterLogin,
    '' as RequesterTitleName,
    case when v.UserLogin = 'None' then '' else v.LastName + ', ' + v.FirstName end as AssignedUserName,
        v.[UserLogin] as AssignedLogin,
    v.[Title] as AssignedTitleName,
	qt.Name as QCNType,
q.[ItemID],
di.[ItemClinicalDescription],
q.Par as Par,
q.UOM as UOM,
q.ManuNumName as [ItemManufacturer],
q.ManuNumName as [ItemManufacturerNumber],
	q.[Details] as [DetailsText],
            case when q.[Details] ='' then 'No' else 'Yes' end Details,
	q.[Updates] as [UpdatesText],
            case when q.[Updates] ='' then 'No' else 'Yes' end Updates,
	case when qs.Status in ('Completed','Rejected') then convert(int,(q.[DateCompleted] - q.[DateEntered]))
		else convert(int,(getdate() - q.[DateEntered])) end as DaysOpen,
    q.[DateEntered],
	q.[DateCompleted],
	qs.Status,
    '' as BinStatus,
    q.[LastUpdated]
from [qcn].[QCN] q
left join [bluebin].[DimBin] db on q.LocationID = db.LocationID and rtrim(q.ItemID) = rtrim(db.ItemID)
left join [bluebin].[DimItem] di on rtrim(q.ItemID) = rtrim(di.ItemID)
        left join [bluebin].[DimLocation] dl on q.LocationID = dl.LocationID and dl.BlueBinFlag = 1
--inner join [bluebin].[BlueBinResource] u on q.RequesterUserID = u.BlueBinResourceID
left join [bluebin].[BlueBinUser] v on q.AssignedUserID = v.BlueBinUserID
inner join [qcn].[QCNType] qt on q.QCNTypeID = qt.QCNTypeID
inner join [qcn].[QCNStatus] qs on q.QCNStatusID = qs.QCNStatusID
left join bluebin.DimFacility df on q.FacilityID = df.FacilityID

WHERE q.Active = 1 
            order by q.[DateEntered] asc--,convert(int,(getdate() - q.[DateEntered])) desc

END
GO
grant exec on tb_QCNDashboard to public
GO

--*********************************************************************************************
--Tableau Sproc  These load data into the datasources for Tableau
--*********************************************************************************************




--*********************************************************************************************
--Tableau Sproc  These load data into the datasources for Tableau
--*********************************************************************************************

if exists (select * from dbo.sysobjects where id = object_id(N'tb_StatCalls') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure tb_StatCalls
GO


--exec tb_StatCalls
CREATE PROCEDURE tb_StatCalls
AS
BEGIN
SET NOCOUNT ON

declare @Facility int
   select @Facility = ConfigValue from bluebin.Config where ConfigName = 'PS_DefaultFacility'

SELECT 
case when @Facility is not null or @Facility <> '' then @Facility else ''end as FROM_TO_CMPY,
case when @Facility is not null or @Facility <> '' then (select FacilityName from bluebin.DimFacility where FacilityID = @Facility) else ''end as FacilityName,
lt.LOCATION as LocationID,
lt.DESCR as LocationName,
ISNULL(dl.BlueBinFlag,0) as BlueBinFlag,
DEMAND_DATE       AS [Date],
COUNT(*) as StatCalls,
'' as Department

FROM   dbo.IN_DEMAND
       INNER JOIN dbo.LOCATION_TBL lt on IN_DEMAND.LOCATION = lt.LOCATION
	   LEFT JOIN bluebin.DimLocation dl ON lt.LOCATION = dl.LocationID

WHERE  PICK_BATCH_ID = 0
       AND BUSINESS_UNIT in (Select ConfigValue from bluebin.Config where ConfigName = 'PS_BUSINESSUNIT')
	   AND (IN_FULFILL_STATE in (select ConfigValue from bluebin.Config where ConfigName = 'PS_InFulfillState') or IN_FULFILL_STATE is null)
GROUP BY
--DimLocation.LocationID,
--DimLocation.LocationName,
lt.LOCATION,
lt.DESCR,
dl.BlueBinFlag,
DEMAND_DATE
Order by DEMAND_DATE


END
GO
grant exec on tb_StatCalls to public
GO

--*********************************************************************************************
--Tableau Sproc  These load data into the datasources for Tableau
--*********************************************************************************************

--****************************
--Must exec etl_DimWarehouseItem to make changes visible for tb_WarehouseSize
--****************************
exec etl_DimWarehouseItem
GO
--****************************


if exists (select * from dbo.sysobjects where id = object_id(N'tb_WarehouseSize') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure tb_WarehouseSize
GO

--exec tb_WarehouseSize

CREATE PROCEDURE tb_WarehouseSize

--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON

SELECT 
       a.FacilityName,
	   a.LocationID,
	   a.LocationName,
	   a.ItemID,
       a.ItemDescription,
       a.ItemClinicalDescription,
       a.ItemManufacturer,
       a.ItemManufacturerNumber,
       a.StockLocation,
       a.SOHQty,
       a.ReorderQty,
       a.ReorderPoint,
       a.UnitCost,
	   c.LastPODate,
	   a.StockUOM as UOM
       ,'' AS LYYTDIssueQty,
       '' AS CYYTDIssueQty
FROM   bluebin.DimWarehouseItem a
       --LEFT JOIN ICTRANS b
       --        ON ltrim(rtrim(a.ItemID)) = ltrim(rtrim(ITEM)) 
		LEFT JOIN bluebin.DimItem c
			   ON a.ItemKey = c.ItemKey
WHERE  SOHQty > 0 --b.DOC_TYPE = 'IS' and Year(b.TRANS_DATE) >= Year(Getdate()) - 1
GROUP  BY 
a.FacilityName,
a.LocationID,
			a.LocationName,
			a.ItemID,
          a.ItemDescription,
          a.ItemClinicalDescription,
          a.ItemManufacturer,
          a.ItemManufacturerNumber,
          a.StockLocation,
          a.SOHQty,
          a.ReorderQty,
          a.ReorderPoint,
          a.UnitCost,
		  c.LastPODate,
		  a.StockUOM 

END
GO
grant exec on tb_WarehouseSize to public
GO



--*********************************************************************************************
--Tableau Sproc  These load data into the datasources for Tableau
--*********************************************************************************************
--****************************
--Must exec etl_FactWarehouseSnapshot to make changes visible for tb_WarehouseSnapshot
--****************************
exec etl_FactWarehouseSnapshot
GO
--****************************


if exists (select * from dbo.sysobjects where id = object_id(N'tb_WarehouseSnapshot') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure tb_WarehouseSnapshot
GO

--exec tb_WarehouseSnapshot
CREATE PROCEDURE tb_WarehouseSnapshot

--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON
SELECT 
	--count(ITEM),
	
	SnapshotDate,
	FacilityName,
	'' as DollarsOnHand,
	LocationID,
	LocationID as LocationName
FROM bluebin.FactWarehouseSnapshot a
WHERE a.SOH > 0
GROUP BY
	
	SnapshotDate,
	FacilityName,
	LocationID 
;


END
GO
grant exec on tb_WarehouseSnapshot to public
GO



--*********************************************************************************************
--Tableau Sproc  These load data into the datasources for Tableau
--*********************************************************************************************
IF EXISTS ( SELECT  *
            FROM    sys.objects
            WHERE   object_id = OBJECT_ID(N'tb_Training')
                    AND type IN ( N'P', N'PC' ) ) 

DROP PROCEDURE  tb_Training
GO

CREATE PROCEDURE tb_Training

AS

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
left join (select BlueBinResourceID,count(*) as Ct from [bluebin].[Training] where Active = 1 and Status = 'Teach' group by BlueBinResourceID) trained on bbt.[BlueBinResourceID] = trained.[BlueBinResourceID]
left join (select BlueBinResourceID,count(*) as Ct from [bluebin].[Training] where Active = 1 and Status <> 'Teach' group by BlueBinResourceID) nottrained on bbt.[BlueBinResourceID] = nottrained.[BlueBinResourceID]
WHERE 
bbt.Active = 1 

	
ORDER BY bbr.[LastName]

GO

grant exec on tb_Training to public
GO
--*********************************************************************************************
--Tableau Sproc  These load data into the datasources for Tableau
--*********************************************************************************************

if exists (select * from dbo.sysobjects where id = object_id(N'tb_GembaDashboard') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure tb_GembaDashboard
GO

--exec tb_GembaDashboard 
CREATE PROCEDURE tb_GembaDashboard

--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON

select 
	g.[GembaAuditNodeID],
	df.FacilityName,
	dl.[LocationID],
	g.LocationID as AuditLocationID,
        dl.[LocationName],
			dl.BlueBinFlag,
	u.LastName + ', ' + u.FirstName  as Auditer,
    u.[UserLogin] as Login,
	u.Title as RoleName,
	u.GembaTier,
	g.PS_TotalScore,
	g.RS_TotalScore,
	g.SS_TotalScore,
	g.NIS_TotalScore,
	g.TotalScore,
	case when TotalScore < 90 then 1 else 0 end as ScoreUnder,
	(select count(*) from bluebin.DimLocation where BlueBinFlag = 1) as LocationCount,
    g.[Date],
	g2.[MaxDate] as LastAuditDate,
	case 
		when g.[Date] is null then 365
		else convert(int,(getdate() - g2.[MaxDate])) end as LastAudit,
	tier1.[MaxDate] as LastAuditDateTier1,
	case 
		when g.[Date] is null  and tier1.[MaxDate] is null or g2.[MaxDate] is not null and dl.LocationID not in (select LocationID from [gemba].[GembaAuditNode] where AuditerUserID in (select BlueBinUserID from bluebin.BlueBinUser where GembaTier = 'Tier1')) then 365
		else convert(int,(getdate() - tier1.[MaxDate])) end as LastAuditTier1,
	tier2.[MaxDate] as LastAuditDateTier2,	
	case 
		when g.[Date] is null  and tier2.[MaxDate] is null or g2.[MaxDate] is not null and dl.LocationID not in (select LocationID from [gemba].[GembaAuditNode] where AuditerUserID in (select BlueBinUserID from bluebin.BlueBinUser where GembaTier = 'Tier2')) then 365
		else convert(int,(getdate() - tier2.[MaxDate])) end as LastAuditTier2,
	tier3.[MaxDate] as LastAuditDateTier3,	
	case 
		when g.[Date] is null and tier3.[MaxDate] is null  or g2.[MaxDate] is not null and dl.LocationID not in (select LocationID from [gemba].[GembaAuditNode] where AuditerUserID in (select BlueBinUserID from bluebin.BlueBinUser where GembaTier = 'Tier3')) then 365
		else convert(int,(getdate() - tier3.[MaxDate])) end as LastAuditTier3,
		
    g.[LastUpdated]
from  [bluebin].[DimLocation] dl
		left join [gemba].[GembaAuditNode] g on dl.LocationID = g.LocationID
		left join (select Max([Date]) as MaxDate,LocationID from [gemba].[GembaAuditNode] group by LocationID) g2 on dl.LocationID = g2.LocationID and g.[Date] = g2.MaxDate
		left join (select Max([Date]) as MaxDate,LocationID from [gemba].[GembaAuditNode] where AuditerUserID in (select BlueBinUserID from bluebin.BlueBinUser where GembaTier = 'Tier1') group by LocationID) tier1 on dl.LocationID = tier1.LocationID and g.[Date] = tier1.MaxDate
		left join (select Max([Date]) as MaxDate,LocationID from [gemba].[GembaAuditNode] where AuditerUserID in (select BlueBinUserID from bluebin.BlueBinUser where GembaTier = 'Tier2') group by LocationID) tier2 on dl.LocationID = tier2.LocationID and g.[Date] = tier2.MaxDate
		left join (select Max([Date]) as MaxDate,LocationID from [gemba].[GembaAuditNode] where AuditerUserID in (select BlueBinUserID from bluebin.BlueBinUser where GembaTier = 'Tier3') group by LocationID) tier3 on dl.LocationID = tier3.LocationID and g.[Date] = tier3.MaxDate
        --left join [bluebin].[DimLocation] dl on g.LocationID = dl.LocationID and dl.BlueBinFlag = 1
		left join [bluebin].[BlueBinUser] u on g.AuditerUserID = u.BlueBinUserID
		left join bluebin.BlueBinRoles bbr on u.RoleID = bbr.RoleID
		left join bluebin.DimFacility df on dl.LocationFacility = df.FacilityID
WHERE dl.BlueBinFlag = 1 and g.Active = 1
            order by dl.LocationID,[Date] asc

END
GO
grant exec on tb_GembaDashboard to public
GO





--*********************************************************************************************
--Tableau Sproc  These load data into the datasources for Tableau
--*********************************************************************************************
if exists (select * from dbo.sysobjects where id = object_id(N'tb_KanbansAdjusted') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure tb_KanbansAdjusted
GO

--exec tb_KanbansAdjusted

CREATE PROCEDURE [dbo].[tb_KanbansAdjusted] 
	
AS

BEGIN

select * from 
(
select 
DATEPART(WEEK,dbh.[Date]) as [Week]
,dbh.[Date]
--,dbh.[Date]-1 as Yesterday
,dbh.FacilityID
,df.FacilityName
,dbh.LocationID
,dl.LocationName
,dbh.ItemID
,di.ItemDescription
,dbh.BinQty as BinQty
,dbh.LastBinQty as YestBinQty
,dbh.BinUOM
,dbh.LastBinUOM as YestBinUOM
,dbh.Sequence
,dbh.LastSequence as YestSequence
,ISNULL(a.OrderQty,0) as OrderQty
,ISNULL(a.OrderUOM,'N/A') as OrderUOM
,case when (dbh.BinQty <> dbh.LastBinQty or dbh.Sequence <> dbh.LastSequence) and dbh.LastBinQty >= 1 and dbh.LastSequence <> 'N/A' then 1 else 0 end as BinChange
,case when a.OrderQty is not null and a.OrderQty <> a.BinQty and a.OrderUOM = a.BinUOM and a.BinCurrentStatus <> 'Never Scanned' then 1 else 0 end as BinOrderChange
,a.BinCurrentStatus

from bluebin.DimBinHistory dbh
inner join tableau.Kanban a on dbh.FacilityID = a.FacilityID and dbh.LocationID = a.LocationID and dbh.ItemID = a.ItemID and dbh.[Date] = a.[Date]
inner join bluebin.DimFacility df on a.FacilityID = df.FacilityID
inner join bluebin.DimLocation dl on a.LocationID = dl.LocationID
inner join bluebin.DimItem di on a.ItemID = di.ItemID


where dbh.[Date] >= getdate() -7 
--and a.LocationID = 'B7435' and a.ItemID = '30003' 
--order by dbh.FacilityID,dbh.LocationID,dbh.ItemID
) a
where BinChange = 1 or BinOrderChange = 1
order by FacilityID,LocationID,ItemID

END
GO
grant exec on tb_KanbansAdjusted to public
GO



--*********************************************************************************************
--Tableau Sproc  These load data into the datasources for Tableau
--*********************************************************************************************

if exists (select * from dbo.sysobjects where id = object_id(N'tb_JobStatus') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure tb_JobStatus
GO

--exec tb_JobStatus 'Demo'

CREATE PROCEDURE [dbo].[tb_JobStatus] 
@db nvarchar(20)
	
AS

BEGIN

declare @SQL nvarchar(max)


SET @SQL = 

'Use [' + @db + ']

Select ''' + @db + ''' as [Database]
select ''' + @db + ''' as [Database],a.BinSnapshotDate,Count(*) from tableau.Kanban a
inner join (select max(BinSnapshotDate) as MaxDate from tableau.Kanban) as b on a.BinSnapshotDate = b.MaxDate
group by a.BinSnapshotDate

select ''' + @db + ''' as [Database],ProcessID,StartTime,EndTime,Duration,Result from etl.JobHeader where StartTime > getdate() -.5 order by StartTime desc
select ''' + @db + ''' as [Database],ProcessID,StepName,StartTime,EndTime,Duration,[RowCount],Result,Message from etl.JobDetails where StartTime > getdate() -.5 order by StartTime desc
select ''' + @db + ''' as [Database],StepNumber,StepName,StepTable,ActiveFlag,LastModifiedDate from etl.JobSteps  order by ActiveFlag,StepNumber
'


EXEC (@SQL)

END
GO
grant exec on tb_JobStatus to public
GO



--*********************************************************************************************
--Tableau Sproc  These load data into the datasources for Tableau
--*********************************************************************************************




IF EXISTS ( SELECT  *
            FROM    sys.objects
            WHERE   object_id = OBJECT_ID(N'tb_OrderVolume')
                    AND type IN ( N'P', N'PC' ) ) 

DROP PROCEDURE  tb_OrderVolume
GO

CREATE PROCEDURE	tb_OrderVolume
--exec tb_OrderVolume  
AS

SET NOCOUNT on
declare @Facility int
   select @Facility = ConfigValue from bluebin.Config where ConfigName = 'PS_DefaultFacility'
  

select 
rh.REQ_DT as CREATION_DATE,
@Facility as COMPANY,
df.FacilityName,
rd.LOCATION as REQ_LOCATION,
rq.REQ_ID,
rq.LINE_NBR as Lines,
rh.REQUESTOR_ID as Name,
dl.BlueBinFlag
from REQ_LINE rq
INNER JOIN REQ_LN_DISTRIB rd on rq.REQ_ID = rd.REQ_ID
inner join REQ_HDR rh on rq.REQ_ID = rh.REQ_ID
inner join bluebin.DimLocation dl on @Facility = rtrim(dl.LocationFacility) and rd.LOCATION = dl.LocationID
inner join bluebin.DimFacility df on @Facility = rtrim(df.FacilityID)
--left join REQUESTER r on rh.REQUESTER = r.REQUESTER and rq.COMPANY = r.COMPANY
where rh.REQ_DT > getdate()-15



GO
grant exec on tb_OrderVolume to public
GO


--*********************************************************************************************
--Tableau Sproc  These load data into the datasources for Tableau
--*********************************************************************************************

IF EXISTS ( SELECT  *
            FROM    sys.objects
            WHERE   object_id = OBJECT_ID(N'tb_TodaysOrders')
                    AND type IN ( N'P', N'PC' ) ) 

DROP PROCEDURE  tb_TodaysOrders
GO

CREATE PROCEDURE	tb_TodaysOrders
--exec tb_TodaysOrders  
AS

SET NOCOUNT on
;

DECLARE @EndDateConfig varchar(20), @TodayDate Datetime
	select @EndDateConfig = ConfigValue from bluebin.Config where ConfigName = 'ReportDateEnd'
	select @TodayDate = case when @EndDateConfig = 'Current' then getdate() -1 else convert(date,getdate()-1,112) end
;	

With list as 
(
			select distinct
			db.BinFacility as COMPANY,
			db.LocationID as REQ_LOCATION,
			dl.LocationName
			from bluebin.FactScan fs
			inner join bluebin.DimBin db on fs.BinKey = db.BinKey
			inner join bluebin.DimLocation dl on db.LocationID = dl.LocationID and dl.BlueBinFlag = 1
			where fs.OrderDate > getdate() -32
			)


select 
convert(datetime,(convert(DATE,getdate()-1)),112) as CREATION_DATE,
[list].COMPANY,
df.FacilityName as FacilityName,
[list].REQ_LOCATION,
[list].LocationName,
ISNULL([current].Lines,0) as TodayLines,
--ISNULL([past].Lines,0) as YestLines,
--CAST([past].Lines as decimal(6,2))/30,
--ROUND(CAST([past].Lines as decimal(6,2))/30,0),
CAST(ISNULL(ROUND(CAST([past].Lines as decimal(6,2))/30,0),0)as int) as YestLines,
case 
	when ISNULL([current].Lines,0) > CAST(ISNULL(ROUND(CAST([past].Lines as decimal(6,2))/30,0),0)as int) then 'UP' 
	when ISNULL([current].Lines,0) < CAST(ISNULL(ROUND(CAST([past].Lines as decimal(6,2))/30,0),0)as int) then 'DOWN'
	else 'EVEN' end as Trend

from 

list
inner join bluebin.DimFacility df on list.COMPANY = df.FacilityID		

left join(
			select
			db.BinFacility as COMPANY,
			db.LocationID as REQ_LOCATION,
			count(*) as Lines
			from bluebin.FactScan fs
			inner join bluebin.DimBin db on fs.BinKey = db.BinKey
			inner join bluebin.DimLocation dl on db.LocationID = dl.LocationID and dl.BlueBinFlag = 1
			where fs.OrderDate > getdate() -32 and fs.OrderDate < getdate() -2
			group by
			db.BinFacility,
			db.LocationID
			)
			[past] on list.COMPANY = past.COMPANY and list.REQ_LOCATION = past.REQ_LOCATION
			
--Todays Data
left join (

select
			db.BinFacility as COMPANY,
			db.LocationID as REQ_LOCATION,
			count(*) as Lines
			from bluebin.FactScan fs
			inner join bluebin.DimBin db on fs.BinKey = db.BinKey
			inner join bluebin.DimLocation dl on db.LocationID = dl.LocationID and dl.BlueBinFlag = 1
			where fs.OrderDate > @TodayDate
			group by
			db.BinFacility,
			db.LocationID

			) [current] on list.COMPANY = [current].COMPANY and list.REQ_LOCATION = [current].REQ_LOCATION
 
order by [list].REQ_LOCATION


GO
grant exec on tb_TodaysOrders to public
GO





--*********************************************************************************************
--Tableau Sproc  These load data into the datasources for Tableau
--*********************************************************************************************

if exists (select * from dbo.sysobjects where id = object_id(N'tb_StatCallsLocation') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure tb_StatCallsLocation
GO

--exec tb_StatCallsLocation
CREATE PROCEDURE tb_StatCallsLocation
AS
BEGIN
SET NOCOUNT ON
declare @Facility int
   select @Facility = ConfigValue from bluebin.Config where ConfigName = 'PS_DefaultFacility'

SELECT 
case when @Facility is not null or @Facility <> '' then @Facility else ''end as FROM_TO_CMPY,
case when @Facility is not null or @Facility <> '' then (select FacilityName from bluebin.DimFacility where FacilityID = @Facility) else ''end as FacilityName,
lt.LOCATION as LocationID,
lt.DESCR as LocationName,
ISNULL(dl.BlueBinFlag,0) as BlueBinFlag,
DEMAND_DATE       AS [Date],
COUNT(*) as StatCalls,
'' as Department

FROM   dbo.IN_DEMAND
       INNER JOIN dbo.LOCATION_TBL lt on IN_DEMAND.LOCATION = lt.LOCATION
	   LEFT JOIN bluebin.DimLocation dl ON lt.LOCATION = dl.LocationID

WHERE  PICK_BATCH_ID = 0
       AND BUSINESS_UNIT in (Select ConfigValue from bluebin.Config where ConfigName = 'PS_BUSINESSUNIT')
	   AND (IN_FULFILL_STATE in (select ConfigValue from bluebin.Config where ConfigName = 'PS_InFulfillState') or IN_FULFILL_STATE is null)
GROUP BY
--DimLocation.LocationID,
--DimLocation.LocationName,
lt.LOCATION,
lt.DESCR,
dl.BlueBinFlag,
DEMAND_DATE
Order by DEMAND_DATE




END
GO
grant exec on tb_StatCallsLocation to public
GO



--*********************************************************************************************
--Tableau Sproc  These load data into the datasources for Tableau
--*********************************************************************************************

if exists (select * from dbo.sysobjects where id = object_id(N'etl_DimBinHistory') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure etl_DimBinHistory
GO

--exec etl_DimBinHistory

CREATE PROCEDURE [dbo].[etl_DimBinHistory] 
	
AS

/*
select * from bluebin.DimBinHistory where LastSequence = 'N/A' order by FacilityID,LocationID,ItemID,Date
select * from bluebin.DimBin where LocationID = 'B6183' and ItemID = '700'  
select * from tableau.Kanban where LocationID = 'B6183' and ItemID = '700' and convert(Date,[Date]) = convert(Date,getdate()-1)
update bluebin.DimBinHistory set LastUpdated = getdate() -3 where DimBinHistoryID = 6161
truncate table bluebin.DimBinHistory
*/
Delete from bluebin.DimBinHistory where [Date] < convert(Date,getdate()-100)


IF (select count(*) from bluebin.DimBinHistory) < 1
BEGIN
insert into bluebin.DimBinHistory ([Date],BinKey,FacilityID,LocationID,ItemID,BinQty,BinUOM,[Sequence],LastBinQty,LastBinUOM,[LastSequence]) 
select convert(Date,getdate()-2),BinKey,BinFacility,LocationID,ItemID,BinQty,BinUOM,BinSequence,BinQty,BinUOM,BinSequence from bluebin.DimBin

insert into bluebin.DimBinHistory ([Date],BinKey,FacilityID,LocationID,ItemID,BinQty,BinUOM,[Sequence],LastBinQty,LastBinUOM,[LastSequence]) 
select convert(Date,getdate()-1),BinKey,BinFacility,LocationID,ItemID,BinQty,BinUOM,BinSequence,BinQty,BinUOM,BinSequence from bluebin.DimBin
END

if not exists (select * from bluebin.DimBinHistory where [Date] = convert(Date,getdate()-1))
BEGIN

insert into bluebin.DimBinHistory ([Date],BinKey,FacilityID,LocationID,ItemID,BinQty,BinUOM,[Sequence],LastBinQty,LastBinUOM,[LastSequence]) 
select convert(Date,getdate()-1),db.BinKey,db.BinFacility,db.LocationID,db.ItemID,convert(int,db.BinQty),db.BinUOM,db.BinSequence,ISNULL(dbh.BinQty,0),ISNULL(dbh.BinUOM,'N/A'),ISNULL(dbh.Sequence,'N/A')
from bluebin.DimBin db
left join bluebin.DimBinHistory dbh on db.BinFacility = dbh.FacilityID and db.LocationID = dbh.LocationID and db.ItemID = dbh.ItemID and dbh.[Date] = convert(Date,getdate()-2)
END



GO
UPDATE etl.JobSteps
SET LastModifiedDate = GETDATE()
WHERE StepName = 'DimBinHistory'

GO
grant exec on etl_DimBinHistory to public
GO

--*********************************************************************************************
--Tableau Sproc  These load data into the datasources for Tableau
--*********************************************************************************************

if exists (select * from dbo.sysobjects where id = object_id(N'tb_ConesDeployed') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure tb_ConesDeployed
GO

--exec tb_ConesDeployed 

CREATE PROCEDURE tb_ConesDeployed


--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON
	SELECT 
	cd.ConeDeployed,
	cd.Deployed,
	cd.ExpectedDelivery,
	cd.ConeReturned,
	cd.Returned,
	df.FacilityID,
	df.FacilityName,
	dl.LocationID,
	dl.LocationName,
	di.ItemID,
	di.ItemDescription,
	db.BinSequence,
	cd.SubProduct,
	other.LocationID as AllLocations
	
	FROM bluebin.[ConesDeployed] cd
	inner join bluebin.DimFacility df on cd.FacilityID = df.FacilityID
	inner join bluebin.DimLocation dl on cd.LocationID = dl.LocationID
	inner join bluebin.DimItem di on cd.ItemID = di.ItemID
	inner join bluebin.DimBin db on df.FacilityID = db.BinFacility and dl.LocationID = db.LocationID and di.ItemID = db.ItemID
		inner join (
					SELECT 
				   il1.ItemID,
				   STUFF((SELECT  ', ' + rtrim(il2.LocationID) 
				  FROM bluebin.DimBin il2
				  where il2.ItemID = il1.ItemID 
				  order by il2.LocationID
				  FOR XML PATH('')), 1, 1, '') [LocationID]
						FROM bluebin.DimBin il1 
						GROUP BY il1.ItemID )other on cd.ItemID = other.ItemID
	where cd.Deleted = 0 and ConeReturned = 0
END
GO
grant exec on tb_ConesDeployed to appusers
GO



--*********************************************************************************************
--Tableau Sproc  These load data into the datasources for Tableau
--*********************************************************************************************

IF EXISTS ( SELECT  *
            FROM    sys.objects
            WHERE   object_id = OBJECT_ID(N'tb_FillRateUtilization')
                    AND type IN ( N'P', N'PC' ) ) 

--exec tb_FillRateUtilization
DROP PROCEDURE  tb_FillRateUtilization
GO

CREATE PROCEDURE tb_FillRateUtilization

AS

select 
[Date],
FacilityID,
FacilityName,
LocationID,
LocationName,
Sum(Scan) as Scans,
Sum(StockOut) as StockOuts,
sum((case when DaysSinceLastScan >=90 then 0 else 1 end)) as LessThan90LastScan,
(count(BinKey)) as TotalBins
from tableau.Kanban

where [Date] > getdate() -14
group by 
[Date],
FacilityID,
FacilityName,
LocationID,
LocationName



GO

grant exec on tb_FillRateUtilization to public
GO

--*********************************************************************************************
--Tableau Sproc  These load data into the datasources for Tableau
--*********************************************************************************************

IF EXISTS ( SELECT  *
            FROM    sys.objects
            WHERE   object_id = OBJECT_ID(N'tb_CurrentStockOuts')
                    AND type IN ( N'P', N'PC' ) ) 

--exec tb_CurrentStockOuts
DROP PROCEDURE  tb_CurrentStockOuts
GO

CREATE PROCEDURE tb_CurrentStockOuts

AS

select 
[Date],
FacilityID,
FacilityName,
LocationID,
LocationName,
ItemID,
ItemDescription,
OrderDate,
OrderNum,
LineNum,
OrderQty
from tableau.Kanban

where [Date] > getdate() -90 and StockOut = 1  and ScanHistseq > (select ConfigValue from bluebin.Config where ConfigName = 'ScanThreshold') and OrderCloseDate is null

UNION

select
scan.Date,
scan.FacilityID,
df.FacilityName,
scan.LocationID,
dl.LocationName,
scan.ItemID,
di.ItemDescription,
scan.Date as OrderDate,
scan.ScanBatchID as OrderNum,
max(sl.Line) as LineNum,
max(sl.Qty) as OrderQty
from (
select convert(Date,sl.ScanDateTime,112) as Date,sb.ScanBatchID,sb.FacilityID,sb.LocationID,sl.ItemID,count(*) as Ct
from scan.ScanLine sl
inner join scan.ScanBatch sb on sl.ScanBatchID = sb.ScanBatchID
where sb.ScanType = 'TrayOrder' and sb.Active = 1 and convert(Date,sl.ScanDateTime,112) = convert(Date,getdate(),112)
group by convert(Date,sl.ScanDateTime,112),sb.ScanBatchID,sb.FacilityID,sb.LocationID,sl.ItemID
) scan
inner join scan.ScanLine sl on scan.ScanBatchID = sl.ScanBatchID and scan.ItemID = sl.ItemID and scan.Ct > 1
inner join bluebin.DimFacility df on scan.FacilityID = df.FacilityID
inner join bluebin.DimLocation dl on scan.LocationID = dl.LocationID
inner join bluebin.DimItem di on scan.ItemID = di.ItemID
where scan.Ct > 1
group by scan.Date,
scan.FacilityID,
df.FacilityName,
scan.LocationID,
dl.LocationName,
scan.ItemID,
di.ItemDescription,
scan.Date,
scan.ScanBatchID

order by LocationID
GO

grant exec on tb_CurrentStockOuts to public
GO
--*********************************************************************************************
--Tableau Sproc  These load data into the datasources for Tableau
--*********************************************************************************************

--*********************************************************************************************
--Tableau Sproc  These load data into the datasources for Tableau
--*********************************************************************************************

--*********************************************************************************************
--Tableau Sproc  These load data into the datasources for Tableau
--*********************************************************************************************

IF EXISTS ( SELECT  *
            FROM    sys.objects
            WHERE   object_id = OBJECT_ID(N'tb_HealthTrends')
                    AND type IN ( N'P', N'PC' ) ) 

--exec tb_HealthTrends
DROP PROCEDURE  tb_HealthTrends
GO

CREATE PROCEDURE tb_HealthTrends

AS




WITH A as (
select
[Date],
BinKey,
BinStatus
from tableau.Kanban
where [Date] > getdate() -90
group by
[Date],
BinKey,
BinStatus )


select 
A.[Date],
df.FacilityID,
df.FacilityName,
dl.LocationID,
dl.LocationName,
A.BinStatus,
count(A.BinStatus) as Count

from A
inner join bluebin.DimBin db on A.BinKey = db.BinKey
inner join bluebin.DimLocation dl on db.LocationID = dl.LocationID 
inner join bluebin.DimFacility df on db.BinFacility = df.FacilityID
group by
A.[Date],
df.FacilityID,
df.FacilityName,
dl.LocationID,
dl.LocationName,
A.BinStatus

order by
A.[Date],
df.FacilityID,
df.FacilityName,
dl.LocationID,
dl.LocationName,
A.BinStatus 

GO

grant exec on tb_HealthTrends to public
GO




--*********************************************************************************************
--Tableau Sproc  These load data into the datasources for Tableau
--*********************************************************************************************
if exists (select * from dbo.sysobjects where id = object_id(N'tb_QCNTimeline') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure tb_QCNTimeline
GO

--select * from qcn.QCN
--exec tb_QCNTimeline 
CREATE PROCEDURE tb_QCNTimeline

--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON

--Main query off of the subs to pull the Date, Facility, Location then takes a running total of Opened/Closed and displays.
select
LastDay,
[Date],
WeekName,
FacilityID,
FacilityName,
--LocationID,
--LocationName,
OpenedCt,
ClosedCt,
((SUM(OpenedCt) OVER (PARTITION BY FacilityID ORDER BY [Date] ROWS UNBOUNDED PRECEDING))-(SUM(ClosedCt) OVER (PARTITION BY FacilityID ORDER BY [Date] ROWS UNBOUNDED PRECEDING))) as RunningTotal
	
from
	(select
	LastDay,
	[Date],
	WeekName,
	FacilityID,
	FacilityName,
	--LocationID,
	--LocationName,
	sum(OpenedCt) as OpenedCt,
	sum(ClosedCt) as ClosedCt
	from (
		select 
		 (DATEADD(dd, @@DATEFIRST - DATEPART(dw, dd.Date), dd.Date)) as LastDay,
		 convert(varchar(4),datepart(yyyy,dd.Date))+right(('0'+convert(varchar(2),datepart(ww,dd.Date))),2)as [Date],
		 convert(varchar(4),datepart(yyyy,dd.Date))+' W'+right(('0'+convert(varchar(2),datepart(ww,dd.Date))),2)+' '+
		 left(DATENAME(Month,CONVERT(varchar(50), (DATEADD(dd, @@DATEFIRST - DATEPART(dw, dd.Date), dd.Date)-6), 101)),3)+' '+SUBSTRING(CONVERT(varchar(50), (DATEADD(dd, @@DATEFIRST - DATEPART(dw, dd.Date), dd.Date)-6), 101),4,2)
				+'-'+
					left(DATENAME(Month,CONVERT(varchar(50), (DATEADD(dd, @@DATEFIRST - DATEPART(dw, dd.Date), dd.Date)), 101)),3)+' '+SUBSTRING(CONVERT(varchar(50), (DATEADD(dd, @@DATEFIRST - DATEPART(dw, dd.Date), dd.Date)), 101),4,2) as WeekName,
		dd.FacilityID,
		dd.FacilityName,
		dd.LocationID,
		dd.LocationName,
		ISNULL(aa.OpenedCt,0) as OpenedCt,
		ISNULL(bb.ClosedCt,0) as ClosedCt

		from (
				--General query to populate a date for everyday for every Facility and Location
				select dd.Date,df.FacilityID,df.FacilityName,'Multiple' as LocationID,'Multiple' as LocationName from bluebin.DimDate dd,bluebin.DimFacility df
				UNION ALL
				select dd.Date,df.FacilityID,df.FacilityName,dl.LocationID,LocationName from bluebin.DimDate dd,bluebin.DimFacility df
				inner join bluebin.DimLocation dl on df.FacilityID = dl.LocationFacility and dl.BlueBinFlag = 1 
				where Date < getdate() +1 and Date > = (select min(DateEntered)-1 from qcn.QCN where Active = 1)) dd
			left join (
				--Query to pull all Opened QCNs by Facility and Location
				select 
						[Date],
						FacilityID,
						LocationID,
						OpenedCt
						from (
							select 
							dd.Date,
							q1.FacilityID,
							q1.LocationID,
							count(ISNULL(q1.DateEntered,0)) as OpenedCt
							from bluebin.DimDate dd
							left join qcn.QCN q1 on dd.Date = convert(date,q1.DateEntered,112) and q1.Active = 1
							where q1.FacilityID is not null and dd.Date < getdate() +1 and dd.Date > = (select min(DateEntered)-1 from qcn.QCN where Active = 1)
							group by dd.Date,q1.FacilityID,q1.LocationID
					
							 ) a
							 --order by FacilityID,LocationID,Date
							 ) aa on dd.Date = aa.Date and dd.FacilityID = aa.FacilityID and dd.LocationID = aa.LocationID
			left join (
				--Query to pull all Closed QCNs by Facility and Location
				select 
						[Date],
						FacilityID,
						LocationID,
						ClosedCt
						from (
							select 
							dd.Date,
							q2.FacilityID,
							q2.LocationID,
					
							count(ISNULL(q2.DateCompleted,0)) as ClosedCt
							from bluebin.DimDate dd
							left join qcn.QCN q2 on dd.Date = convert(date,q2.DateCompleted,112) and q2.Active = 1
							where q2.FacilityID is not null and dd.Date < getdate() +1 and dd.Date > = (select min(DateCompleted)-1 from qcn.QCN where Active = 1)
							group by dd.Date,q2.FacilityID,q2.LocationID
					
							 ) a
							 --order by FacilityID,LocationID,Date
							 ) bb on dd.Date = bb.Date  and dd.FacilityID = bb.FacilityID and dd.LocationID = bb.LocationID

		where dd.Date < getdate() +1 and dd.Date > = (select min(DateEntered)-1 from qcn.QCN where Active = 1) and (ISNULL(OpenedCt,0) + ISNULL(ClosedCt,0)) > 0 
		) b
	group by 
	LastDay,
	[Date],
	WeekName,
	FacilityID,
	FacilityName
	--LocationID,
	--LocationName
	) c 
order by FacilityID,Date desc




END
GO
grant exec on tb_QCNTimeline to public
GO



--*********************************************************************************************
--Tableau Sproc  These load data into the datasources for Tableau
--*********************************************************************************************

if exists (select * from dbo.sysobjects where id = object_id(N'tb_KanbansAdjustedHB') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure tb_KanbansAdjustedHB
GO

--exec tb_KanbansAdjustedHB

CREATE PROCEDURE [dbo].[tb_KanbansAdjustedHB] 
	
AS

BEGIN

select 
[Week],
[Date],
FacilityID,
FacilityName,
SUM(BinChange) as BinChange,
Sum(BinOrderChange) as BinOrderChange
from (
select 
DATEPART(WEEK,dbh.[Date]) as [Week]
,dbh.[Date]
--,dbh.[Date]-1 as Yesterday
,dbh.FacilityID
,df.FacilityName
,case when (dbh.BinQty <> dbh.LastBinQty or dbh.Sequence <> dbh.LastSequence) and dbh.LastBinQty > 0 then 1 else 0 end as BinChange
,case when a.OrderQty is not null and a.OrderQty <> a.BinQty and a.OrderUOM = a.BinUOM then 1 else 0 end as BinOrderChange


from bluebin.DimBinHistory dbh
inner join tableau.Kanban a on dbh.FacilityID = a.FacilityID and dbh.LocationID = a.LocationID and dbh.ItemID = a.ItemID and dbh.[Date] = a.[Date]
inner join bluebin.DimFacility df on a.FacilityID = df.FacilityID

where dbh.[Date] >= getdate() -7 

) a
group by 
[Week],
[Date],
FacilityID,
FacilityName 
order by FacilityID


END
GO
grant exec on tb_KanbansAdjustedHB to public
GO

--*********************************************************************************************
--Tableau Sproc  These load data into the datasources for Tableau
--*********************************************************************************************
--*********************************************************************************************
--Tableau Sproc  These load data into the datasources for Tableau
--*********************************************************************************************
--*********************************************************************************************
--Tableau Sproc  These load data into the datasources for Tableau
--*********************************************************************************************

IF EXISTS ( SELECT  *
            FROM    sys.objects
            WHERE   object_id = OBJECT_ID(N'tb_HealthTrendsHB')
                    AND type IN ( N'P', N'PC' ) ) 

--exec tb_HealthTrendsHB
DROP PROCEDURE  tb_HealthTrendsHB
GO

CREATE PROCEDURE tb_HealthTrendsHB

AS


WITH A as (
select
[Date],
BinKey,
BinStatus
from tableau.Kanban
where [Date] > getdate() -90
group by
[Date],
BinKey,
BinStatus )


select 
A.[Date],
df.FacilityID,
df.FacilityName,
'' as LocationID,
'' as LocationName,
A.BinStatus,
count(A.BinStatus) as Count

from A
inner join bluebin.DimBin db on A.BinKey = db.BinKey
inner join bluebin.DimFacility df on db.BinFacility = df.FacilityID
group by
A.[Date],
df.FacilityID,
df.FacilityName,
A.BinStatus

order by
A.[Date],
df.FacilityID,
df.FacilityName,
A.BinStatus 

GO

grant exec on tb_HealthTrendsHB to public
GO




--*********************************************************************************************
--Tableau Sproc  These load data into the datasources for Tableau
--*********************************************************************************************
if exists (select * from dbo.sysobjects where id = object_id(N'tb_ItemUsageSourcing') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure tb_ItemUsageSourcing
GO

--exec tb_ItemUsageSourcing

CREATE PROCEDURE tb_ItemUsageSourcing

--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON

select 
FacilityName,
LocationName,
ItemID,
ItemClinicalDescription,
BinUOM,
convert(int,TotalPar) as TotalPar,
[Month],
Sum(OrderQty) as OrderQty,
Sum(OrderQty*BinCurrentCost) as Cost
from (
	select
	k.FacilityName,
	dl.LocationName,
	k.ItemNumber as ItemID,
	di.ItemClinicalDescription,
	dateadd(month,datediff(month,0,k.[PODate]),0) as [Month],
	k.BuyUOM as BinUOM,
	k.QtyOrdered as OrderQty,
	db.BinQty as TotalPar,
	db.BinCurrentCost
	from tableau.Sourcing k
	inner join bluebin.DimBin db on k.PurchaseFacility = db.BinFacility and k.PurchaseLocation = db.LocationID and k.ItemNumber = db.ItemID
	inner join bluebin.DimLocation dl on k.PurchaseLocation = dl.LocationID
	inner join bluebin.DimItem di on k.ItemNumber = di.ItemID

	where k.QtyOrdered is not null and k.BlueBinFlag = 'Yes' 
	--and k.PODate > getdate() -10
	) a

group by
FacilityName,
LocationName,
ItemID,
ItemClinicalDescription,
BinUOM,
convert(int,TotalPar),
[Month]

END
GO
grant exec on tb_ItemUsageSourcing to public
GO



--*********************************************************************************************
--Tableau Sproc  These load data into the datasources for Tableau
--*********************************************************************************************
if exists (select * from dbo.sysobjects where id = object_id(N'tb_ItemUsageKanban') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure tb_ItemUsageKanban
GO

--exec tb_ItemUsageKanban
/*
select distinct PODate from tableau.Sourcing
*/
CREATE PROCEDURE tb_ItemUsageKanban

--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON

select 
FacilityName,
LocationName,
ItemID,
ItemClinicalDescription,
BinUOM,
convert(int,TotalPar) as TotalPar,
[Month],
Sum(OrderQty) as OrderQty,
Sum(OrderQty*BinCurrentCost) as Cost
from (
	select
	k.FacilityName,
	k.LocationName,
	k.ItemID,
	k.ItemClinicalDescription,
	dateadd(month,datediff(month,0,k.[Date]),0) as [Month],
	k.BinUOM,
	k.OrderQty,
	db.BinQty as TotalPar,
	db.BinCurrentCost
	from tableau.Kanban k
	inner join bluebin.DimBin db on k.BinKey = db.BinKey

	where k.OrderQty is not null) a

group by
FacilityName,
LocationName,
ItemID,
ItemClinicalDescription,
BinUOM,
convert(int,TotalPar),
[Month]

END
GO
grant exec on tb_ItemUsageKanban to public
GO



--*********************************************************************************************
--Tableau Sproc  These load data into the datasources for Tableau
--*********************************************************************************************

--*********************************************************************************************
--Tableau Sproc  These load data into the datasources for Tableau
--*********************************************************************************************

IF EXISTS ( SELECT  *
            FROM    sys.objects
            WHERE   object_id = OBJECT_ID(N'tb_OpenScans')
                    AND type IN ( N'P', N'PC' ) ) 

--exec tb_OpenScans
DROP PROCEDURE  tb_OpenScans
GO

CREATE PROCEDURE tb_OpenScans

AS


select 
p.REQ_ID as [Order Num],
OrderNum as [PO Num],
LineNum as [Line #],
OrderDate as [Order Date],
FacilityName as [Facility Name],
LocationID as [Location ID],
LocationName as [Location Name],
ItemID as [Item ID],
ItemDescription as [Item Description],
ItemType as [Item Type],
OrderUOM as [Order UOM],
BinSequence as [Bin Sequence],
Scan as Scans,
HotScan as [Hot Scan],
StockOut as [Stock Outs],
BinCurrentStatus as [Bin Status],
OrderQty as [Order Qty]



--select top 10* 
from tableau.Kanban k
left outer join PO_LINE_DISTRIB p on k.OrderNum = p.PO_ID and k.LineNum = p.LINE_NBR

where 
--Date > getdate()-10 and 
ScanHistseq > (select ConfigValue from bluebin.Config where ConfigName = 'ScanThreshold') and 
OrderCloseDate is null and 
OrderDate is not null --and p.PO_NUMBER is Null and ItemType = 'N'

group by
OrderNum,
p.REQ_ID,
LineNum,
OrderDate,
FacilityName,
LocationID,
LocationName,
ItemID,
ItemDescription,
ItemType,
OrderUOM,
BinSequence,
Scan,
HotScan,
StockOut,
BinCurrentStatus,
OrderQty

GO

grant exec on tb_OpenScans to public
GO


--*********************************************************************************************
--Tableau Sproc  These load data into the datasources for Tableau
--*********************************************************************************************


if exists (select * from dbo.sysobjects where id = object_id(N'tb_WarehouseHistory') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure tb_WarehouseHistory
GO

--exec tb_WarehouseHistory

CREATE PROCEDURE tb_WarehouseHistory

--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON

declare @History Table (Date date,FacilityName varchar(50),DollarsOnHand decimal(38,9),LocationID char(5),LocationName char(5),SKUS int,MonthEnd date)

insert into @History 
SELECT 
       Date,
	   FacilityName,
	   DollarsOnHand,
	   LocationID,
	   LocationName,
	   SKUS,
	   case when EOMONTH(getdate()) = EOMONTH(Date) then (select max(Date) from bluebin.FactWHHistory) else EOMONTH(Date) end as MonthEnd
FROM   bluebin.FactWHHistory

SELECT 
       a.Date,
	   a.FacilityName,
	   a.LocationID,
	   a.LocationName,
	   a.SKUS,
	   a.DollarsOnHand,
	   a.MonthEnd,
	   c.DollarsOnHand as MonthEndDollars
FROM @History  a
	inner join (
			SELECT 
				   b.Date,
				   b.FacilityName,
				   b.LocationID,
				   b.LocationName,
				   b.SKUS,
				   b.DollarsOnHand,
				   case when EOMONTH(getdate()) = EOMONTH(b.Date) then (select max(Date) from bluebin.FactWHHistory) else EOMONTH(b.Date) end as MonthEnd
			FROM   bluebin.FactWHHistory b 
			where b.DollarsOnHand > 0 and b.Date = case when EOMONTH(getdate()) = EOMONTH(b.Date) then (select max(Date) from bluebin.FactWHHistory) else EOMONTH(b.Date) end  
			) c on a.MonthEnd = c.Date and a.FacilityName = c.FacilityName and a.LocationID = c.LocationID
order by a.Date desc       



END
GO
grant exec on tb_WarehouseHistory to public
GO




Print 'Tableau (tb) sprocs updated'
Print 'DB: ' + DB_NAME() + ' updated'
GO