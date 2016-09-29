/*
Upgrade Script to copy in the etl_ and tb_ sprocs used in both the daily etl and to populate data sources in the Tableau WOrkbooks
20151211 - Created By John Ratte
20160115 - Updated by Gery Butler
20160211 - Updated by Gery Butler
20160229 - Updated by Gery Butler
20160315 - Updated by Gery Butler
20160315 - Updated by Gery Butler
20160509 - Updated by Gery Butler

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



GO

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


CREATE PROCEDURE etl_DimItem

AS

/**************		SET BUSINESS RULES		***************/




/**************		DROP DimItem			***************/

BEGIN Try
    DROP TABLE bluebin.DimItem
END Try

BEGIN Catch
END Catch


/**************		CREATE Temp Tables			*******************/
Declare @UseClinicalDescription int
select @UseClinicalDescription = ConfigValue from bluebin.Config where ConfigName = 'UseClinicalDescription'       

SELECT ITEM,max(ClinicalDescription) as ClinicalDescription
INTO   #ClinicalDescriptions
FROM
(
SELECT 
	a.ITEM,
		case when @UseClinicalDescription = 1 then
		case 
			when b.ClinicalDescription is null or b.ClinicalDescription = ''  then
			case
				when a.USER_FIELD3 is null or a.USER_FIELD3 = ''  then
				case	
					when a.USER_FIELD1 is null or a.USER_FIELD1 = '' then 
					case 
						when c.DESCRIPTION is null or c.DESCRIPTION = '' then '*NEEDS*'
					else rtrim(c.DESCRIPTION) + '*' end
				else a.USER_FIELD1 end
			else a.USER_FIELD3 end
		else b.ClinicalDescription end	
	else c.DESCRIPTION
	end as ClinicalDescription

FROM 
(SELECT 
	ITEM,
	USER_FIELD1,
	USER_FIELD3
FROM ITEMLOC a 
INNER JOIN RQLOC b ON a.LOCATION = b.REQ_LOCATION and a.COMPANY = b.COMPANY
WHERE LEFT(REQ_LOCATION, 2) IN (SELECT [ConfigValue] FROM   [bluebin].[Config] WHERE  [ConfigName] = 'REQ_LOCATION' AND Active = 1) or REQ_LOCATION in (Select REQ_LOCATION from bluebin.ALT_REQ_LOCATION)) a
LEFT JOIN 
(SELECT 
	distinct ITEM, 
	USER_FIELD3 as ClinicalDescription
FROM ITEMLOC 
WHERE LOCATION IN (SELECT [ConfigValue] FROM [bluebin].[Config] WHERE  [ConfigName] = 'LOCATION' AND Active = 1) AND LEN(LTRIM(USER_FIELD3)) > 0
) b
ON ltrim(rtrim(a.ITEM)) = ltrim(rtrim(b.ITEM))
left join ITEMMAST c on ltrim(rtrim(a.ITEM)) = ltrim(rtrim(c.ITEM))
) a

Group by ITEM
	  

SELECT distinct ITEM,
       Max(PO_DATE) AS LAST_PO_DATE
INTO   #LastPO
FROM   POLINE a
       INNER JOIN PURCHORDER b
              ON a.PO_NUMBER = b.PO_NUMBER
                  AND a.COMPANY = b.COMPANY
                  AND a.PO_CODE = b.PO_CODE
--WHERE ITEM like '%30003%'			   
GROUP  BY ITEM

SELECT 
   il1.ITEM,
   STUFF((SELECT  ', '  + il2.Bins.COMPARTMENT + '(' + rtrim(il2.LOCATION) + ')'
          FROM ITEMLOC il2
          WHERE  il2.LOCATION in (Select ConfigValue from bluebin.Config where ConfigName = 'LOCATION')
		  and il2.Bins.COMPARTMENT <> '' and il2.ACTIVE_STATUS = 'A' and il2.ITEM = il1.ITEM 
		  order by il2.LOCATION
          FOR XML PATH('')), 1, 1, '') [Bins.COMPARTMENT]
INTO   #StockLocations
FROM ITEMLOC il1
WHERE il1.LOCATION in (Select ConfigValue from bluebin.Config where ConfigName = 'LOCATION') and il1.Bins.COMPARTMENT <> '' and il1.ACTIVE_STATUS = 'A'

GROUP BY il1.ITEM
ORDER BY 1

--**Old Stock Locations
--SELECT 
--Row_number()
--             OVER(
--               ORDER BY ITEM,LOCATION) as Num,
--	LOCATION,ITEM,
--       Bins.COMPARTMENT
--INTO   #StockLocations
--FROM   ITEMLOC
--WHERE  LOCATION in (Select ConfigValue from bluebin.Config where ConfigName = 'LOCATION') 
--and ACTIVE_STATUS = 'A' and ITEM in  ('61830','12296') and Bins.COMPARTMENT <> ''


SELECT distinct  a.ITEM,
       a.VENDOR,
       a.VEN_ITEM,
       a.UOM,
       a.UOM_MULT
INTO #ItemContract
FROM   POVAGRMTLN a
       INNER JOIN (SELECT ITEM,
						  MAX(LINE_NBR)		AS LINE_NBR,
                          Max(EFFECTIVE_DT) AS EFFECTIVE_DT,
                          Max(EXPIRE_DT)    AS EXPIRE_DT
                   FROM   POVAGRMTLN
                   WHERE  HOLD_FLAG = 'N'
                   GROUP  BY ITEM) b
               ON a.ITEM = b.ITEM
                  AND a.EFFECTIVE_DT = b.EFFECTIVE_DT
                  AND a.EXPIRE_DT = b.EXPIRE_DT
				  AND a.LINE_NBR = b.LINE_NBR
WHERE  a.HOLD_FLAG = 'N'  

--**Old Vendors
--select distinct a.ITEM,a.VENDOR
--into #ItemVendor
--from ITEMSRC a
--where a.REPLENISH_PRI = 1
--        AND a.LOCATION in (Select ConfigValue from bluebin.Config where ConfigName = 'LOCATION')
--		and a.REPL_FROM_LOC = '' 

select distinct a.ITEM,a.VENDOR
into #ItemVendor
from 
	(select ITEM,max(VENDOR) as VENDOR
		from ITEMSRC 
		where REPLENISH_PRI = 1
				AND LOCATION in (Select ConfigValue from bluebin.Config where ConfigName = 'LOCATION')
				and REPL_FROM_LOC = ''
		group by ITEM) a



/*********************		CREATE DimItem		**************************************/


SELECT Row_number()
         OVER(
           ORDER BY a.ITEM)                AS ItemKey,
       a.ITEM                              AS ItemID,
       a.DESCRIPTION                       AS ItemDescription,
	   a.DESCRIPTION2					   AS ItemDescription2,
       case 
		when @UseClinicalDescription = 1 
		then 
			case 
				when e.ClinicalDescription is null 
				then rtrim(a.DESCRIPTION) + '*' 
				else e.ClinicalDescription end
		else rtrim(a.DESCRIPTION) + '*' end             AS ItemClinicalDescription,
       a.ACTIVE_STATUS                     AS ActiveStatus,
       icm.DESCRIPTION                     AS ItemManufacturer, --b.DESCRIPTION
	   --a.MANUF_NBR                         AS ItemManufacturer, --b.DESCRIPTION
       a.MANUF_NBR                         AS ItemManufacturerNumber,
       d.VENDOR_VNAME                      AS ItemVendor,
       c.VENDOR                            AS ItemVendorNumber,
       f.LAST_PO_DATE                      AS LastPODate,
       ltrim(g.Bins.COMPARTMENT)                       AS StockLocation,
       h.VEN_ITEM                          AS VendorItemNumber,
	   a.STOCK_UOM							AS StockUOM,
       h.UOM                               AS BuyUOM,
       CONVERT(VARCHAR, Cast(h.UOM_MULT AS INT))
       + ' EA' + '/'+Ltrim(Rtrim(h.UOM)) AS PackageString
INTO   bluebin.DimItem
FROM   ITEMMAST a 
     --  LEFT JOIN ITEMSRC c 
     --         ON ltrim(rtrim(a.ITEM)) = ltrim(rtrim(c.ITEM))
     --            AND c.REPLENISH_PRI = 1
     --            AND c.LOCATION in (Select ConfigValue from bluebin.Config where ConfigName = 'LOCATION')
				 --and c.REPL_FROM_LOC = ''
	   LEFT JOIN #ItemVendor c on ltrim(rtrim(a.ITEM)) = ltrim(rtrim(c.ITEM))
       LEFT JOIN (select distinct VENDOR_GROUP,VENDOR,VENDOR_VNAME from APVENMAST) d 
              ON ltrim(rtrim(c.VENDOR)) = ltrim(rtrim(d.VENDOR))
       LEFT JOIN #ClinicalDescriptions e
              ON ltrim(rtrim(a.ITEM)) = ltrim(rtrim(e.ITEM))
       LEFT JOIN #LastPO f
              ON rtrim(a.ITEM) = rtrim(f.ITEM)
       LEFT JOIN #StockLocations g
              ON ltrim(rtrim(c.ITEM)) = ltrim(rtrim(g.ITEM)) 
       LEFT JOIN #ItemContract h
              ON ltrim(rtrim(a.ITEM)) = ltrim(rtrim(h.ITEM)) AND ltrim(rtrim(d.VENDOR)) = ltrim(rtrim(h.VENDOR))
		LEFT JOIN 
			(select MANUF_CODE,max(DESCRIPTION) as [DESCRIPTION] from ICMANFCODE group by MANUF_CODE) icm
              ON a.MANUF_CODE = icm.MANUF_CODE
--where a.ITEM = '30003'
order by a.ITEM



/*********************		DROP Temp Tables	*********************************/


DROP TABLE #ClinicalDescriptions

DROP TABLE #LastPO

DROP TABLE #StockLocations

DROP TABLE #ItemContract

DROP TABLE #ItemVendor

GO

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


CREATE PROCEDURE etl_DimLocation
AS

/********************		DROP DimLocation	***************************/
  BEGIN TRY
      DROP TABLE bluebin.DimLocation
  END TRY

  BEGIN CATCH
  END CATCH

/*********************		CREATE DimLocation	****************************/
   SELECT Row_number()
             OVER(
               ORDER BY REQ_LOCATION) AS LocationKey,
           REQ_LOCATION               AS LocationID,
           NAME                       AS LocationName,
           COMPANY                    AS LocationFacility,
           CASE
             WHEN ACTIVE_STATUS = 'A' and (
											LEFT(REQ_LOCATION, 2) IN (SELECT [ConfigValue]
                                            FROM   [bluebin].[Config]
                                            WHERE  [ConfigName] = 'REQ_LOCATION'
                                                   AND Active = 1) 
										or REQ_LOCATION in (Select REQ_LOCATION from bluebin.ALT_REQ_LOCATION)
											)		   
												   
										THEN 1
             ELSE 0
           END                        AS BlueBinFlag,
		   ACTIVE_STATUS
    INTO   bluebin.DimLocation
    FROM   RQLOC 



GO

UPDATE etl.JobSteps
SET LastModifiedDate = GETDATE()
WHERE StepName = 'DimLocation'





/********************************************************

		DimDate

********************************************************/

IF EXISTS ( SELECT  *
            FROM    sys.objects
            WHERE   object_id = OBJECT_ID(N'etl_DimDate')
                    AND type IN ( N'P', N'PC' ) ) 

DROP PROCEDURE  etl_DimDate
GO

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


--****************************************************************************
--DimBin
--****************************************************************************

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

SELECT REQ_LOCATION,
       Min(CREATION_DATE) AS BinAddedDate
INTO   #BinAddDates
FROM   REQLINE a INNER JOIN bluebin.DimLocation b ON a.REQ_LOCATION = b.LocationID
WHERE  b.BlueBinFlag = 1
GROUP  BY REQ_LOCATION

SELECT Row_number()
         OVER(
           Partition BY ITEM, ENTERED_UOM
           ORDER BY CREATION_DATE DESC) AS Itemreqseq,
       ITEM,
       ENTERED_UOM,
       UNIT_COST
INTO   #ItemReqs
FROM   REQLINE a INNER JOIN bluebin.DimLocation b ON a.REQ_LOCATION = b.LocationID
WHERE  b.BlueBinFlag = 1

SELECT Row_number()
         OVER(
           Partition BY ITEM, ENT_BUY_UOM
           ORDER BY PO_NUMBER DESC) AS ItemOrderSeq,
       ITEM,
       ENT_BUY_UOM,
       ENT_UNIT_CST
INTO   #ItemOrders
FROM   POLINE
WHERE  ITEM_TYPE IN ( 'I', 'N' )
       AND ITEM IN (SELECT DISTINCT ITEM
                    FROM   ITEMLOC a INNER JOIN bluebin.DimLocation b ON a.LOCATION = b.LocationID
WHERE  b.BlueBinFlag = 1)


SELECT distinct a.ITEM,
       --a.GL_CATEGORY,
       max(b.ISS_ACCOUNT) as ISS_ACCOUNT--,a.LOCATION
INTO   #ItemAccounts
FROM   ITEMLOC a 
		LEFT JOIN ICCATEGORY b
              ON a.GL_CATEGORY = b.GL_CATEGORY
                 AND a.LOCATION = b.LOCATION
WHERE  
a.LOCATION in (select ConfigValue from bluebin.Config where ConfigName = 'LOCATION') 
and a.ACTIVE_STATUS = 'A' --and a.ITEM = '3733'
group by a.ITEM
       --,a.GL_CATEGORY




SELECT distinct 
i.ITEM,
c.LAST_ISS_COST
INTO   #ItemStore
FROM   ITEMLOC i
left join (select ITEMLOC.ITEM,max(ITEMLOC.LAST_ISS_COST) as LAST_ISS_COST from ITEMLOC
				inner join (select ITEM,max(LAST_ISSUE_DT) as t from ITEMLOC where ITEM = '1915' group by ITEM) cost on ITEMLOC.ITEM = cost.ITEM and ITEMLOC.LAST_ISSUE_DT = cost.t
				group by ITEMLOC.ITEM ) c on i.ITEM = c.ITEM
WHERE  i.LOCATION in (select ConfigValue from bluebin.Config where ConfigName = 'LOCATION')  and i.ACTIVE_STATUS = 'A'  


SELECT distinct ITEM,CONSIGNMENT_FL 
INTO #Consignment
FROM ITEMMAST
WHERE  ITEM in (select ITEM from ITEMLOC where LOCATION in (select ConfigValue from bluebin.Config where ConfigName = 'LOCATION'))



/***********************************		CREATE	DimBin		***********************************/

SELECT Row_number()
             OVER(
               ORDER BY ITEMLOC.LOCATION, ITEMLOC.ITEM)                                               AS BinKey,
			   ITEMLOC.COMPANY																			AS BinFacility,
           ITEMLOC.ITEM                                                                               AS ItemID,
           ITEMLOC.LOCATION                                                                           AS LocationID,
           Bins.COMPARTMENT                                                                                 AS BinSequence,
		   CASE WHEN ISNUMERIC(left(Bins.COMPARTMENT,1))=1 then LEFT(Bins.COMPARTMENT,2) 
				else CASE WHEN Bins.COMPARTMENT LIKE '[A-Z][A-Z]%' THEN LEFT(Bins.COMPARTMENT, 2) ELSE LEFT(Bins.COMPARTMENT, 1) END END as BinCart,
			CASE WHEN ISNUMERIC(left(Bins.COMPARTMENT,1))=1 then SUBSTRING(Bins.COMPARTMENT, 3, 1) 
				else CASE WHEN Bins.COMPARTMENT LIKE '[A-Z][A-Z]%' THEN SUBSTRING(Bins.COMPARTMENT, 3, 1) ELSE SUBSTRING(Bins.COMPARTMENT, 2,1) END END as BinRow,
			CASE WHEN ISNUMERIC(left(Bins.COMPARTMENT,1))=1 then SUBSTRING(Bins.COMPARTMENT, 4, 2)
				else CASE WHEN Bins.COMPARTMENT LIKE '[A-Z][A-Z]%' THEN SUBSTRING (Bins.COMPARTMENT,4,2) ELSE SUBSTRING(Bins.COMPARTMENT, 3,2) END END as BinPosition,	
			CASE
				WHEN Bins.COMPARTMENT LIKE 'CARD%' THEN 'WALL'
					ELSE 
						CASE WHEN ISNUMERIC(left(Bins.COMPARTMENT,1))=1 then RIGHT(Bins.COMPARTMENT,2) 
							else CASE WHEN Bins.COMPARTMENT LIKE '[A-Z][A-Z]%' THEN RIGHT(Bins.COMPARTMENT, 2) ELSE RIGHT(Bins.COMPARTMENT, 3) END END
           END                                                                                        AS BinSize,
           UOM                                                                                        AS BinUOM,
           REORDER_POINT                                                                              AS BinQty,
           CASE
             WHEN LEADTIME_DAYS = 0 or LEADTIME_DAYS is null THEN (Select max(ConfigValue) from bluebin.Config where ConfigName = 'DefaultLeadTime')
             ELSE LEADTIME_DAYS
           END                                                                                          AS BinLeadTime,
           #BinAddDates.BinAddedDate                                                                  AS BinGoLiveDate,
           COALESCE(COALESCE(#ItemReqs.UNIT_COST, #ItemOrders.ENT_UNIT_CST), #ItemStore.LAST_ISS_COST) AS BinCurrentCost,
           CASE
             WHEN ltrim(rtrim(ITEMLOC.USER_FIELD1)) = 'Consignment' THEN 'Y'
			 WHEN UPPER(ltrim(rtrim(ITEMLOC.USER_FIELD1))) = 'CONSIGNMENT' OR #Consignment.CONSIGNMENT_FL = 'Y'  THEN 'Y'
             ELSE 'N'
           END                                                                                        AS BinConsignmentFlag,
           #ItemAccounts.ISS_ACCOUNT                                                                  AS BinGLAccount,
		   'Awaiting Updated Status'																							AS BinCurrentStatus
    INTO   bluebin.DimBin
    FROM   ITEMLOC  
           INNER JOIN bluebin.DimLocation
                   ON ITEMLOC.LOCATION = DimLocation.LocationID
				   AND ITEMLOC.COMPANY = DimLocation.LocationFacility			   
           INNER JOIN #BinAddDates
                   ON ITEMLOC.LOCATION = #BinAddDates.REQ_LOCATION
           LEFT JOIN #ItemReqs
                  ON ITEMLOC.ITEM = #ItemReqs.ITEM
                     AND ITEMLOC.UOM = #ItemReqs.ENTERED_UOM
                     AND #ItemReqs.Itemreqseq = 1
           LEFT JOIN #ItemOrders
                  ON ITEMLOC.ITEM = #ItemOrders.ITEM
                     AND ITEMLOC.UOM = #ItemOrders.ENT_BUY_UOM
                     AND #ItemOrders.ItemOrderSeq = 1
           LEFT JOIN #ItemAccounts
                  ON ITEMLOC.ITEM = #ItemAccounts.ITEM
           LEFT JOIN #ItemStore
                  ON ITEMLOC.ITEM = #ItemStore.ITEM
		   LEFT JOIN #Consignment
                  ON ITEMLOC.ITEM = #Consignment.ITEM
	WHERE DimLocation.BlueBinFlag = 1
	--and ITEMLOC.ITEM = '1915'

/*****************************************		DROP Temp Tables	**************************************/

DROP TABLE #BinAddDates
DROP TABLE #ItemReqs
DROP TABLE #ItemOrders
DROP TABLE #ItemAccounts
DROP TABLE #ItemStore
DROP TABLE #Consignment

GO

UPDATE etl.JobSteps
SET LastModifiedDate = GETDATE()
WHERE StepName = 'DimBin'


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

AS

/*****************************		DROP FactScan		*******************************/

BEGIN Try
    DROP TABLE bluebin.FactScan
END Try

BEGIN Catch
END Catch

--/********************************		CREATE Temp Tables			******************************/

SELECT COMPANY,
       CASE 
			WHEN LEN(DOCUMENT) = 10 and LEFT(DOCUMENT,6) = '000000' THEN RIGHT(DOCUMENT,4)
			WHEN LEN(DOCUMENT) = 10 and LEFT(DOCUMENT,5) = '00000' THEN RIGHT(DOCUMENT,5)
			WHEN LEN(DOCUMENT) = 10 and LEFT(DOCUMENT,4) = '0000' THEN RIGHT(DOCUMENT,6)
			WHEN LEN(DOCUMENT) = 10 and LEFT(DOCUMENT,3) = '000' THEN RIGHT(DOCUMENT,7)
		ELSE DOCUMENT 
		END AS DOCUMENT,
       LINE_NBR,
	   SUM((QUANTITY*-1)) as QUANTITY,
       MAX((Cast(CONVERT(VARCHAR, TRANS_DATE, 101) + ' '
            + LEFT(RIGHT('00000' + CONVERT(VARCHAR, ACTUAL_TIME), 4), 2)
            + ':'
            + Substring(RIGHT('00000' + CONVERT(VARCHAR, ACTUAL_TIME), 4), 3, 2) AS DATETIME))) AS TRANS_DATE
INTO #ICTRANS
FROM   ICTRANS a
       INNER JOIN bluebin.DimLocation b
               ON a.FROM_TO_LOC = b.LocationID 
WHERE b.BlueBinFlag = 1 and DOCUMENT not like '%[A-Z]%' and DOCUMENT not like '%/%' and try_convert(bigint,DOCUMENT) < 2147483647  
--and DOCUMENT like '%270943%'
group by 
COMPANY,
       CASE 
			WHEN LEN(DOCUMENT) = 10 and LEFT(DOCUMENT,6) = '000000' THEN RIGHT(DOCUMENT,4)
			WHEN LEN(DOCUMENT) = 10 and LEFT(DOCUMENT,5) = '00000' THEN RIGHT(DOCUMENT,5)
			WHEN LEN(DOCUMENT) = 10 and LEFT(DOCUMENT,4) = '0000' THEN RIGHT(DOCUMENT,6)
			WHEN LEN(DOCUMENT) = 10 and LEFT(DOCUMENT,3) = '000' THEN RIGHT(DOCUMENT,7)
		ELSE DOCUMENT 
		END,
       LINE_NBR
--select * from ICTRANS where DOCUMENT like '%270943%'

SELECT COMPANY,
	   CASE 
			WHEN LEN(REQ_NUMBER) = 10 and LEFT(REQ_NUMBER,6) = '000000' THEN RIGHT(REQ_NUMBER,4)
			WHEN LEN(REQ_NUMBER) = 10 and LEFT(REQ_NUMBER,5) = '00000' THEN RIGHT(REQ_NUMBER,5)
			WHEN LEN(REQ_NUMBER) = 10 and LEFT(REQ_NUMBER,4) = '0000' THEN RIGHT(REQ_NUMBER,6)
			WHEN LEN(REQ_NUMBER) = 10 and LEFT(REQ_NUMBER,3) = '000' THEN RIGHT(REQ_NUMBER,7)
		ELSE REQ_NUMBER 
		END AS REQ_NUMBER,
       LINE_NBR,
       ITEM,
       REQ_LOCATION,
       ENTERED_UOM,
       QUANTITY,
       ITEM_TYPE,
       CREATION_TIME,
	   CLOSED_FL,
       Cast(CONVERT(VARCHAR, CREATION_DATE, 101) + ' '
            + LEFT(RIGHT('00000' + CONVERT(VARCHAR, CREATION_TIME), 8), 2)
            + ':'
            + Substring(RIGHT('00000' + CONVERT(VARCHAR, CREATION_TIME), 8), 3, 2)
            + ':'
            + Substring(RIGHT('00000' + CONVERT(VARCHAR, CREATION_TIME), 8), 5, 2) AS DATETIME) AS CREATION_DATE
INTO #REQLINE
FROM   REQLINE
WHERE  STATUS = 9
       AND KILL_QUANTITY = 0 
--and REQ_NUMBER like '%603585%'

SELECT 
a.COMPANY,
		CASE
			WHEN LEN(a.SOURCE_DOC_N) = 10 and LEFT(a.SOURCE_DOC_N,6) = '000000' THEN RIGHT(a.SOURCE_DOC_N,4)
			WHEN LEN(a.SOURCE_DOC_N) = 10 and LEFT(a.SOURCE_DOC_N,5) = '00000' THEN RIGHT(a.SOURCE_DOC_N,5)
			WHEN LEN(a.SOURCE_DOC_N) = 10 and LEFT(a.SOURCE_DOC_N,4) = '0000' THEN RIGHT(a.SOURCE_DOC_N,6)
			WHEN LEN(a.SOURCE_DOC_N) = 10 and LEFT(a.SOURCE_DOC_N,3) = '000' THEN RIGHT(a.SOURCE_DOC_N,7)	
		ELSE a.SOURCE_DOC_N 
		END AS REQ_NUMBER,
       a.SRC_LINE_NBR                                                                         AS LINE_NBR,
       MIN(Cast(CONVERT(VARCHAR, b.REC_DATE, 101) + ' '
			+ LEFT(RIGHT('00000' + CONVERT(VARCHAR, case when b.UPDATE_TIME is null then '00000000' else b.UPDATE_TIME end), 8), 2)
            + ':'
            + Substring(RIGHT('00000' + CONVERT(VARCHAR, case when b.UPDATE_TIME is null then '00000000' else b.UPDATE_TIME end), 8), 3, 2)
            + ':'
            + Substring(RIGHT('00000' + CONVERT(VARCHAR, case when b.UPDATE_TIME is null then '00000000' else b.UPDATE_TIME end), 8), 5, 2) AS DATETIME)) AS REC_DATE

INTO #POLINE
FROM   POLINESRC a
       LEFT JOIN PORECLINE b
               ON a.PO_NUMBER = b.PO_NUMBER
                  AND a.LINE_NBR = b.PO_LINE_NBR
					AND a.COMPANY = b.COMPANY 


GROUP BY
	a.COMPANY,
	a.SOURCE_DOC_N,
	a.SRC_LINE_NBR



Select
b.COMPANY,
CASE
			WHEN LEN(a.SOURCE_DOC_N) = 10 and LEFT(a.SOURCE_DOC_N,6) = '000000' THEN RIGHT(a.SOURCE_DOC_N,4)
			WHEN LEN(a.SOURCE_DOC_N) = 10 and LEFT(a.SOURCE_DOC_N,5) = '00000' THEN RIGHT(a.SOURCE_DOC_N,5)
			WHEN LEN(a.SOURCE_DOC_N) = 10 and LEFT(a.SOURCE_DOC_N,4) = '0000' THEN RIGHT(a.SOURCE_DOC_N,6)
			WHEN LEN(a.SOURCE_DOC_N) = 10 and LEFT(a.SOURCE_DOC_N,3) = '000' THEN RIGHT(a.SOURCE_DOC_N,7)	
		ELSE a.SOURCE_DOC_N 
		END AS REQ_NUMBER,
        a.SRC_LINE_NBR                                                                         AS LINE_NBR, 
		CLOSE_DATE   as CancelDate
INTO #CancelledLines
FROM POLINE b
INNER JOIN POLINESRC a on b.COMPANY = a.COMPANY and b.PO_NUMBER = a.PO_NUMBER AND b.LINE_NBR = a.LINE_NBR
WHERE b.CXL_QTY = b.QUANTITY and b.CLOSED_FL = 'Y' --and a.SOURCE_DOC_N like '%270943%'




SELECT 
Row_number()
         OVER(
           Partition BY b.BinKey
           ORDER BY a.CREATION_DATE DESC) AS Scanseq,
       Row_number()
         OVER(
           Partition BY b.BinKey
           ORDER BY a.CREATION_DATE ASC) AS ScanHistseq,
       a.COMPANY					AS OrderFacility,
	   b.BinKey,
	   b.BinLeadTime,
       b.LocationID,
       b.ItemID,
       b.BinGoLiveDate,
       a.ITEM_TYPE                   AS ItemType,
       a.REQ_NUMBER                  AS OrderNum,
       a.LINE_NBR                    AS LineNum,
       a.ENTERED_UOM                 AS OrderUOM,
       a.QUANTITY                    AS OrderQty,
       a.CREATION_DATE               AS OrderDate,
       CASE
         WHEN a.ITEM_TYPE = 'I' and e.QUANTITY >= a.QUANTITY OR a.ITEM_TYPE = 'I' and a.CLOSED_FL = 'Y' --Additional logic to add if checking for Quantity on the ICTrans.  Not currently doing so.*/
			THEN e.TRANS_DATE
         WHEN a.ITEM_TYPE = 'N' 
			THEN c.REC_DATE 
         ELSE NULL
       END                           AS OrderCloseDate,
	   case 
	   when a.CLOSED_FL = 'Y' and ((c.REQ_NUMBER is null and a.ITEM_TYPE = 'N') or (e.DOCUMENT is null and e.TRANS_DATE is null and a.ITEM_TYPE = 'I')) then a.CREATION_DATE
	   else d.CancelDate end as OrderCancelDate
INTO   #tmpScan  
FROM   #REQLINE a
       INNER JOIN bluebin.DimBin b
               ON a.ITEM = b.ItemID
                  AND a.REQ_LOCATION = b.LocationID
				  AND a.COMPANY = b.BinFacility
       LEFT JOIN #POLINE c 
			ON a.REQ_NUMBER = c.REQ_NUMBER 
			AND a.LINE_NBR = c.LINE_NBR
			--AND a.COMPANY = c.COMPANY		--Remove case if Multiple Companies
	   --LEFT JOIN  (select COMPANY,DOCUMENT,LINE_NBR,max(TRANS_DATE) as TRANS_DATE from #ICTRANS group by COMPANY,DOCUMENT,LINE_NBR) e --Different join logic if you remove the group in the #ICTRANS table
	   LEFT JOIN #ICTRANS e
               ON a.REQ_NUMBER = e.DOCUMENT
               AND a.LINE_NBR = e.LINE_NBR
			--AND a.COMPANY = e.COMPANY		--Remove case if Multiple Companies
		LEFT JOIN #CancelledLines d 
			ON a.REQ_NUMBER = d.REQ_NUMBER 
			AND a.LINE_NBR = d.LINE_NBR
			--and a.COMPANY = d.COMPANY		--Remove case if Multiple Companies


/***********************************		CREATE FactScan		****************************************/
declare @DefaultLT int = (Select max(ConfigValue) from bluebin.Config where ConfigName = 'DefaultLeadTime')

SELECT a.Scanseq,
       a.ScanHistseq,
       a.BinKey,
       c.LocationKey,
       d.ItemKey,
       a.BinGoLiveDate,
       a.OrderNum,
       a.LineNum,
       a.ItemType,
       a.OrderUOM,
       Cast(a.OrderQty AS INT) AS OrderQty,
       a.OrderDate,
       case when (a.OrderCancelDate is not null and a.ItemType <> 'I') or (a.OrderCancelDate is not null and a.ItemType = 'I') then a.OrderCancelDate else a.OrderCloseDate end as OrderCloseDate,
       b.OrderDate             AS PrevOrderDate,
       case when b.OrderCancelDate is not null  and a.ItemType <> 'I' then b.OrderCancelDate else b.OrderCloseDate end AS PrevOrderCloseDate,
       1                       AS Scan,
       CASE
         WHEN Datediff(Day, b.OrderDate, a.OrderDate) < COALESCE(a.BinLeadTime,@DefaultLT,3) THEN 1
         ELSE 0
       END                     AS HotScan,
       CASE
         WHEN a.OrderDate < COALESCE(b.OrderCloseDate, b.OrderCancelDate, Getdate())
              AND a.ScanHistseq > (select ConfigValue + 1 from bluebin.Config where ConfigName = 'ScanThreshold') THEN 1 --When looking for stockouts you have to take the scanseq 2 after the ignored one
         ELSE 0
       END                     AS StockOut
INTO   bluebin.FactScan
FROM   #tmpScan a
       LEFT JOIN #tmpScan b
              ON a.BinKey = b.BinKey
                 AND a.Scanseq = b.Scanseq - 1
       LEFT JOIN bluebin.DimLocation c
              ON a.LocationID = c.LocationID	
			  AND a.OrderFacility = c.LocationFacility		
       LEFT JOIN bluebin.DimItem d
              ON a.ItemID = d.ItemID 
--where a.OrderNum like '%606841%'
order by a.BinKey,a.OrderDate
/*****************************************		DROP Temp Tables		*******************************/

DROP TABLE #REQLINE
DROP TABLE #ICTRANS
DROP TABLE #POLINE
DROP TABLE #tmpScan
DROP TABLE #CancelledLines



GO

UPDATE etl.JobSteps
SET LastModifiedDate = GETDATE()
WHERE StepName = 'FactScan'



/*************************************************

			FactBinSnapshot

*************************************************/

IF EXISTS ( SELECT  *
            FROM    sys.objects
            WHERE   object_id = OBJECT_ID(N'etl_FactBinSnapshot')
                    AND type IN ( N'P', N'PC' ) ) 

DROP PROCEDURE  etl_FactBinSnapshot
GO


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
--exec etl_FactIssue
CREATE PROCEDURE etl_FactIssue

AS

/****************************		DROP FactIssue ***********************************/
 BEGIN TRY
 DROP TABLE bluebin.FactIssue
 END TRY
 BEGIN CATCH
 END CATCH

 /*******************************	CREATE FactIssue	*********************************/


 SELECT 
		a.COMPANY                                                                                AS FacilityKey,
       a.LOCATION as LocationID,
	   b.LocationKey,
	   c.LocationKey                                                                          AS ShipLocationKey,
       c.LocationFacility                                                                     AS ShipFacilityKey,
       c.BlueBinFlag,
	   d.ItemKey,
       SYSTEM_CD as SourceSystem,
       CASE
         WHEN SYSTEM_CD = 'RQ' THEN DOCUMENT
         ELSE ''
       END                                                                                    AS ReqNumber,
       CASE
         WHEN SYSTEM_CD = 'RQ' THEN LINE_NBR
         ELSE ''
       END                                                                                    AS ReqLineNumber,
       Cast(CONVERT(VARCHAR, TRANS_DATE, 101) + ' '
            + LEFT(RIGHT('00000' + CONVERT(VARCHAR, ACTUAL_TIME), 4), 2)
            + ':'
            + Substring(RIGHT('00000' + CONVERT(VARCHAR, ACTUAL_TIME), 4), 3, 2) AS DATETIME) AS IssueDate,
       TRAN_UOM as UOM,
       TRAN_UOM_MULT as UOMMult,
       -QUANTITY                                                                              AS IssueQty,
       CASE
         WHEN SYSTEM_CD = 'IC' THEN 1
         ELSE 0
       END                                                                                    AS StatCall,
       1                                                                                      AS IssueCount
INTO bluebin.FactIssue
FROM   ICTRANS a
       LEFT JOIN bluebin.DimLocation b
               ON a.LOCATION = b.LocationID
                  AND a.COMPANY = b.LocationFacility
       LEFT JOIN bluebin.DimLocation c
               ON a.FROM_TO_LOC = c.LocationID
                  AND a.FROM_TO_CMPY = c.LocationFacility
       LEFT JOIN bluebin.DimItem d
               ON a.ITEM = d.ItemID
WHERE  DOC_TYPE = 'IS'  and a.DOCUMENT not like '%[A-Z]%' 

GO

UPDATE etl.JobSteps
SET LastModifiedDate = GETDATE()
WHERE StepName = 'FactIssue'

GO

/****************************************************************

			FactWarehouseSnapshot

****************************************************************/


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

	
select 
	LOCATION,
	ITEM,
       SOH_QTY       AS SOHQty,
	   LAST_ISS_COST	AS UnitCost,
	   convert(DATE,getdate()) as MonthEnd
into TempA# 
from ITEMLOC 
where 
	LOCATION in (Select ConfigValue from bluebin.Config where ConfigName = 'LOCATION')
	and SOH_QTY > 0 
	OR 
	LOCATION in (Select ConfigValue from bluebin.Config where ConfigName = 'LOCATION') and 
	ITEM in (select distinct ITEM from ICTRANS where LOCATION in (Select ConfigValue from bluebin.Config where ConfigName = 'LOCATION'))
	--AND ITEM in ('0000013','0000018')


    SELECT 
		Row_number()
             OVER(
               PARTITION BY a.ITEM
               ORDER BY a.MonthEnd DESC) as [Sequence],
		a.MonthEnd,
		a.ITEM,
		case when a.MonthEnd = convert(DATE,getdate()) then TempA#.SOHQty else (ISNULL(b.QUANTITY,0)*-1) end as QUANTITY,
		(ISNULL(c.QUANTITY,0)*-1) as QUANTITYIN

    into TempB#
	FROM   
	(SELECT DISTINCT 
		case when left(Date,11) = left(getdate(),11) then Date else Eomonth(Date) end AS MonthEnd,
		ITEM
		FROM   bluebin.DimDate,TempA#) a
		LEFT JOIN
		(select 
			ITEM,
			EOMONTH(DATEADD(MONTH, -1, TRANS_DATE)) as MonthEnd,
			SUM((QUANTITY)) as QUANTITY 
			FROM   ICTRANS 
			where 
				LOCATION in (Select ConfigValue from bluebin.Config where ConfigName = 'LOCATION')
			group by ITEM,
			EOMONTH(DATEADD(MONTH, -1, TRANS_DATE))) b on a.MonthEnd = b.MonthEnd and a.ITEM = b.ITEM 
		LEFT JOIN
		(select 
			ITEM,
			EOMONTH(DATEADD(MONTH, -1, REC_ACT_DATE)) as MonthEnd,
			SUM((REC_QTY*EBUY_UOM_MULT)) as QUANTITY 
			FROM   POLINE 
			where 
				LOCATION in (Select ConfigValue from bluebin.Config where ConfigName = 'LOCATION')
				and CXL_QTY = 0 and REC_QTY > 0 and ITEM_TYPE = 'I'
			group by ITEM,
			EOMONTH(DATEADD(MONTH, -1, REC_ACT_DATE))) c on a.MonthEnd = c.MonthEnd and a.ITEM = c.ITEM 
		left join TempA# on a.MonthEnd = TempA#.MonthEnd and a.ITEM = TempA#.ITEM
    WHERE  a.MonthEnd <= Getdate() 



select 
ic.COMPANY AS FacilityKey,
df.FacilityName,
ic.LOCATION as LocationID,
TempB#.MonthEnd as SnapshotDate,
TempB#.ITEM,
SUM(TempB#.QUANTITY+TempB#.QUANTITYIN) OVER (PARTITION BY TempB#.ITEM ORDER BY TempB#.[Sequence]) as SOH,
ic.LAST_ISS_COST  AS UnitCost  
--,SUM(TempB#.QUANTITY+TempB#.QUANTITYIN) OVER (PARTITION BY TempB#.ITEM ORDER BY TempB#.[Sequence])*ic.LAST_ISS_COST as B
into bluebin.FactWarehouseSnapshot
from TempB# 
inner join ITEMLOC ic on TempB#.ITEM = ic.ITEM
inner join bluebin.DimFacility df on ic.COMPANY = df.FacilityID
where ic.LOCATION in (Select ConfigValue from bluebin.Config where ConfigName = 'LOCATION')

drop table TempA#
drop table TempB#

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





IF EXISTS ( SELECT  *
            FROM    sys.objects
            WHERE   object_id = OBJECT_ID(N'tb_Sourcing')
                    AND type IN ( N'P', N'PC' ) ) 

DROP PROCEDURE  tb_Sourcing
GO

CREATE PROCEDURE	tb_Sourcing
--exec tb_Sourcing  select count(*) from tableau.Sourcing where PODate >= (select ConfigValue from bluebin.Config where ConfigName = 'PO_DATE')
AS

/********************************		DROP Sourcing		**********************************/

BEGIN TRY
    DROP TABLE tableau.Sourcing
END TRY

BEGIN CATCH
END CATCH

/**********************************		CREATE Temp Tables		***************************/

-- #tmpPOLines

SELECT a.COMPANY,
       a.PO_NUMBER,
       a.PO_RELEASE,
       a.PO_CODE,
       a.LINE_NBR,
       a.ITEM,
       a.ITEM_TYPE,
       a.DESCRIPTION AS PO_DESCRIPTION,
       a.QUANTITY,
       a.REC_QTY,
       a.AGREEMENT_REF,
       a.ENT_UNIT_CST,
       a.ENT_BUY_UOM,
       a.EBUY_UOM_MULT,
       b.PO_DATE,
       a.EARLY_DL_DATE,
       a.LATE_DL_DATE,
       a.REC_ACT_DATE,
       a.CLOSE_DATE,
       a.LOCATION,
       a.BUYER_CODE,
       a.VENDOR,
       d.OPER_COMPANY,
	   d.REQ_LOCATION,
       a.VEN_ITEM,
       a.CLOSED_FL,
       a.CXL_QTY,
       c.INVOICE_AMT
INTO   #tmpPOLines
FROM   POLINE a
       INNER JOIN PURCHORDER b
              ON a.PO_NUMBER = b.PO_NUMBER
                 AND a.COMPANY = b.COMPANY
                 AND a.PO_CODE = b.PO_CODE
				 AND a.PO_RELEASE = b.PO_RELEASE
       LEFT JOIN (SELECT PO_NUMBER,
                         LINE_NBR,
                         Sum(TOT_DIST_AMT) AS INVOICE_AMT
                  FROM   MAINVDTL
                  GROUP  BY PO_NUMBER,
                            LINE_NBR) c
              ON a.PO_NUMBER = c.PO_NUMBER
                 AND a.LINE_NBR = c.LINE_NBR
       LEFT JOIN POLINESRC d
              ON a.COMPANY = d.COMPANY
                 AND a.PO_NUMBER = d.PO_NUMBER
                 AND a.LINE_NBR = d.LINE_NBR
                 AND a.PO_CODE = d.PO_CODE
				 AND a.PO_RELEASE = d.PO_RELEASE
WHERE  b.PO_DATE >= (select ConfigValue from bluebin.Config where ConfigName = 'PO_DATE') 
		--AND b.PO_RELEASE = 0
       AND a.CXL_QTY = 0
	   
	   --and a.PO_NUMBER like '%380479%'


--#tmpMMDIST
SELECT a.DOC_NUMBER    AS PO_NUMBER,
       a.LINE_NBR,
       a.ACCT_UNIT,
       b.DESCRIPTION AS ACCT_UNIT_NAME
INTO #tmpMMDIST
FROM   MMDIST a
inner join (select COMPANY,DOC_NUMBER,LINE_NBR,max(LINE_SEQ) as LINE_SEQ from MMDIST WHERE  SYSTEM_CD = 'PO' AND DOC_TYPE = 'PT' group by COMPANY,DOC_NUMBER,LINE_NBR) sq on a.COMPANY = sq.COMPANY and a.DOC_NUMBER = sq.DOC_NUMBER and a.LINE_NBR = sq.LINE_NBR and a.LINE_SEQ = sq.LINE_SEQ
       LEFT JOIN GLNAMES b
              ON a.COMPANY = b.COMPANY
                 AND a.ACCT_UNIT = b.ACCT_UNIT
WHERE  SYSTEM_CD = 'PO'
       AND DOC_TYPE = 'PT'
       AND a.DOC_NUMBER IN (SELECT PO_NUMBER
                          FROM   PURCHORDER
                          WHERE  PO_DATE >= (select ConfigValue from bluebin.Config where ConfigName = 'PO_DATE'))
						  --and a.DOC_NUMBER like '%380479%'
						  --and a.DOC_NUMBER like '%389266%' order by 2


--#tmpPOStatus
SELECT Row_number()
         OVER(
           ORDER BY a.PO_NUMBER, a.LINE_NBR) AS POKey,
       COMPANY                           AS Company,
       a.PO_NUMBER                         AS PONumber,
       a.LINE_NBR                          AS POLineNumber,
       PO_RELEASE                        AS PORelease,
       PO_CODE                           AS POCode,
       ITEM                              AS ItemNumber,
	   a.VENDOR                            AS VendorCode,
	   d.VENDOR_VNAME					AS VendorName,
       a.BUYER_CODE                        AS Buyer,
	   c.NAME							AS BuyerName,
       LOCATION                          AS ShipLocation,
       ACCT_UNIT                         AS AcctUnit,
       ACCT_UNIT_NAME                    AS AcctUnitName,
       PO_DESCRIPTION                    AS PODescr,
       QUANTITY                          AS QtyOrdered,
       REC_QTY                           AS QtyReceived,
       AGREEMENT_REF                     AS AgrmtRef,
       ENT_UNIT_CST                      AS UnitCost,
       ENT_BUY_UOM                       AS BuyUOM,
       EBUY_UOM_MULT                     AS BuyUOMMult,
	   ENT_UNIT_CST/EBUY_UOM_MULT		 AS IndividualCost,
       PO_DATE                           AS PODate,
       EARLY_DL_DATE                     AS ExpectedDeliveryDate,
       LATE_DL_DATE                      AS LateDeliveryDate,
       REC_ACT_DATE                      AS ReceivedDate,
       CLOSE_DATE                        AS CloseDate,
       REQ_LOCATION                      AS PurchaseLocation,
       OPER_COMPANY                      AS PurchaseFacility,
	   VEN_ITEM                          AS VendorItemNbr,
       CLOSED_FL                         AS ClosedFlag,
       CXL_QTY                           AS QtyCancelled,
       QUANTITY * ENT_UNIT_CST           AS POAmt,
       INVOICE_AMT                       AS InvoiceAmt,
       ITEM_TYPE                         AS POItemType,
       CASE
         WHEN ITEM_TYPE = 'S' THEN 0
         ELSE
           CASE
             WHEN REC_QTY = 0 THEN 0
             ELSE INVOICE_AMT - ( REC_QTY * ENT_UNIT_CST )
           END
       END                               AS PPV,
       1                                 AS POLine
INTO #tmpPOStatus
FROM   #tmpPOLines a
       LEFT JOIN #tmpMMDist b
              ON a.PO_NUMBER = b.PO_NUMBER
                 AND a.LINE_NBR = b.LINE_NBR 
		LEFT JOIN (select distinct BUYER_CODE,NAME from BUYER) c
		ON a.BUYER_CODE = c.BUYER_CODE
		LEFT JOIN APVENMAST d ON a.VENDOR = d.VENDOR


--#tmpPOs

SELECT *,
CASE WHEN ClosedFlag = 'Y' THEN 'Closed' ELSE
	CASE WHEN QtyReceived + QtyCancelled = QtyOrdered THEN 'Closed' ELSE 'Open' END
	END 																as POStatus,
CASE WHEN POItemType = 'S' THEN 'N/A' ELSE
	CASE WHEN Dateadd(day, 3, ExpectedDeliveryDate) <= GETDATE() AND (QtyReceived+QtyCancelled < QtyOrdered) THEN 'Late' ELSE
		CASE WHEN Dateadd(day, 3, ExpectedDeliveryDate) > GETDATE() THEN 'In-Progress' ELSE
			CASE WHEN ReceivedDate <= Dateadd(day, 3, ExpectedDeliveryDate) AND (QtyReceived + QtyCancelled) = QtyOrdered THEN 'On-Time' ELSE 'Late' END
		END	
	
	END

END as PODeliveryStatus
INTO #tmpPOs
FROM #tmpPOStatus


/*************************		CREATE Sourcing		****************************/

SELECT a.*,
       CASE
         WHEN a.PODeliveryStatus = 'In-Progress' THEN 1
         ELSE 0
       END AS InProgress,
       CASE
         WHEN a.PODeliveryStatus = 'On-Time' THEN 1
         ELSE 0
       END AS OnTime,
       CASE
         WHEN a.PODeliveryStatus = 'Late' THEN 1
         ELSE 0
       END AS Late,
	   case when dl.BlueBinFlag = 1 then 'Yes' else 'No' end as BlueBinFlag,
	   df.FacilityName

INTO   tableau.Sourcing 
FROM   #tmpPOs a
LEFT JOIN bluebin.DimLocation dl on ltrim(rtrim(a.PurchaseLocation)) = ltrim(rtrim(dl.LocationID)) and ltrim(rtrim(a.PurchaseFacility)) = ltrim(rtrim(dl.LocationFacility))
LEFT JOIN bluebin.DimFacility df on ltrim(rtrim(a.PurchaseFacility)) = ltrim(rtrim(df.FacilityID))
/***********************		DROP Temp Tables	**************************/

DROP TABLE #tmpPOLines
DROP TABLE #tmpMMDIST
DROP TABLE #tmpPOStatus
DROP TABLE #tmpPOs

GO

UPDATE etl.JobSteps
SET LastModifiedDate = GETDATE()
WHERE StepName = 'Sourcing'

GO
grant exec on tb_Sourcing to public
GO





/*******************************************************************************


			Contracts


*******************************************************************************/


IF EXISTS ( SELECT  *
            FROM    sys.objects
            WHERE   object_id = OBJECT_ID(N'tb_Contracts')
                    AND type IN ( N'P', N'PC' ) ) 

DROP PROCEDURE  tb_Contracts
GO

CREATE PROCEDURE tb_Contracts

AS

BEGIN TRY
    DROP TABLE tableau.Contracts
END TRY

BEGIN CATCH
END CATCH

SELECT Date,
       VEN_AGRMT_REF AS ContractID,
       AGMT_TYPE     AS ContractType,
       a.VENDOR        AS VendorNumber,
	   b.VENDOR_VNAME	AS VendorName,
       a.ITEM          AS ItemNumber,
	   c.DESCRIPTION	AS ItemDescription,
       VEN_ITEM      AS VendorItemNumber,
       CURR_NET_CST  AS CurrentCost,
       UOM,
       UOM_MULT      AS UOMMult,
       PRIORITY      AS Priority,
       HOLD_FLAG     AS HoldFlag,
       EFFECTIVE_DT  AS EffectiveDate,
       EXPIRE_DT     AS ExpireDate
INTO   tableau.Contracts
FROM   bluebin.DimDate
       LEFT JOIN POVAGRMTLN a
              ON EXPIRE_DT = Date 
		LEFT JOIN APVENMAST b ON a.VENDOR = b.VENDOR
		LEFT JOIN ITEMMAST c ON a.ITEM = c.ITEM
		select EFFECTIVE_DT,count(*) from POVAGRMTLN group by EFFECTIVE_DT
GO

UPDATE etl.JobSteps
SET LastModifiedDate = GETDATE()
WHERE StepName = 'Contracts'

select top 100* from tableau.Sourcing where VendorName is null

GO

grant exec on tb_Contracts to public
GO

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



SELECT 
		--d.LocationID,
		a.COMPANY,
		df.FacilityName,
		a.LOCATION as LocationID,
		a.LOCATION as LocationName,
		b.ItemKey,
       b.ItemID,
       b.ItemDescription,
       b.ItemClinicalDescription,
       b.ItemManufacturer,
       b.ItemManufacturerNumber,
       b.ItemVendor,
       b.ItemVendorNumber,
       a.Bins.COMPARTMENT    AS StockLocation,
       a.SOH_QTY       AS SOHQty,
       a.MAX_ORDER     AS ReorderQty,
       a.REORDER_POINT AS ReorderPoint,
	   a.LAST_ISS_COST	AS UnitCost,
       b.StockUOM,
       b.BuyUOM,
       b.PackageString
INTO   bluebin.DimWarehouseItem
FROM   ITEMLOC a
       INNER JOIN bluebin.DimItem b
               ON a.ITEM = b.ItemID
		INNER JOIN bluebin.DimFacility df on a.COMPANY = df.FacilityID
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

WHERE a.LOCATION in (Select ConfigValue from bluebin.Config where ConfigName = 'LOCATION')


GO

UPDATE etl.JobSteps
SET LastModifiedDate = GETDATE()
WHERE StepName = 'Warehouse Item'

GO



Print 'ETL Sprocs updated'
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

INSERT INTO bluebin.DimFacility 
	SELECT
	COMPANY as FacilityID,
	NAME as FacilityName

    FROM   dbo.APCOMPANY a
	left join bluebin.DimFacility df on a.COMPANY = df.FacilityID 
	where df.FacilityID is null
	
END 
;

    INSERT INTO bluebin.DimFacility 
	SELECT
	COMPANY as FacilityID,
	NAME as FacilityName

    FROM   dbo.APCOMPANY a
	left join bluebin.DimFacility df on a.COMPANY = df.FacilityID 
	where df.FacilityID is null
;
update bluebin.DimFacility set FacilityName = a.fn from
(select COMPANY as fi,NAME as fn from APCOMPANY) as a
where FacilityID = a.fi and FacilityName <> a.fn
;

UPDATE etl.JobSteps
SET LastModifiedDate = GETDATE()
WHERE StepName = 'DimFacility'
GO



/********************************************************************

					Warehouse History

********************************************************************/



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




--*********************************************************************************************
--Tableau Sproc  These load data into the datasources for Tableau
--*********************************************************************************************

if exists (select * from dbo.sysobjects where id = object_id(N'tb_CostVariance') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure tb_CostVariance
GO

--tb_CostVariance

CREATE PROCEDURE tb_CostVariance

--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON



SELECT f.ITEM,
       f.DESCRIPTION,
       Min(e.PO_DATE)   AS EFF_DATE,
       Max(e.PO_DATE)   AS EXP_DATE,
       Sum(c.QUANTITY)  AS QUANTITY,
       c.ENT_BUY_UOM    AS UOM,
       (d.MATCH_UNIT_CST/c.EBUY_UOM_MULT) AS UNIT_COST,
       h.ISS_ACCOUNT
INTO   #PriceHist
FROM   POLINE c
       INNER JOIN MAINVDTL d
               ON c.COMPANY = d.COMPANY
                  AND c.PO_NUMBER = d.PO_NUMBER
                  AND c.LINE_NBR = d.LINE_NBR
                  AND c.PO_CODE = d.PO_CODE
       INNER JOIN PURCHORDER e
               ON c.PO_NUMBER = e.PO_NUMBER
       INNER JOIN ITEMMAST f
               ON c.ITEM = f.ITEM
       LEFT JOIN (SELECT *
                  FROM   ITEMLOC
                  WHERE  LOCATION in (Select ConfigValue from bluebin.Config where ConfigName = 'LOCATION')) g
              ON c.ITEM = g.ITEM
       LEFT JOIN ICCATEGORY h
              ON g.COMPANY = h.COMPANY
                 AND g.LOCATION = h.LOCATION
                 AND g.GL_CATEGORY = h.GL_CATEGORY
WHERE  c.ITEM_TYPE IN ( 'I', 'N' )
       AND CXL_QTY = 0
       AND Year(PO_DATE) >= Year(Getdate()) - 1
GROUP  BY f.ITEM,
          f.DESCRIPTION,
          c.ENT_BUY_UOM,
		  c.EBUY_UOM_MULT,
          d.MATCH_UNIT_CST,
          h.ISS_ACCOUNT

SELECT Row_number()
         OVER(
           PARTITION BY ITEM, UOM
           ORDER BY QUANTITY DESC) AS PriceSeq,
       ITEM,
       DESCRIPTION,
       EFF_DATE,
	   EXP_DATE,
       QUANTITY,
       UOM,
       UNIT_COST,
	   ISS_ACCOUNT
INTO   #PriceSeq
FROM   #PriceHist

SELECT *
INTO   #ModePrice
FROM   #PriceSeq
WHERE  PriceSeq = 1

SELECT c.PO_NUMBER,
       c.LINE_NBR,
       c.ITEM,
       c.DESCRIPTION,
       c.ITEM_TYPE,
       e.PO_DATE,
       c.QUANTITY,
       c.ENT_BUY_UOM,
       (c.ENT_UNIT_CST/c.EBUY_UOM_MULT)	as ENT_UNIT_CST,
       (d.MATCH_UNIT_CST/c.EBUY_UOM_MULT) as MATCH_UNIT_CST
INTO   #POHistory
FROM   POLINE c
       INNER JOIN MAINVDTL d
               ON c.COMPANY = d.COMPANY
                  AND c.PO_NUMBER = d.PO_NUMBER
                  AND c.LINE_NBR = d.LINE_NBR
                  AND c.PO_CODE = d.PO_CODE
       INNER JOIN PURCHORDER e
               ON c.PO_NUMBER = e.PO_NUMBER
       INNER JOIN ITEMMAST f
               ON c.ITEM = f.ITEM
WHERE  c.ITEM_TYPE IN ( 'I', 'N' )
       AND CXL_QTY = 0
       AND Year(PO_DATE) >= Year(Getdate()) - 1

SELECT a.*,
       b.UNIT_COST                                AS ModePrice,
       a.QUANTITY * ( a.UNIT_COST - b.UNIT_COST ) AS Variance
FROM   #PriceSeq a
       INNER JOIN #ModePrice b
               ON a.ITEM = b.ITEM
                  AND a.UOM = b.UOM
       LEFT JOIN #POHistory c
              ON a.ITEM = c.ITEM
                 AND a.UOM = c.ENT_BUY_UOM
                 AND a.UNIT_COST = c.MATCH_UNIT_CST
                 AND a.EFF_DATE <= c.PO_DATE
                 AND a.EXP_DATE >= c.PO_DATE 
ORDER by 2, 1
END
GO
grant exec on tb_CostVariance to public
GO
--DROP TABLE #PriceHist
--DROP TABLE #PriceSeq
--DROP TABLE #ModePrice
--DROP TABLE #POHistory


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

SELECT FISCAL_YEAR                                                                                                                                                                                                  AS FiscalYear,
       ACCT_PERIOD                                                                                                                                                                                                  AS AcctPeriod,
       a.COMPANY,
	   df.FacilityName,
	   a.ACCOUNT                                                                                                                                                                                                    AS Account,
       b.ACCOUNT_DESC                                                                                                                                                                                               AS AccountDesc,
       a.ACCT_UNIT                                                                                                                                                                                                  AS AcctUnit,
       c.DESCRIPTION                                                                                                                                                                                                AS AcctUnitName,
       Cast(CONVERT(VARCHAR, CASE WHEN ACCT_PERIOD <= 3 THEN ACCT_PERIOD + 9 ELSE ACCT_PERIOD - 3 END) + '/1/' + CONVERT(VARCHAR, CASE WHEN ACCT_PERIOD <=3 THEN FISCAL_YEAR - 1 ELSE FISCAL_YEAR END) AS DATETIME) AS Date,
       Sum(TRAN_AMOUNT)                                                                                                                                                                                             AS Amount
FROM   GLTRANS a
       INNER JOIN GLCHARTDTL b
               ON a.ACCOUNT = b.ACCOUNT
       INNER JOIN GLNAMES c
               ON a.ACCT_UNIT = c.ACCT_UNIT
                  AND a.COMPANY = c.COMPANY
		left join bluebin.DimFacility df on a.COMPANY = df.FacilityID
WHERE  SUMRY_ACCT_ID in (select ConfigValue from bluebin.Config where ConfigName = 'GLSummaryAccountID')
GROUP  BY FISCAL_YEAR,
          ACCT_PERIOD,
          a.COMPANY,
			df.FacilityName,
			a.ACCOUNT,
          b.ACCOUNT_DESC,
          a.ACCT_UNIT,
          c.DESCRIPTION 


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
	a.COMPANY,
	df.FacilityName,
	a.ITEM as LawsonItemNumber,
	ISNULL(c.MANUF_NBR,'N/A') as ItemManufacturerNumber,
	case when @UseClinicalDescription = 1 then
		case 
			when b.ClinicalDescription is null or b.ClinicalDescription = ''  then
			case
				when a.USER_FIELD3 is null or a.USER_FIELD3 = ''  then
				case	
					when a.USER_FIELD1 is null or a.USER_FIELD1 = '' then 
					case 
						when c.DESCRIPTION is null or c.DESCRIPTION = '' then '*NEEDS*'
					else c.DESCRIPTION  end 
				else a.USER_FIELD1 end
			else a.USER_FIELD3 end
		else b.ClinicalDescription end	
	else c.DESCRIPTION
	end as ClinicalDescription,
	a.LOCATION as LocationCode,
	a.NAME as LocationName,
	a.Cart,
	a.Row,
	a.Position
FROM 
(SELECT 
	a.COMPANY,
	ITEM,
	LOCATION,
	b.NAME,
	USER_FIELD1,
	USER_FIELD3,
	CASE WHEN ISNUMERIC(left(Bins.COMPARTMENT,1))=1 then LEFT(Bins.COMPARTMENT,2) 
		else CASE WHEN Bins.COMPARTMENT LIKE '[A-Z][A-Z]%' THEN LEFT(Bins.COMPARTMENT, 2) ELSE LEFT(Bins.COMPARTMENT, 1) END END as Cart,
	CASE WHEN ISNUMERIC(left(Bins.COMPARTMENT,1))=1 then SUBSTRING(Bins.COMPARTMENT, 3, 1) 
		else CASE WHEN Bins.COMPARTMENT LIKE '[A-Z][A-Z]%' THEN SUBSTRING(Bins.COMPARTMENT, 3, 1) ELSE SUBSTRING(Bins.COMPARTMENT, 2,1) END END as Row,
	CASE WHEN ISNUMERIC(left(Bins.COMPARTMENT,1))=1 then SUBSTRING(Bins.COMPARTMENT, 4, 2)
		else CASE WHEN Bins.COMPARTMENT LIKE '[A-Z][A-Z]%' THEN SUBSTRING (Bins.COMPARTMENT,4,2) ELSE SUBSTRING(Bins.COMPARTMENT, 3,2) END END as Position	
FROM ITEMLOC a 
INNER JOIN RQLOC b ON a.LOCATION = b.REQ_LOCATION and a.COMPANY = b.COMPANY
WHERE LEFT(REQ_LOCATION, 2) IN (SELECT [ConfigValue] FROM   [bluebin].[Config] WHERE  [ConfigName] = 'REQ_LOCATION' AND Active = 1) or REQ_LOCATION in (Select REQ_LOCATION from bluebin.ALT_REQ_LOCATION)) a
LEFT JOIN 
(SELECT 
	ITEM, 
	max(USER_FIELD3) as ClinicalDescription
FROM ITEMLOC 
WHERE LOCATION IN (SELECT [ConfigValue] FROM [bluebin].[Config] WHERE  [ConfigName] = 'LOCATION' AND Active = 1) AND LEN(LTRIM(USER_FIELD3) ) > 0 group by ITEM
) b
ON a.ITEM = b.ITEM

left join ITEMMAST c on a.ITEM = c.ITEM
left join bluebin.DimFacility df on a.COMPANY = df.FacilityID



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


SELECT 
a.COMPANY,
df.FacilityName,
CREATION_DATE   AS Date,
       CASE
         WHEN LEFT(a.REQ_LOCATION, 2) IN (SELECT ConfigValue
                                          FROM   [bluebin].[Config]
                                          WHERE  ConfigName = 'REQ_LOCATION') 
											or 
										  a.REQ_LOCATION in (Select REQ_LOCATION from bluebin.ALT_REQ_LOCATION) 
										  THEN 'BlueBin'
         ELSE 'Non BlueBin'
       END             AS LineType,
       b.ISS_ACCT_UNIT AS AcctUnit,
       ISNULL(c.DESCRIPTION,'Unknown')   AS AcctUnitName,
       a.REQ_LOCATION  AS Location,
       b.NAME          AS LocationName,
       1               AS LineCount

FROM   REQLINE a
       INNER JOIN RQLOC b
               ON a.COMPANY = b.COMPANY
                  AND a.REQ_LOCATION = b.REQ_LOCATION
       LEFT JOIN GLNAMES c
               ON b.COMPANY = c.COMPANY
                  AND b.ISS_ACCT_UNIT = c.ACCT_UNIT 
	   INNER JOIN bluebin.DimFacility df on rtrim(a.COMPANY) = rtrim(df.FacilityID)
order by 2
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


SELECT
    a.FROM_TO_CMPY,
	df.FacilityName,
	--a.LOCATION,
	b.REQ_LOCATION as LocationID,
	dl.LocationName,
	case when dl.BlueBinFlag = 1 then 'Yes' else 'No' end as BlueBinFlag,
	TRANS_DATE as Date,
    COUNT(*) as StatCalls,
    case when c.ACCT_UNIT is null then 'None' else LTRIM(RTRIM(c.ACCT_UNIT)) + ' - '+ c.DESCRIPTION  end as Department
FROM
    ICTRANS a 
INNER JOIN
RQLOC b ON a.FROM_TO_CMPY = b.COMPANY AND a.FROM_TO_LOC = b.REQ_LOCATION
LEFT JOIN GLNAMES c ON b.COMPANY = c.COMPANY AND b.ISS_ACCT_UNIT = c.ACCT_UNIT
INNER JOIN bluebin.DimFacility df on a.FROM_TO_CMPY = df.FacilityID
INNER JOIN bluebin.DimLocation dl on b.REQ_LOCATION = dl.LocationID
WHERE SYSTEM_CD = 'IC' AND DOC_TYPE = 'IS' --and dl.BlueBinFlag = 1
GROUP BY
    a.FROM_TO_CMPY,
	df.FacilityName,
	--a.LOCATION,
	b.REQ_LOCATION,
	dl.LocationName,
	dl.BlueBinFlag,
	TRANS_DATE,
    c.ACCT_UNIT,
    c.DESCRIPTION
Order by TRANS_DATE desc


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
       ,Sum(CASE
             WHEN TRANS_DATE >= Dateadd(YEAR, Datediff(YEAR, 0, Dateadd(YEAR, -1, Getdate())), 0)
                  AND TRANS_DATE <= Dateadd(YEAR, -1, Getdate()) THEN b.QUANTITY * -1
             ELSE 0
           END) / Month(Getdate()) AS LYYTDIssueQty,
       Sum(CASE
             WHEN TRANS_DATE >= Dateadd(YEAR, Datediff(YEAR, 0, Getdate()), 0) THEN b.QUANTITY * -1
             ELSE 0
           END) / Month(Getdate()) AS CYYTDIssueQty
FROM   bluebin.DimWarehouseItem a
       LEFT JOIN ICTRANS b
               ON ltrim(rtrim(a.ItemID)) = ltrim(rtrim(ITEM)) 
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
	SUM(SOH * UnitCost) as DollarsOnHand,
	LocationID,
	LocationID as LocationName
FROM bluebin.FactWarehouseSnapshot a
WHERE SOH > 0
GROUP BY
	
	SnapshotDate,
	FacilityName,
	LocationID 


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

select 
rq.CREATION_DATE,
rq.COMPANY,
df.FacilityName,
rq.REQ_LOCATION,
rq.REQ_NUMBER,
rq.LINE_NBR as Lines,
r.NAME,
dl.BlueBinFlag
from REQLINE rq
inner join bluebin.DimLocation dl on rtrim(rq.COMPANY) = rtrim(dl.LocationFacility) and rq.REQ_LOCATION = dl.LocationID
inner join bluebin.DimFacility df on rtrim(rq.COMPANY) = rtrim(df.FacilityID)
inner join REQHEADER rh on rq.REQ_NUMBER = rh.REQ_NUMBER
left join REQUESTER r on rh.REQUESTER = r.REQUESTER and rq.COMPANY = r.COMPANY
where rq.CREATION_DATE > getdate()-15



GO
grant exec on tb_OrderVolume to public
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

WHERE fi.IssueDate > getdate() -15 and fi.LocationID in (select ConfigValue from bluebin.Config where ConfigName = 'LOCATION') --Filter for HB

GROUP  BY df.FacilityName,fi.LocationID,Cast(fi.IssueDate AS DATE)
order by 1,2,3 



END
GO
grant exec on tb_HBPickLines to public
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


SELECT
    a.FROM_TO_CMPY,
	df.FacilityName,
	--a.LOCATION,
	b.REQ_LOCATION,
	dl.BlueBinFlag,
	TRANS_DATE as Date,
    COUNT(*) as StatCalls,
    case when c.ACCT_UNIT is null then 'None' else LTRIM(RTRIM(c.ACCT_UNIT)) + ' - '+ c.DESCRIPTION  end as Department
FROM
    ICTRANS a 
INNER JOIN
RQLOC b ON a.FROM_TO_CMPY = b.COMPANY AND a.FROM_TO_LOC = b.REQ_LOCATION
LEFT JOIN GLNAMES c ON b.COMPANY = c.COMPANY AND b.ISS_ACCT_UNIT = c.ACCT_UNIT
INNER JOIN bluebin.DimFacility df on a.FROM_TO_CMPY = df.FacilityID
INNER JOIN bluebin.DimLocation dl on b.REQ_LOCATION = dl.LocationID
WHERE SYSTEM_CD = 'IC' AND DOC_TYPE = 'IS' and TRANS_DATE > getdate() -15---and dl.BlueBinFlag = 1
GROUP BY
    a.FROM_TO_CMPY,
	df.FacilityName,
	--a.LOCATION,
	b.REQ_LOCATION,
	dl.BlueBinFlag,
	TRANS_DATE,
    c.ACCT_UNIT,
    c.DESCRIPTION
Order by TRANS_DATE desc

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
OrderNum as [Order Num],
ltrim(rtrim(p.PO_NUMBER)) as [PO Num],
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
left outer join POLINESRC p on k.OrderNum = p.SOURCE_DOC_N and k.LineNum = p.SRC_LINE_NBR

where 
--Date > getdate()-10 and 
ScanHistseq > (select ConfigValue from bluebin.Config where ConfigName = 'ScanThreshold') and 
OrderCloseDate is null and 
OrderDate is not null

group by
OrderNum,
p.PO_NUMBER,
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