/*
--*************************
PEOPLESOFT SPECIFIC UPGRADE SCRIPTS
--*************************

Upgrade Script to copy in the etl_ and tb_ sprocs used in both the daily etl and to populate data sources in the Tableau WOrkbooks
20160927 - Updated by Gerry Butler

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


/***********************************************************

			Sourcing

***********************************************************/

IF EXISTS ( SELECT  *
            FROM    sys.objects
            WHERE   object_id = OBJECT_ID(N'tb_Sourcing')
                    AND type IN ( N'P', N'PC' ) ) 

DROP PROCEDURE  tb_Sourcing
GO

CREATE PROCEDURE	tb_Sourcing
--exec tb_Sourcing  select * from tableau.Sourcing
AS

/********************************		DROP Sourcing		**********************************/

BEGIN TRY
    DROP TABLE tableau.Sourcing
END TRY

BEGIN CATCH
END CATCH



/**********************************		CREATE Temp Tables		***************************/
/*
select distinct BUSINESS_UNIT from PO_HDR
select top 100* from PO_HDR
select top 100* from PO_LINE
select top 1000* from PO_LINE_DISTRIB
select top 100* from RECV_LN_SHIP --where INV_ITEM_ID = '206460'
select top 100* from MASTER_ITEM_TBL
select top 100* from BRAND_NAMES_INV
select top 100* from PURCH_ITEM_ATTR
select top 100* from PURCH_ITEM_BU
select top 1000* from MANUFACTURER order by 3
select * from insert select * into Stanford_LPCH.tableau.Sourcing from OSUMC.tableau.Sourcing
select top 1000* from OSUMC.tableau.Sourcing
select * from tableau.Sourcing where PONumber = '0000404739'
select * from etl.JobSteps
update etl.JobSteps set ActiveFlag = 1 where StepName in ('Sourcing')

*/
-- #tmpPOLines
declare @Facility int
   select @Facility = ConfigValue from bluebin.Config where ConfigName = 'PS_DefaultFacility'
declare @POTimeAdjust int = (Select max(ConfigValue) from bluebin.Config where ConfigName = 'PS_POTimeAdjust')
  
;
With A as (
SELECT Row_number()
                  OVER(
                    ORDER BY PO_LN.PO_ID, PO_LN.LINE_NBR) AS POKey,
                @Facility as Company,
				PO_LN.PO_ID as PONumber,
				--PO_LN.PO_ID as PONumber,
				PO_LN.LINE_NBR AS POLineNumber,
				0 as PORelease,							--NEED
				PO_LN.PO_ID AS POCode,
                PO_LN.INV_ITEM_ID  AS ItemNumber,
                PO_HDR.VENDOR_ID as VendorCode,
				ISNULL(v.VENDOR_NAME_SHORT,'N/A') as VendorName,					
				PO_HDR.BUYER_ID as Buyer,
				PO_HDR.BUYER_ID as BuyerName,			
				PO_LN_DST.BUSINESS_UNIT as ShipLocation,					
				PO_LN_DST.ACCOUNT as AcctUnit,			
				gl.DESCR as AcctUnitName,						
				PO_LN.DESCR254_MIXED as PODescr, -- Original   MIT.DESCR as PODescr,
				case when PO_LN_DST.QTY_PO = '' then 0 else PO_LN_DST.QTY_PO end as QtyOrdered,
				case
					when ISNULL(PO_LN.CANCEL_STATUS,'') IN ( 'X', 'D', 'PX') OR SHIP.RECEIPT_DTTM is NULL then 0 else PO_LN_DST.QTY_PO end as QtyReceived, --May need to add , 'C', 'PX'		
				PO_LN.CNTRCT_ID as AgrmtRef,
				case when PO_LN_DST.QTY_PO = 0 then 0 else PO_LN_DST.MERCHANDISE_AMT/PO_LN_DST.QTY_PO end as UnitCost,							
				PO_LN.UNIT_OF_MEASURE as BuyUOM,
				1 as BuyUOMMult,						--NEED
				case when PO_LN_DST.QTY_PO = 0 then 0 else PO_LN_DST.MERCHANDISE_AMT/PO_LN_DST.QTY_PO end as IndividualCost,					
				DATEADD(hour,@POTimeAdjust,PO_HDR.PO_DT) as PODate,
				--PO_HDR.PO_DT as PODate,
				(DATEADD(day,((@POTimeAdjust/24)+convert(int,(Select max(ConfigValue) from bluebin.Config where ConfigName = 'DefaultLeadTime') )),PO_HDR.PO_DT)) as ExpectedDeliveryDate,				
				'' as LateDeliveryDate,					
				SHIP.RECEIPT_DTTM as ReceivedDate,
				SHIP.RECEIPT_DTTM as CloseDate,			
				PO_LN_DST.LOCATION AS PurchaseLocation,
                @Facility as PurchaseFacility,
				case when ISNULL(PO_LN_DST.DISTRIB_LN_STATUS,'') in ('M','X','C') or ISNULL(PO_LN.CANCEL_STATUS,'') IN ( 'X', 'C') then 'Y' else 'N' end  as ClosedFlag,						
				case
					when ISNULL(PO_LN.CANCEL_STATUS,'') IN ( 'X', 'D' , 'PX') or ISNULL(PO_LN_DST.DISTRIB_LN_STATUS,'') in ('M','X') then PO_LN_DST.QTY_PO else 0 end as QtyCancelled,	--May need to add , 'C', 'PX'					
				PO_LN_DST.MERCHANDISE_AMT as POAmt,							
				PO_LN_DST.MERCHANDISE_AMT as InvoiceAmt,
				PO_LN_DST.LOCATION as DeliverToNew,						
				Case 
					When PO_LN.QTY_TYPE = 'S' and PO_LN.PRICE_DT_TYPE = 'D' then 'X'
					When PO_LN.QTY_TYPE = 'L' and PO_LN.PRICE_DT_TYPE = 'P' then 'N'  
					else 'I' end as POItemType,						
				0 as PPV,								
				1 as POLine		
  
         FROM   dbo.PO_LINE_DISTRIB PO_LN_DST
                INNER JOIN dbo.PO_LINE PO_LN
                        ON PO_LN_DST.PO_ID = PO_LN.PO_ID
                           AND PO_LN_DST.LINE_NBR = PO_LN.LINE_NBR
                INNER JOIN dbo.PO_HDR
                        ON PO_LN.PO_ID = PO_HDR.PO_ID
                LEFT JOIN
					(select PO_ID,LINE_NBR,max(RECEIPT_DTTM) as RECEIPT_DTTM from dbo.RECV_LN_SHIP group by PO_ID,LINE_NBR) SHIP
						ON PO_LN.PO_ID = SHIP.PO_ID
                          AND PO_LN.LINE_NBR = SHIP.LINE_NBR
				--LEFT JOIN MASTER_ITEM_TBL MIT on PO_LN.INV_ITEM_ID = MIT.INV_ITEM_ID
				LEFT JOIN 
					(select g.ACCOUNT,g.ACCOUNT_TYPE,g.DESCR from GL_ACCOUNT_TBL g
					inner join (select ACCOUNT,max(EFFDT) as EFFDT from GL_ACCOUNT_TBL where EFF_STATUS = 'A' group by ACCOUNT) a on g.ACCOUNT = a.ACCOUNT and g.EFFDT = a.EFFDT
					) gl ON PO_LN_DST.ACCOUNT = gl.ACCOUNT 
				LEFT JOIN VENDOR v on PO_HDR.VENDOR_ID = v.VENDOR_ID
				LEFT JOIN bluebin.DimLocation dl on PO_LN_DST.LOCATION = dl.LocationID
				--LEFT JOIN (select INV_ITEM_ID,max(LAST_PO_PRICE_PAID) as Price from PURCH_ITEM_ATTR group by INV_ITEM_ID) pia on PO_LN.INV_ITEM_ID = pia.INV_ITEM_ID
				
				--select * from GL_ACCOUNT_TBL where ACCOUNT = '732900'
				

		 WHERE  PO_HDR.PO_DT >= (select ConfigValue from bluebin.Config where ConfigName = 'PO_DATE') 
                AND (ISNULL(PO_LN.CANCEL_STATUS,'') NOT IN ( 'X', 'D' ) or ISNULL(PO_LN_DST.DISTRIB_LN_STATUS,'') NOT in ('M','X'))

)
,
B as (
SELECT A.*,
CASE WHEN ClosedFlag = 'Y' THEN 'Closed' ELSE
	CASE WHEN QtyReceived + QtyCancelled >= QtyOrdered THEN 'Closed' ELSE 'Open' END
	END 																as POStatus,
CASE WHEN POItemType = 'S' THEN 'N/A' ELSE
	CASE WHEN Dateadd(day, 3, ExpectedDeliveryDate) <= GETDATE() AND (QtyReceived+QtyCancelled < QtyOrdered) THEN 'Late' ELSE
		CASE WHEN Dateadd(day, 3, ExpectedDeliveryDate) > GETDATE() THEN 'In-Progress' ELSE
			CASE WHEN ReceivedDate <= Dateadd(day, 3, ExpectedDeliveryDate) AND (QtyReceived + QtyCancelled) >= QtyOrdered THEN 'On-Time' ELSE 'Late' END
		END	
	
	END

END as PODeliveryStatus

FROM A)

SELECT B.*,
       CASE
         WHEN B.PODeliveryStatus = 'In-Progress' THEN 1
         ELSE 0
       END AS InProgress,
       CASE
         WHEN B.PODeliveryStatus = 'On-Time' THEN 1
         ELSE 0
       END AS OnTime,
       CASE
         WHEN B.PODeliveryStatus = 'Late' THEN 1
         ELSE 0
       END AS Late,
	   case when dl.BlueBinFlag = 1 then 'Yes' else 'No' end as BlueBinFlag,
	   df.FacilityName,
	   dl.LocationName,
	   iv.ITM_ID_VNDR as VendorItemNbr

INTO   tableau.Sourcing 
FROM   B
LEFT JOIN bluebin.DimLocation dl on ltrim(rtrim(B.PurchaseLocation)) = ltrim(rtrim(dl.LocationID)) and ltrim(rtrim(B.PurchaseFacility)) = ltrim(rtrim(dl.LocationFacility))
LEFT JOIN bluebin.DimFacility df on ltrim(rtrim(B.PurchaseFacility)) = ltrim(rtrim(df.FacilityID))
LEFT JOIN (select VENDOR_ID,ITM_ID_VNDR,INV_ITEM_ID from ITM_VENDOR where ITM_STATUS = 'A') iv on B.ItemNumber = iv.INV_ITEM_ID and B.VendorCode = iv.VENDOR_ID
where QtyOrdered > 0
--where ItemNumber= '0761925'
--where dl.BlueBinFlag = 1

GO

UPDATE etl.JobSteps
SET LastModifiedDate = GETDATE()
WHERE StepName = 'Sourcing'

GO
grant exec on tb_Sourcing to public
GO







--/******************************************

--			DimItem

--******************************************/
--Updated GB 20180413 Added Last Po Date, Item Vendor #
--Updated GB 20180219 Added Expireable

IF EXISTS ( SELECT  *
            FROM    sys.objects
            WHERE   object_id = OBJECT_ID(N'etl_DimItem')
                    AND type IN ( N'P', N'PC' ) ) 

DROP PROCEDURE  etl_DimItem
GO

--exec etl_DimItem  select count(*) from bluebin.DimItem select * from bluebin.DimItem
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
	   --DESCR                       AS ItemClinicalDescription,--****
	   case when @UseClinicalDescription = 1 then
			case 
				when bn.INV_BRAND_NAME is null or bn.INV_BRAND_NAME = ''  then
						case 
							when DESCR is null or DESCR = '' then '*NEEDS*' 
							else DESCR end 
			else bn.INV_BRAND_NAME end 
		else DESCR end as ItemClinicalDescription,
	   'A'							AS ActiveStatus,--****
       b.MFG_ID                    AS ItemManufacturer,
       b.MFG_ITM_ID                AS ItemManufacturerNumber,
       d.NAME1                     AS ItemVendor,
       c.VENDOR_ID               AS ItemVendorNumber,
	   
	   podt.PO_DT					AS LastPODate,--****
       ''							AS StockLocation,--****
       c.ITM_ID_VNDR				AS VendorItemNumber,--****
	   UNIT_MEASURE_STD			   AS StockUOM,
       UNIT_MEASURE_STD            AS BuyUOM,
       ''							AS PackageString,--****
	   ISNULL(ex.Expireable,'') as Expireable
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
	   left join BRAND_NAMES_INV bn on a.INV_ITEM_ID = bn.INV_ITEM_ID
	   left join (select INV_ITEM_ID,ITEM_FIELD_C2 as Expireable from BU_ITEMS_INV where ITEM_FIELD_C2 = 'Y' group by INV_ITEM_ID,ITEM_FIELD_C2) ex on a.INV_ITEM_ID = ex.INV_ITEM_ID
	   left join (select p.INV_ITEM_ID,max(hd.PO_DT) as PO_DT from PO_LINE p inner join PO_HDR hd on p.PO_ID = hd.PO_ID group by p.INV_ITEM_ID) podt on a.INV_ITEM_ID = podt.INV_ITEM_ID
--select count(*) from bluebin.DimItem 
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
--select count(*),sum(BlueBinFlag) from bluebin.DimLocation

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
	   COALESCE(df.FacilityID,@Facility,0) AS LocationFacility,
	   --case when @Facility = '' or @Facility is null then df.FacilityID else @Facility end AS LocationFacility,
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
INNER JOIN (SELECT LOCATION, MIN(EFFDT) AS EFFDT FROM dbo.LOCATION_TBL where EFF_STATUS = 'A'  GROUP BY LOCATION) b ON a.LOCATION  = b.LOCATION AND a.EFFDT = b.EFFDT 
LEFT JOIN 
	(select BUSINESS_UNIT,LOCATION from CART_ATTRIB_INV group by BUSINESS_UNIT,LOCATION) c on a.LOCATION = c.LOCATION
LEFT JOIN bluebin.DimFacility df on c.BUSINESS_UNIT COLLATE DATABASE_DEFAULT = df.FacilityName
WHERE  a.EFF_STATUS = 'A'  --and a.DESCR like 'BB%'



GO

UPDATE etl.JobSteps
SET LastModifiedDate = GETDATE()
WHERE StepName = 'DimLocation'

GO



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

	DECLARE @StartDateConfig int, @EndDateConfig varchar(20)
	select @StartDateConfig = ConfigValue from bluebin.Config where ConfigName = 'ReportDateStart'
	select @EndDateConfig = ConfigValue from bluebin.Config where ConfigName = 'ReportDateEnd'
	
	SET @StartDate = Dateadd(dd, @StartDateConfig, Dateadd(dd, Datediff(dd, 0, Getdate()), 0)) --Starting value of Date Range
	SET @EndDate = case when @EndDateConfig = 'Current' then Dateadd(dd, Datediff(dd, -1, Getdate()), 0) else Dateadd(dd, Datediff(dd, 0, Getdate()), 0) end--End Value of Date Range
	
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

			DimBinNotManaged

***********************************************************/

IF EXISTS ( SELECT  *
            FROM    sys.objects
            WHERE   object_id = OBJECT_ID(N'etl_DimBinNotManaged')
                    AND type IN ( N'P', N'PC' ) ) 

DROP PROCEDURE  etl_DimBinNotManaged
GO

CREATE PROCEDURE etl_DimBinNotManaged

AS

--exec etl_DimBinNotManaged 
--Select * from bluebin.DimBinNotManaged
/***************************		DROP DimBinNotManaged		********************************/
BEGIN TRY
    DROP TABLE bluebin.DimBinNotManaged
END TRY

BEGIN CATCH
END CATCH


/***********************************		CREATE	DimBinNotManaged		***********************************/



declare @Facility int, @UsePriceList int
   select @Facility = ConfigValue from bluebin.Config where ConfigName = 'PS_DefaultFacility'
   select @UsePriceList = ConfigValue from bluebin.Config where ConfigName = 'PS_UsePriceList'
 ;

With A as (
SELECT 
	   rtrim(ltrim(convert(varchar(10),COALESCE(df.FacilityID,@Facility,0)))) +'-' + rtrim(ltrim(convert(varchar(10),Locations.LOCATION))) + '-' + rtrim(ltrim(convert(varchar(10),Bins.INV_ITEM_ID))) AS FLI,
	   COALESCE(df.FacilityID,@Facility,0) as FacilityID,
       Locations.LOCATION  AS LocationID,
	   Bins.INV_ITEM_ID  AS ItemID,
	   Bins.UNIT_OF_MEASURE AS BinUOM,
	   Cast(Bins.QTY_OPTIMAL AS INT)  AS BinQty,
	   convert(int,(Select max(ConfigValue) from bluebin.Config where ConfigName = 'DefaultLeadTime') )  AS BinLeadTime,
	   CASE
			When @UsePriceList = 1 then
			COALESCE(bu.PRICE_LIST,bu.LAST_PRICE_PAID,bu.LAST_PO_PRICE_PAID,0)
			Else
			COALESCE(bu.LAST_PRICE_PAID,bu.LAST_PO_PRICE_PAID,bu.PRICE_LIST,0) 
			end AS BinCurrentCost,
	   COALESCE(bu.CONSIGNED_FLAG_BU,bu.CONSIGNED_FLAG_M,'N') AS BinConsignmentFlag,
	   Bins.ACCOUNT AS BinGLAccount,
	   getdate() as [BaselineDate]
		   
--INTO bluebin.DimBinNotManaged
FROM   
	(
	select distinct 
	c.BUSINESS_UNIT,
	c.INV_CART_ID, 
	c.INV_ITEM_ID,
	case when LEN(c.COMPARTMENT) < 6 then '' else c.COMPARTMENT end as COMPARTMENT,
	c.QTY_OPTIMAL,
	c.UNIT_OF_MEASURE,
	max(c.ACCOUNT) as ACCOUNT
	
	 from dbo.CART_TEMPL_INV c
	 inner join (select INV_CART_ID, INV_ITEM_ID, max(ISNULL(COUNT_ORDER,1)) as COUNT_ORDER from CART_TEMPL_INV 
	 --where COUNT_ORDER != 2
	 --and LEN(COMPARTMENT) >=6 
	 group by INV_CART_ID, INV_ITEM_ID) a 
		on c.INV_CART_ID = a.INV_CART_ID and c.INV_ITEM_ID = a.INV_ITEM_ID and ISNULL(c.COUNT_ORDER,1) = a.COUNT_ORDER
	 --where c.INV_ITEM_ID = '1446' and c.INV_CART_ID = 'L0153'
	 group by 
	 c.BUSINESS_UNIT,
	 c.INV_CART_ID, 
	c.INV_ITEM_ID,
	case when LEN(c.COMPARTMENT) < 6 then '' else c.COMPARTMENT end,
	c.QTY_OPTIMAL,
	c.UNIT_OF_MEASURE ) Bins
	          
	  LEFT JOIN dbo.CART_ATTRIB_INV Carts
              ON Bins.INV_CART_ID = Carts.INV_CART_ID
        LEFT JOIN dbo.LOCATION_TBL Locations
              ON Carts.LOCATION = Locations.LOCATION
		INNER JOIN bluebin.DimLocation dl
              ON Locations.LOCATION COLLATE DATABASE_DEFAULT = dl.LocationID
		--LEFT JOIN dbo.BU_ITEMS_INV bu on Bins.INV_ITEM_ID = bu.INV_ITEM_ID  and bu.BUSINESS_UNIT in (select ConfigValue from bluebin.Config where ConfigName = 'PS_BUSINESSUNIT')
		LEFT JOIN
		(select
			m.INV_ITEM_ID
			,case when bu.LAST_PRICE_PAID = 0 then NULL else bu.LAST_PRICE_PAID end as LAST_PRICE_PAID
			,case when p.LAST_PO_PRICE_PAID = 0 then NULL else p.LAST_PO_PRICE_PAID end as LAST_PO_PRICE_PAID
			,case when p.PRICE_LIST = 0 then NULL else p.PRICE_LIST end as PRICE_LIST
			,bu.CONSIGNED_FLAG as CONSIGNED_FLAG_BU
			,m.CONSIGNED_FLAG as CONSIGNED_FLAG_M

			from (select INV_ITEM_ID,max(CONSIGNED_FLAG) as CONSIGNED_FLAG from MASTER_ITEM_TBL group by INV_ITEM_ID) m 
			LEFT JOIN PURCH_ITEM_ATTR p on m.INV_ITEM_ID = p.INV_ITEM_ID
			--LEFT JOIN BU_ITEMS_INV bu on m.INV_ITEM_ID = bu.INV_ITEM_ID and bu.BUSINESS_UNIT in (select ConfigValue from bluebin.Config where ConfigName = 'PS_BUSINESSUNIT')
			LEFT JOIN
				(select a.BUSINESS_UNIT,a.CONSIGNED_FLAG,a.INV_ITEM_ID,max(a.LAST_PRICE_PAID) as LAST_PRICE_PAID
					from BU_ITEMS_INV a
					inner join (select BUSINESS_UNIT,INV_ITEM_ID,max(LAST_ORDER_DATE) as LAST_ORDER_DATE from BU_ITEMS_INV group by BUSINESS_UNIT,INV_ITEM_ID) b 
							on a.BUSINESS_UNIT = b.BUSINESS_UNIT and a.INV_ITEM_ID = b.INV_ITEM_ID and a.LAST_ORDER_DATE = b.LAST_ORDER_DATE
					group by a.BUSINESS_UNIT,a.CONSIGNED_FLAG,a.INV_ITEM_ID) bu on m.INV_ITEM_ID = bu.INV_ITEM_ID and bu.BUSINESS_UNIT in (select ConfigValue from bluebin.Config where ConfigName = 'PS_BUSINESSUNIT')

			) bu on Bins.INV_ITEM_ID = bu.INV_ITEM_ID
			LEFT JOIN bluebin.DimFacility df on Bins.BUSINESS_UNIT COLLATE DATABASE_DEFAULT = df.FacilityName
WHERE  
		
		rtrim(ltrim(convert(varchar(10),COALESCE(df.FacilityID,@Facility,0)))) +'-' + rtrim(ltrim(convert(varchar(10),Locations.LOCATION)))  not in (select rtrim(ltrim(LocationFacility)) +'-' + rtrim(ltrim(LocationID))  from bluebin.DimLocation where BlueBinFlag = 1)
		and rtrim(ltrim(convert(varchar(10),COALESCE(df.FacilityID,@Facility,0)))) +'-' + rtrim(ltrim(convert(varchar(10),Locations.LOCATION))) + '-' + rtrim(ltrim(convert(varchar(32),Bins.INV_ITEM_ID))) not in (select rtrim(ltrim(convert(varchar(10),BinFacility))) + '-' + LocationID + '-' + ItemID from bluebin.DimBin)
	   

group by
rtrim(ltrim(convert(varchar(10),COALESCE(df.FacilityID,@Facility,0)))) +'-' + rtrim(ltrim(convert(varchar(10),Locations.LOCATION))) + '-' + rtrim(ltrim(convert(varchar(10),Bins.INV_ITEM_ID))),
	   df.FacilityID,
       Locations.LOCATION,
	   Bins.INV_ITEM_ID,
	   Bins.UNIT_OF_MEASURE,
	   Bins.QTY_OPTIMAL,
	   bu.PRICE_LIST,
	   bu.LAST_PRICE_PAID,
	   bu.LAST_PO_PRICE_PAID,
	   bu.CONSIGNED_FLAG_BU,
	   bu.CONSIGNED_FLAG_M,
	   Bins.ACCOUNT
)
insert INTO bluebin.DimBinNotManaged
select 
FLI,
FacilityID,
LocationID,
ItemID,
Max(BinUOM) as BinUOM,
Max(BinQty) as BinQty,
BinLeadTime,
Max(BinCurrentCost) as BinCurrentCost,
BinConsignmentFlag,
BinGLAccount,
--'2017-11-13 00:00:00' as BaseLineDate
getdate() as BaselineDate
from A
where FLI not in (select FLI from bluebin.DimBinNotManaged)
group by
FLI,
FacilityID,
LocationID,
ItemID,
BinLeadTime,
BinConsignmentFlag,
BinGLAccount

GO

UPDATE etl.JobSteps
SET LastModifiedDate = GETDATE()
WHERE StepName = 'DimBinNotManaged'




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
declare @UsePriceList int
declare @Facility int = (select ConfigValue from bluebin.Config where ConfigName = 'PS_DefaultFacility')
declare @FacilityName varchar(30) = (select PSFacilityName from bluebin.DimFacility where FacilityID = @Facility)
select @UsePriceList = ConfigValue from bluebin.Config where ConfigName = 'PS_UsePriceList'
 


SELECT distinct
		Row_number()
         OVER(
           ORDER BY Locations.LOCATION, Bins.INV_ITEM_ID) AS BinKey,
       --Bins.INV_CART_ID                                 AS CartID,
	   COALESCE(df.FacilityID,@Facility,0) as BinFacility,
	   --case when @Facility is not null or @Facility <> '' then @Facility else ''end	as BinFacility,
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
	   COALESCE((case when Locations.EFFDT < '1910-01-01' then NULL else Locations.EFFDT end),lt2.LOC_DATE,lt.LOC_DATE)									AS BinGoLiveDate,
	   
		--bu.LAST_PRICE_PAID AS BinCurrentCost,
  --     bu.CONSIGNED_FLAG AS BinConsignmentFlag,
		CASE
			When @UsePriceList = 1 then
			COALESCE(bu.PRICE_LIST,bu.LAST_PRICE_PAID,bu.LAST_PO_PRICE_PAID,0)
			Else
			COALESCE(bu.LAST_PRICE_PAID,bu.LAST_PO_PRICE_PAID,bu.PRICE_LIST,0) 
			end AS BinCurrentCost,
       COALESCE(bu.CONSIGNED_FLAG_BU,bu.CONSIGNED_FLAG_M,'N') AS BinConsignmentFlag,
       Bins.ACCOUNT AS BinGLAccount,
	   'Awaiting Updated Status'						 AS BinCurrentStatus

	   
INTO   bluebin.DimBin
FROM   
	(
	select distinct 
	c.BUSINESS_UNIT,
	c.INV_CART_ID, 
	c.INV_ITEM_ID,
	case when LEN(c.COMPARTMENT) < 6 then '' else c.COMPARTMENT end as COMPARTMENT,
	c.QTY_OPTIMAL,
	c.UNIT_OF_MEASURE,
	max(ACCOUNT) as ACCOUNT
	
	 from dbo.CART_TEMPL_INV c
	 inner join (select INV_CART_ID, INV_ITEM_ID, max(ISNULL(COUNT_ORDER,1)) as COUNT_ORDER from CART_TEMPL_INV 
	 --where COUNT_ORDER != 2
	 --and LEN(COMPARTMENT) >=6 
	 group by INV_CART_ID, INV_ITEM_ID) a 
		on c.INV_CART_ID = a.INV_CART_ID and c.INV_ITEM_ID = a.INV_ITEM_ID and ISNULL(c.COUNT_ORDER,1) = a.COUNT_ORDER
	 --where c.INV_ITEM_ID = '1446' and c.INV_CART_ID = 'L0153'
	 group by 
	 c.BUSINESS_UNIT,
	 c.INV_CART_ID, 
	c.INV_ITEM_ID,
	case when LEN(c.COMPARTMENT) < 6 then '' else c.COMPARTMENT end,
	c.QTY_OPTIMAL,
	c.UNIT_OF_MEASURE) Bins
	          
	  LEFT JOIN dbo.CART_ATTRIB_INV Carts
              ON Bins.INV_CART_ID = Carts.INV_CART_ID
        LEFT JOIN dbo.LOCATION_TBL Locations 
              ON Carts.LOCATION = Locations.LOCATION
		LEFT JOIN (Select INV_CART_ID,min(DEMAND_DATE) as LOC_DATE from dbo.CART_CT_INF_INV where CART_COUNT_QTY > 0 AND PROCESS_INSTANCE > 0 group by INV_CART_ID) lt on Bins.INV_CART_ID = lt.INV_CART_ID 
		LEFT JOIN (Select INV_CART_ID,INV_ITEM_ID,min(DEMAND_DATE) as LOC_DATE from dbo.CART_CT_INF_INV group by INV_CART_ID,INV_ITEM_ID) lt2 on Bins.INV_CART_ID = lt2.INV_CART_ID and Bins.INV_ITEM_ID = lt2.INV_ITEM_ID 
				 
		INNER JOIN bluebin.DimLocation dl
              ON Locations.LOCATION COLLATE DATABASE_DEFAULT = dl.LocationID
		--LEFT JOIN dbo.BU_ITEMS_INV bu on Bins.INV_ITEM_ID = bu.INV_ITEM_ID  and bu.BUSINESS_UNIT in (select ConfigValue from bluebin.Config where ConfigName = 'PS_BUSINESSUNIT')
		LEFT JOIN
		(select
			m.INV_ITEM_ID
			,case when bu.LAST_PRICE_PAID = 0 then NULL else bu.LAST_PRICE_PAID end as LAST_PRICE_PAID
			,case when p.LAST_PO_PRICE_PAID = 0 then NULL else p.LAST_PO_PRICE_PAID end as LAST_PO_PRICE_PAID
			,case when p.PRICE_LIST = 0 then NULL else p.PRICE_LIST end as PRICE_LIST
			,bu.CONSIGNED_FLAG as CONSIGNED_FLAG_BU
			,m.CONSIGNED_FLAG as CONSIGNED_FLAG_M

			from (select INV_ITEM_ID,max(CONSIGNED_FLAG) as CONSIGNED_FLAG from MASTER_ITEM_TBL group by INV_ITEM_ID) m 
			LEFT JOIN PURCH_ITEM_ATTR p on m.INV_ITEM_ID = p.INV_ITEM_ID
			--LEFT JOIN BU_ITEMS_INV bu on m.INV_ITEM_ID = bu.INV_ITEM_ID and bu.BUSINESS_UNIT in (select ConfigValue from bluebin.Config where ConfigName = 'PS_BUSINESSUNIT')
			LEFT JOIN
				(select a.BUSINESS_UNIT,a.CONSIGNED_FLAG,a.INV_ITEM_ID,max(a.LAST_PRICE_PAID) as LAST_PRICE_PAID
					from BU_ITEMS_INV a
					inner join (select BUSINESS_UNIT,INV_ITEM_ID,max(LAST_ORDER_DATE) as LAST_ORDER_DATE from BU_ITEMS_INV group by BUSINESS_UNIT,INV_ITEM_ID) b 
							on a.BUSINESS_UNIT = b.BUSINESS_UNIT and a.INV_ITEM_ID = b.INV_ITEM_ID and a.LAST_ORDER_DATE = b.LAST_ORDER_DATE
					group by a.BUSINESS_UNIT,a.CONSIGNED_FLAG,a.INV_ITEM_ID) bu on m.INV_ITEM_ID = bu.INV_ITEM_ID and bu.BUSINESS_UNIT in (select ConfigValue from bluebin.Config where ConfigName = 'PS_BUSINESSUNIT')

			) bu on Bins.INV_ITEM_ID = bu.INV_ITEM_ID
			LEFT JOIN bluebin.DimFacility df on Bins.BUSINESS_UNIT COLLATE DATABASE_DEFAULT = df.FacilityName
WHERE  
		
		dl.BlueBinFlag = 1 and
		LEN(COMPARTMENT) >=6 and 
		(LEFT(Locations.LOCATION, 2) COLLATE DATABASE_DEFAULT IN (SELECT [ConfigValue] FROM   [bluebin].[Config] WHERE  [ConfigName] = 'REQ_LOCATION' AND Active = 1) 
		or Locations.LOCATION COLLATE DATABASE_DEFAULT in (Select REQ_LOCATION from bluebin.ALT_REQ_LOCATION))

		--and Bins.INV_ITEM_ID = '1446' and Bins.INV_CART_ID = 'L0153'
group by
df.FacilityID,
Bins.INV_ITEM_ID,
Locations.LOCATION,
Bins.COMPARTMENT,
Bins.UNIT_OF_MEASURE,
Bins.QTY_OPTIMAL,
Locations.EFFDT,
lt2.LOC_DATE,
lt.LOC_DATE,
bu.LAST_PRICE_PAID,
bu.LAST_PO_PRICE_PAID,
bu.PRICE_LIST,
bu.CONSIGNED_FLAG_BU,
bu.CONSIGNED_FLAG_M,
Bins.ACCOUNT
		
order by 2,Locations.LOCATION,Bins.INV_ITEM_ID 

--select count(*) from bluebin.DimBin order by LocationID,ItemID
/*****************************************		DROP Temp Tables	**************************************/


GO

UPDATE etl.JobSteps
SET LastModifiedDate = GETDATE()
WHERE StepName = 'DimBin'

GO





/***********************************************************

			HistoricalDimBin

***********************************************************/

IF EXISTS ( SELECT  *
            FROM    sys.objects
            WHERE   object_id = OBJECT_ID(N'etl_HistoricalDimBin')
                    AND type IN ( N'P', N'PC' ) ) 

DROP PROCEDURE  etl_HistoricalDimBin
GO

CREATE PROCEDURE etl_HistoricalDimBin

AS

/*  select FLI,count(*) from bluebin.HistoricalDimBin group by FLI order by 2 desc
exec etl_HistoricalDimBin 
select * from bluebin.HistoricalDimBin where FLI = '1-LHMB090103-000000000000077070'
truncate table bluebin.HistoricalDimBin
select * from bluebin.HistoricalDimBin where BaselineDate = '2017-12-27 10:25:23.447'
select * from bluebin.HistoricalDimBin where BaselineDate = '2017-11-13'

Tables Used: CART_TEMPL_INV, CART_ATTRIB_INV, LOCATION_TBL, MASTER_ITEM_TBL, PURCH_ITEM_ATTR, BU_ITEMS_INV
*/
/***************************		DROP HistoricalDimBin		********************************/
BEGIN TRY
    truncate TABLE bluebin.HistoricalDimBin 
END TRY

BEGIN CATCH
END CATCH

/***********************************		CREATE	HistoricalDimBin		***********************************/
declare @Facility int, @UsePriceList int
   select @Facility = ConfigValue from bluebin.Config where ConfigName = 'PS_DefaultFacility'
   select @UsePriceList = ConfigValue from bluebin.Config where ConfigName = 'PS_UsePriceList'
   
--INSERT INTO bluebin.HistoricalDimBin
;

WITH A as (
SELECT 
	   rtrim(ltrim(convert(varchar(10),COALESCE(df.FacilityID,@Facility,0)))) +'-' + rtrim(ltrim(convert(varchar(10),Locations.LOCATION))) + '-' + rtrim(ltrim(convert(varchar(25),Bins.INV_ITEM_ID))) AS FLI,
	   COALESCE(df.FacilityID,@Facility,0) as FacilityID,
       Locations.LOCATION  AS LocationID,
	   Bins.INV_ITEM_ID  AS ItemID,
	   Bins.UNIT_OF_MEASURE AS BinUOM,
	   Cast(Bins.QTY_OPTIMAL AS INT)  AS BinQty,
	   convert(int,(Select max(ConfigValue) from bluebin.Config where ConfigName = 'DefaultLeadTime') )  AS BinLeadTime,
	   CASE
			When @UsePriceList = 1 then
			COALESCE(bu.PRICE_LIST,bu.LAST_PRICE_PAID,bu.LAST_PO_PRICE_PAID,0)
			Else
			COALESCE(bu.LAST_PRICE_PAID,bu.LAST_PO_PRICE_PAID,bu.PRICE_LIST,0) 
			end AS BinCurrentCost,
	   COALESCE(bu.CONSIGNED_FLAG_BU,bu.CONSIGNED_FLAG_M,'N') AS BinConsignmentFlag,
	   Bins.ACCOUNT AS BinGLAccount,
	   '2017-11-13 00:00:00' as [BaselineDate]
	   --getdate() as [BaselineDate]

FROM   
	(
	select distinct 
	c.BUSINESS_UNIT,
	c.INV_CART_ID, 
	c.INV_ITEM_ID,
	case when LEN(c.COMPARTMENT) < 6 then '' else c.COMPARTMENT end as COMPARTMENT,
	c.QTY_OPTIMAL,
	c.UNIT_OF_MEASURE,
	max(c.ACCOUNT) as ACCOUNT
	
	 from dbo.CART_TEMPL_INV c
	 inner join (select INV_CART_ID, INV_ITEM_ID, max(ISNULL(COUNT_ORDER,1)) as COUNT_ORDER from CART_TEMPL_INV 
	 --where COUNT_ORDER != 2
	 --and LEN(COMPARTMENT) >=6 
	 group by INV_CART_ID, INV_ITEM_ID) a 
		on c.INV_CART_ID = a.INV_CART_ID and c.INV_ITEM_ID = a.INV_ITEM_ID and ISNULL(c.COUNT_ORDER,1) = a.COUNT_ORDER
	 group by 
	 c.BUSINESS_UNIT,
	 c.INV_CART_ID, 
	c.INV_ITEM_ID,
	case when LEN(c.COMPARTMENT) < 6 then '' else c.COMPARTMENT end,
	c.QTY_OPTIMAL,
	c.UNIT_OF_MEASURE ) Bins
	          
	  LEFT JOIN dbo.CART_ATTRIB_INV Carts
              ON Bins.INV_CART_ID = Carts.INV_CART_ID
        LEFT JOIN dbo.LOCATION_TBL Locations
              ON Carts.LOCATION = Locations.LOCATION
		LEFT JOIN
		(select
			m.INV_ITEM_ID
			,case when bu.LAST_PRICE_PAID = 0 then NULL else bu.LAST_PRICE_PAID end as LAST_PRICE_PAID
			,case when p.LAST_PO_PRICE_PAID = 0 then NULL else p.LAST_PO_PRICE_PAID end as LAST_PO_PRICE_PAID
			,case when p.PRICE_LIST = 0 then NULL else p.PRICE_LIST end as PRICE_LIST
			,bu.CONSIGNED_FLAG as CONSIGNED_FLAG_BU
			,m.CONSIGNED_FLAG as CONSIGNED_FLAG_M

			from (select INV_ITEM_ID,max(CONSIGNED_FLAG) as CONSIGNED_FLAG from MASTER_ITEM_TBL group by INV_ITEM_ID) m 
			LEFT JOIN PURCH_ITEM_ATTR p on m.INV_ITEM_ID = p.INV_ITEM_ID
			LEFT JOIN
				(select a.BUSINESS_UNIT,a.CONSIGNED_FLAG,a.INV_ITEM_ID,max(a.LAST_PRICE_PAID) as LAST_PRICE_PAID
					from BU_ITEMS_INV a
					inner join (select BUSINESS_UNIT,INV_ITEM_ID,max(LAST_ORDER_DATE) as LAST_ORDER_DATE from BU_ITEMS_INV group by BUSINESS_UNIT,INV_ITEM_ID) b 
							on a.BUSINESS_UNIT = b.BUSINESS_UNIT and a.INV_ITEM_ID = b.INV_ITEM_ID and a.LAST_ORDER_DATE = b.LAST_ORDER_DATE
					group by a.BUSINESS_UNIT,a.CONSIGNED_FLAG,a.INV_ITEM_ID) bu on m.INV_ITEM_ID = bu.INV_ITEM_ID and bu.BUSINESS_UNIT in (select ConfigValue from bluebin.Config where ConfigName = 'PS_BUSINESSUNIT')

			) bu on Bins.INV_ITEM_ID = bu.INV_ITEM_ID
			LEFT JOIN bluebin.DimFacility df on Bins.BUSINESS_UNIT COLLATE DATABASE_DEFAULT = df.FacilityName
WHERE  

		--LEN(COMPARTMENT) >=6 and 
		--df.FacilityID= '4' and Locations.LOCATION = 'LHMB090337'  and Bins.INV_ITEM_ID = '000000000000077070' and 
		rtrim(ltrim(convert(varchar(10),COALESCE(df.FacilityID,@Facility,0)))) +'-' + rtrim(ltrim(convert(varchar(10),Locations.LOCATION)))  not in (select rtrim(ltrim(LocationFacility)) +'-' + rtrim(ltrim(LocationID))  from bluebin.DimLocation where BlueBinFlag = 1)
		and rtrim(ltrim(convert(varchar(10),COALESCE(df.FacilityID,@Facility,0)))) +'-' + rtrim(ltrim(convert(varchar(10),Locations.LOCATION))) + '-' + rtrim(ltrim(convert(varchar(10),Bins.INV_ITEM_ID))) not in (select FLI from bluebin.HistoricalDimBin)		
		

group by
 rtrim(ltrim(convert(varchar(10),COALESCE(df.FacilityID,@Facility,0)))) +'-' + rtrim(ltrim(convert(varchar(10),Locations.LOCATION))) + '-' + rtrim(ltrim(convert(varchar(25),Bins.INV_ITEM_ID))),
	   df.FacilityID,
       Locations.LOCATION,
	   Bins.INV_ITEM_ID,
	   Bins.UNIT_OF_MEASURE,
	   Bins.QTY_OPTIMAL,
	   bu.PRICE_LIST,
	   bu.LAST_PRICE_PAID,
	   bu.LAST_PO_PRICE_PAID,
	   bu.CONSIGNED_FLAG_BU,
	   bu.CONSIGNED_FLAG_M,
	   Bins.ACCOUNT


--order by Locations.LOCATION,Bins.INV_ITEM_ID 
)

INSERT INTO bluebin.HistoricalDimBin 
select 
FLI,
FacilityID,
LocationID,
ItemID,
Max(BinUOM) as BinUOM,
Max(BinQty) as BinQty,
BinLeadTime,
Max(BinCurrentCost) as BinCurrentCost,
BinConsignmentFlag,
BinGLAccount,
--'2017-11-13 00:00:00' as BaseLineDate
getdate() as BaselineDate
from A
where FLI not in (select FLI from bluebin.HistoricalDimBin)
group by
FLI,
FacilityID,
LocationID,
ItemID,
BinLeadTime,
BinConsignmentFlag,
BinGLAccount


GO

UPDATE etl.JobSteps
SET LastModifiedDate = GETDATE()
WHERE StepName = 'HistoricalDimBin'







/*************************************************

			FactScan

*************************************************/
--Edited GB 20180430.  Updated the IN_DEMAND portion for to COALESCE DEMAND_DATE and SCHED_DTTM.  This pulls alternate orderdate
--Edited GB 20180423.  Updated the IN_DEMAND portion for tmpLines to look into IN_FULFILL_STATE for max to eliminate cancellations (state = 90)
--Edited GB 20180307.  Updated PO_ID to account for leading zeroes with NYCH
--Edited 20180209 GB


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
declare @POTimeAdjust int = (Select max(ConfigValue) from bluebin.Config where ConfigName = 'PS_POTimeAdjust')
;
WITH FirstScans
     AS (
/* Original Query	 
	 SELECT INV_CART_ID      AS LocationID,
                INV_ITEM_ID      AS ItemID,
                Min(DEMAND_DATE) AS FirstScanDate
         FROM   dbo.CART_CT_INF_INV
         WHERE  CART_COUNT_QTY > 0
                AND PROCESS_INSTANCE > 0
         GROUP  BY INV_CART_ID,
                   INV_ITEM_ID
				   */
		select
		LocationID,
		ItemID,
		COALESCE(DEMAND_DATE,SCHED_DTTM,LOC_DATE,BIN_DATE,NULL) as FirstScanDate
		from 
				(
				SELECT db.LocationID,
					   db.ItemID,
					   lt.LOC_DATE,
						Min(ct.DEMAND_DATE) AS DEMAND_DATE,
						min(id.SCHED_DTTM) as SCHED_DTTM,
						min(db.BinGoLiveDate) as BIN_DATE
				 FROM   bluebin.DimBin db
				 LEFT JOIN dbo.CART_CT_INF_INV ct on db.LocationID = ct.INV_CART_ID and db.ItemID = ct.INV_ITEM_ID and ct.CART_COUNT_QTY > 0 AND ct.PROCESS_INSTANCE > 0
				 LEFT JOIN IN_DEMAND id on db.LocationID = id.LOCATION and db.ItemID = id.INV_ITEM_ID
				 LEFT JOIN (Select INV_CART_ID,min(DEMAND_DATE) as LOC_DATE from dbo.CART_CT_INF_INV where CART_COUNT_QTY > 0 AND PROCESS_INSTANCE > 0 group by INV_CART_ID) lt on db.LocationID = lt.INV_CART_ID 
				 GROUP  BY 
				 db.LocationID,
				 db.ItemID,
				 lt.LOC_DATE
				  ) a 
				   
				   )
				   
				   ,

--**************************
Orders
     AS (
	 SELECT Row_number()
                  OVER(
                    PARTITION BY Bins.ItemID, PO_LN_DST.LOCATION, PO_HDR.PO_DT
                    ORDER BY PO_LN.PO_ID, PO_LN.LINE_NBR) AS DailySeq,
                Bins.BinKey,
				--Bins.BinGoLiveDate,
                Bins.ItemID									AS ItemID, --Original PO_LN.INV_ITEM_ID
                PO_LN_DST.LOCATION                        AS LocationID,
                PO_LN.PO_ID                               AS OrderNum,
                PO_LN.LINE_NBR                            AS LineNum,
                SHIP.RECEIPT_DTTM                         AS CloseDate,
                QTY_PO                                    AS OrderQty,
                PO_LN.UNIT_OF_MEASURE                     AS OrderUOM,
                DATEADD(hour,@POTimeAdjust,PO_HDR.PO_DT) as PO_DT
				--PO_HDR.PO_DT
         FROM   dbo.PO_LINE_DISTRIB PO_LN_DST
                INNER JOIN dbo.PO_LINE PO_LN
                        ON PO_LN_DST.PO_ID = PO_LN.PO_ID
                           AND PO_LN_DST.LINE_NBR = PO_LN.LINE_NBR
                INNER JOIN dbo.PO_HDR
                        ON PO_LN.PO_ID = PO_HDR.PO_ID
							AND PO_LN.BUSINESS_UNIT = PO_HDR.BUSINESS_UNIT
                INNER JOIN bluebin.DimBin Bins
                        ON RIGHT(('000000000000000000' + PO_LN.INV_ITEM_ID),18) = RIGHT(('000000000000000000' + Bins.ItemID),18) 
                           AND Bins.LocationID = PO_LN_DST.LOCATION
                LEFT JOIN
					(select PO_ID,LINE_NBR,max(RECEIPT_DTTM) as RECEIPT_DTTM from dbo.RECV_LN_SHIP group by PO_ID,LINE_NBR) SHIP
						ON PO_LN.PO_ID = SHIP.PO_ID
                          AND PO_LN.LINE_NBR = SHIP.LINE_NBR
				--LEFT JOIN dbo.RECV_LN_SHIP SHIP
    --                   ON PO_LN.PO_ID = SHIP.PO_IDselect * from RECV_LN_SHIP 
    --                      AND PO_LN.LINE_NBR = SHIP.LINE_NBR
                LEFT JOIN FirstScans
                       ON RIGHT(('000000000000000000' + PO_LN.INV_ITEM_ID),18) = RIGHT(('000000000000000000' + FirstScans.ItemID),18)
                          AND PO_LN_DST.LOCATION = FirstScans.LocationID
         WHERE  (LEFT(PO_LN_DST.LOCATION, 2) COLLATE DATABASE_DEFAULT IN (SELECT [ConfigValue] FROM   [bluebin].[Config] WHERE  [ConfigName] = 'REQ_LOCATION' AND Active = 1) 
				or PO_LN_DST.LOCATION COLLATE DATABASE_DEFAULT in (Select REQ_LOCATION from bluebin.ALT_REQ_LOCATION))
                AND ISNULL(PO_LN.CANCEL_STATUS,'') NOT IN ( 'X', 'D', 'PX' )
				--AND PO_LN_DST.LOCATION = '16401PED02' and PO_LN.INV_ITEM_ID = '100177' and PO_LN.PO_ID = '0000008230' 
				--and DATEADD(hour,@POTimeAdjust,PO_HDR.PO_DT) > getdate() -5
                --AND PO_LN_DST.BUSINESS_UNIT_GL = 209
		GROUP BY 
				Bins.BinKey,
				PO_LN_DST.LOCATION,
				Bins.ItemID, --Original PO_LN.INV_ITEM_ID
                PO_LN.PO_ID,
                PO_LN.LINE_NBR,
                SHIP.RECEIPT_DTTM,
				QTY_PO,
                PO_LN.UNIT_OF_MEASURE,
                PO_HDR.PO_DT
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
				--CART_COUNT_QTY
         FROM   dbo.CART_CT_INF_INV
         WHERE  --CART_COUNT_QTY <> 0 AND
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
       COALESCE(b.SCAN_DATE,a.PO_DT)                 AS OrderDate,
       a.CloseDate,
       a.OrderQty,
       a.OrderUOM,
	   'PO' as OrderType,
		'No' as Cancelled
FROM   Orders a
       LEFT JOIN CartCounts b
               ON a.LocationID = b.LocationID
                  AND a.ItemID = b.ItemID
                  AND a.PO_DT = b.PO_DT
                  AND a.DailySeq = b.DailySeq 

UNION ALL

SELECT Bins.BinKey,
--Bins.BinGoLiveDate,
       Picks.INV_ITEM_ID as ItemID,
       Picks.LOCATION as LocationID,
       Picks.ORDER_NO as OrderNum,
       Picks.ORDER_INT_LINE_NO as LineNum,
       COALESCE(Picks.SCHED_DTTM,Picks.DEMAND_DATE) as OrderDate,
       max(Picks.PICK_CONFIRM_DTTM) as CloseDate,
       Cast(Picks.QTY_REQUESTED AS INT) AS OrderQty,
	   UNIT_OF_MEASURE as OrderUOM,
	   CASE
         WHEN Picks.ORDER_NO LIKE 'MSR%' THEN 'MSR'
         ELSE 'Pick' end as OrderType,
		case when (Picks.IN_FULFILL_STATE = '70' and Picks.QTY_PICKED = '0') or can.IN_FULFILL_STATE = '90' then 'Yes' else 'No' end as Cancelled

FROM   dbo.IN_DEMAND Picks
       INNER JOIN bluebin.DimBin Bins
               ON Picks.LOCATION = Bins.LocationID AND Picks.INV_ITEM_ID = Bins.ItemID
		left join (select LOCATION,INV_ITEM_ID,ORDER_NO,ORDER_INT_LINE_NO,max(PICK_CONFIRM_DTTM) as PICK_CONFIRM_DTTM,max(IN_FULFILL_STATE) as IN_FULFILL_STATE from IN_DEMAND GROUP BY LOCATION,INV_ITEM_ID,ORDER_NO,ORDER_INT_LINE_NO) can
				ON Picks.LOCATION = can.LOCATION AND Picks.INV_ITEM_ID = can.INV_ITEM_ID AND Picks.ORDER_NO = can.ORDER_NO and Picks.ORDER_INT_LINE_NO = can.ORDER_INT_LINE_NO
		LEFT JOIN FirstScans
		ON Picks.INV_ITEM_ID = FirstScans.ItemID AND Picks.LOCATION = FirstScans.LocationID
WHERE  (LEFT(Picks.LOCATION, 2) COLLATE DATABASE_DEFAULT IN (SELECT [ConfigValue] FROM   [bluebin].[Config] WHERE  [ConfigName] = 'REQ_LOCATION' AND Active = 1) 
		or Picks.LOCATION COLLATE DATABASE_DEFAULT in (Select REQ_LOCATION from bluebin.ALT_REQ_LOCATION))
       AND (CANCEL_DTTM IS NULL  or CANCEL_DTTM < '1900-01-02')
	   AND DEMAND_DATE >= FirstScanDate --ISNULL(FirstScanDate,Bins.BinGoLiveDate)
	  --and Picks.ORDER_NO like '%420290%' 
	  --and IN_FULFILL_STATE <> '20'
Group By
	   Bins.BinKey,
       Picks.INV_ITEM_ID,
       Picks.LOCATION,
       Picks.ORDER_NO,
       Picks.ORDER_INT_LINE_NO,
       COALESCE(Picks.SCHED_DTTM,Picks.DEMAND_DATE),
       Cast(Picks.QTY_REQUESTED AS INT),
	   UNIT_OF_MEASURE,
	   CASE
         WHEN Picks.ORDER_NO LIKE 'MSR%' THEN 'MSR'
         ELSE 'Pick' end,
		case when (Picks.IN_FULFILL_STATE = '70' and Picks.QTY_PICKED = '0') or can.IN_FULFILL_STATE = '90' then 'Yes' else 'No' end
	   )
	   ,
--**************************	   
tmpOrders 
	AS (
	SELECT Row_number()
         OVER(
           Partition BY BinKey
           ORDER BY OrderDate) AS OrderSeq,
		   *
       --*,
       --CASE
       --  WHEN OrderNum LIKE 'MSR%' THEN 'MSR'
       --  ELSE 'PO'
       --END                     AS OrderType

FROM   tmpLines
where Cancelled = 'No'
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
	   case when a.OrderType = 'MSR' or a.OrderType = 'Pick' then 'I'
			else 'N' end as ItemType,
	   a.OrderUOM,
       Cast(a.OrderQty AS INT) AS OrderQty,
       a.OrderDate,
       case when a.CloseDate < '1900-01-01' then NULL else a.CloseDate end as OrderCloseDate,
       b.OrderDate             AS PrevOrderDate,
       case when b.CloseDate < '1900-01-01' then NULL else b.CloseDate end AS PrevOrderCloseDate,
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
	   
WHERE  a.OrderDate >= db.BinGoLiveDate and a.OrderUOM <> '0' and a.OrderQty <> '0'--and a.OrderDate > getdate() -360--and d.ItemKey = '18710' and 
--and a.OrderNum = '0000000553'
Order by BinKey,ScanHistseq asc

--select * from bluebin.FactScan where OrderNum = '0000000553'

GO

UPDATE etl.JobSteps
SET LastModifiedDate = GETDATE()
WHERE StepName = 'FactScan'

GO

/*************************************************

			FactBinSnapshot

*************************************************/

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
 

declare @Facility int = (select ConfigValue from bluebin.Config where ConfigName = 'PS_DefaultFacility')
declare @FacilityName varchar(30) = (select PSFacilityName from bluebin.DimFacility where FacilityID = @Facility)

  
  SELECT 

	   COALESCE(df2.FacilityID,@Facility) as FacilityKey,
		--case when @Facility is not null or @Facility <> '' then @Facility else '' end as FacilityKey,
	   Picks.BUSINESS_UNIT AS LocationID,
       b.LocationKey AS LocationKey,

       c.LocationKey AS ShipLocationKey,
       COALESCE(df.FacilityID,@Facility) as ShipFacilityKey,
	   --case when @Facility is not null or @Facility <> '' then @Facility else '' end as ShipFacilityKey,
       ISNULL(c.BlueBinFlag,0) as BlueBinFlag,
	   d.ItemKey AS ItemKey,
       '' AS  SourceSystem,
       Picks.ORDER_NO AS ReqNumber,
       Picks.ORDER_INT_LINE_NO AS ReqLineNumber,
       Picks.DEMAND_DATE AS IssueDate,
       Picks.UNIT_OF_MEASURE AS UOM,
       '' AS UOMMult,
       Picks.QTY_PICKED AS  IssueQty,
       case when PICK_BATCH_ID = 0 then 1 else 0 end AS StatCall,
       1  AS IssueCount
INTO bluebin.FactIssue
FROM   dbo.IN_DEMAND Picks
	   LEFT JOIN bluebin.DimLocation b ON Picks.BUSINESS_UNIT = b.LocationID AND @Facility = b.LocationFacility
       LEFT JOIN bluebin.DimLocation c ON Picks.LOCATION = c.LocationID 
       LEFT JOIN bluebin.DimItem d ON Picks.INV_ITEM_ID = d.ItemID
	   left join bluebin.DimFacility df on Picks.SOURCE_BUS_UNIT = df.FacilityName
	   left join bluebin.DimFacility df2 on Picks.BUSINESS_UNIT = df2.FacilityName
		
		
			   
WHERE  
CANCEL_DTTM IS NULL or CANCEL_DTTM < '1900-01-02'
order by 9,10
	
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
--Updated GB 20180219 Added Expireable

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
Declare @UseClinicalDescTab int
/*This setting will use the Brand Name (Peoplsoft) or the set name in ITEM LOC User Fields (Lawson) 
instead of the standard that is populated through ItemClinicalDescription all write it over ItemDescription in ALL Tableau reports*/
select @UseClinicalDescTab = ConfigValue from bluebin.Config where ConfigName = 'UseClinicalDescTab'



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
       case
		when @UseClinicalDescTab = 1 then DimItem.ItemClinicalDescription else DimItem.ItemDescription end as ItemDescription,
	   DimItem.ItemClinicalDescription,
       DimItem.ItemManufacturer,
       DimItem.ItemManufacturerNumber,
       DimItem.ItemVendor,
       DimItem.ItemVendorNumber,
       DimLocation.LocationName,
       1 AS TotalBins,
	   DimItem.Expireable
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

declare @UsePriceList int
declare @Facility int = (select ConfigValue from bluebin.Config where ConfigName = 'PS_DefaultFacility')
declare @FacilityName varchar(30) = (select PSFacilityName from bluebin.DimFacility where FacilityID = @Facility)
   select @UsePriceList = ConfigValue from bluebin.Config where ConfigName = 'PS_UsePriceList'
   

SELECT distinct
		--d.LocationID,
		--case when @Facility is not null or @Facility <> '' then @Facility else ''end as FacilityID,
		--case when @Facility is not null or @Facility <> '' then (select FacilityName from bluebin.DimFacility where FacilityID = @Facility) else ''end as FacilityName,
		COALESCE(df.FacilityID,@Facility) AS COMPANY,
		COALESCE(df.FacilityName,@FacilityName) AS FacilityName,
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
	   --a.[LAST_PRICE_PAID] as UnitCost,
	   CASE
			When @UsePriceList = 1 then
			COALESCE(a2.PRICE_LIST,a2.LAST_PRICE_PAID,a2.LAST_PO_PRICE_PAID,0)
			Else
			COALESCE(a2.LAST_PRICE_PAID,a2.LAST_PO_PRICE_PAID,a2.PRICE_LIST,0) 
			end AS UnitCost,
	   --CASE 		--Use if PriceList should be part of the Warehouse report as well  Uncomment left join to PURCHITEM_ATTR if activating
		--WHEN @UsePriceList = 1 then p.PRICE_LIST
		--else a.[LAST_PRICE_PAID]	
		--End AS UnitCost,
       b.StockUOM,
       b.BuyUOM,
       b.PackageString
INTO   bluebin.DimWarehouseItem
FROM   [dbo].[BU_ITEMS_INV] a
       INNER JOIN bluebin.DimItem b
               ON a.[INV_ITEM_ID] = b.ItemID
		LEFT JOIN		
		(select
			m.INV_ITEM_ID
			,case when bu.LAST_PRICE_PAID = 0 then NULL else bu.LAST_PRICE_PAID end as LAST_PRICE_PAID
			,case when p.LAST_PO_PRICE_PAID = 0 then NULL else p.LAST_PO_PRICE_PAID end as LAST_PO_PRICE_PAID
			,case when p.PRICE_LIST = 0 then NULL else p.PRICE_LIST end as PRICE_LIST
			,bu.CONSIGNED_FLAG as CONSIGNED_FLAG_BU
			,m.CONSIGNED_FLAG as CONSIGNED_FLAG_M

			from (select INV_ITEM_ID,max(CONSIGNED_FLAG) as CONSIGNED_FLAG from MASTER_ITEM_TBL group by INV_ITEM_ID) m 
			LEFT JOIN PURCH_ITEM_ATTR p on m.INV_ITEM_ID = p.INV_ITEM_ID
			--LEFT JOIN BU_ITEMS_INV bu on m.INV_ITEM_ID = bu.INV_ITEM_ID and bu.BUSINESS_UNIT in (select ConfigValue from bluebin.Config where ConfigName = 'PS_BUSINESSUNIT')
			LEFT JOIN
				(select a.BUSINESS_UNIT,a.CONSIGNED_FLAG,a.INV_ITEM_ID,max(a.LAST_PRICE_PAID) as LAST_PRICE_PAID
					from BU_ITEMS_INV a
					inner join (select BUSINESS_UNIT,INV_ITEM_ID,max(LAST_ORDER_DATE) as LAST_ORDER_DATE from BU_ITEMS_INV group by BUSINESS_UNIT,INV_ITEM_ID) b 
							on a.BUSINESS_UNIT = b.BUSINESS_UNIT and a.INV_ITEM_ID = b.INV_ITEM_ID and a.LAST_ORDER_DATE = b.LAST_ORDER_DATE
					group by a.BUSINESS_UNIT,a.CONSIGNED_FLAG,a.INV_ITEM_ID) bu on m.INV_ITEM_ID = bu.INV_ITEM_ID and bu.BUSINESS_UNIT in (select ConfigValue from bluebin.Config where ConfigName = 'PS_BUSINESSUNIT')

			) a2 on a.INV_ITEM_ID = a2.INV_ITEM_ID
		left join bluebin.DimFacility df on a.BUSINESS_UNIT = df.FacilityName
--WHERE a.BUSINESS_UNIT in (Select ConfigValue from bluebin.Config where ConfigName = 'LOCATION')
WHERE a.BUSINESS_UNIT in (Select ConfigValue from bluebin.Config where ConfigName = 'PS_BUSINESSUNIT')
--and b.ItemID like '%10553%'

group by
		df.FacilityID,
		df.FacilityName,
		a.BUSINESS_UNIT,
		a.BUSINESS_UNIT,
		b.ItemKey,
       b.ItemID,
       b.ItemDescription,
       b.ItemClinicalDescription,
       b.ItemManufacturer,
       b.ItemManufacturerNumber,
       b.ItemVendor,
       b.ItemVendorNumber,
       a.[QTY_ONHAND],
       a.[QTY_MAXIMUM],
       a.[REORDER_POINT],
		a2.LAST_PRICE_PAID,
		a2.LAST_PO_PRICE_PAID,
		a2.PRICE_LIST,
       b.StockUOM,
       b.BuyUOM,
       b.PackageString
	   order by 6,2,3

--select count(*) from bluebin.DimWarehouseItem
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
	[FacilityName] varchar (50) NOT NULL,
	[PSFacilityName] varchar (30) NULL
)
;
declare @DefaultFacility int = (select ConfigValue from bluebin.Config where ConfigName = 'PS_DefaultFacility')

if exists (select ConfigValue from bluebin.Config where ConfigName = 'PS_DefaultFacility' and ConfigValue > 0)
BEGIN
INSERT INTO bluebin.DimFacility 
--declare @DefaultFacility int = (select ConfigValue from bluebin.Config where ConfigName = 'PS_DefaultFacility')

select 
@DefaultFacility,
a.BUSINESS_UNIT,
bu.DESCR
from
	(select distinct BUSINESS_UNIT from CART_CT_INF_INV) a
	left join dbo.BUS_UNIT_TBL_FS bu on a.BUSINESS_UNIT = bu.BUSINESS_UNIT
	where @DefaultFacility not in (select FacilityID from bluebin.DimFacility)

END 
ELSE
BEGIN
INSERT INTO bluebin.DimFacility 
select 
ROW_NUMBER() OVER (ORDER BY a.BUSINESS_UNIT),
a.BUSINESS_UNIT,
bu.DESCR
from
	(select distinct BUSINESS_UNIT from CART_CT_INF_INV) a
	left join dbo.BUS_UNIT_TBL_FS bu on a.BUSINESS_UNIT = bu.BUSINESS_UNIT
	where @DefaultFacility not in (select FacilityID from bluebin.DimFacility)
	and a.BUSINESS_UNIT not in (select FacilityName from bluebin.DimFacility)
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
--SET NOCOUNT ON
declare @Facility int = (select ConfigValue from bluebin.Config where ConfigName = 'PS_DefaultFacility')
declare @FacilityName varchar(30) = (select PSFacilityName from bluebin.DimFacility where FacilityID = @Facility)


SELECT 
jh.FISCAL_YEAR as FiscalYear,
jh.ACCOUNTING_PERIOD AS AcctPeriod,
COALESCE(df.FacilityID,@Facility) as COMPANY,
COALESCE(df.FacilityName,@FacilityName) as FacilityName,
ISNULL(jl.ACCOUNT,'N/A') as Account,                                                                                                              
ISNULL((jl.ACCOUNT + '-' + gl.DESCR),'N/A') AS AccountDesc,     
ISNULL(d.DEPTID,'N/A') AS  AcctUnit,
ISNULL(d.DESCR,'N/A') AS  AcctUnitName, 
jh.POSTED_DATE AS [Date],
Sum(jl.MONETARY_AMOUNT) AS  Amount 

FROM   JRNL_HEADER jh
	INNER JOIN JRNL_LN jl on jl.JOURNAL_ID = jh.JOURNAL_ID
	LEFT JOIN (select g.ACCOUNT,g.ACCOUNT_TYPE,g.DESCR from GL_ACCOUNT_TBL g
					inner join (select ACCOUNT,max(EFFDT) as EFFDT from GL_ACCOUNT_TBL where EFF_STATUS = 'A' group by ACCOUNT) a on g.ACCOUNT = a.ACCOUNT and g.EFFDT = a.EFFDT
					)  gl ON jl.ACCOUNT = gl.ACCOUNT  
	LEFT JOIN (select d.DEPTID,d.DESCR from DEPT_TBL d
					inner join (select DEPTID,max(EFFDT) as EFFDT from DEPT_TBL where EFF_STATUS = 'A' group by DEPTID) a on d.DEPTID = a.DEPTID and d.EFFDT = a.EFFDT
					) d on jl.DEPTID = d.DEPTID
	LEFT JOIN bluebin.DimFacility df on jh.BUSINESS_UNIT = df.FacilityName

WHERE  

(jl.ACCOUNT in (select ConfigValue from bluebin.Config where ConfigName = 'GLSummaryAccountID')
--or gl.DESCR like '%supply%' or gl.DESCR like '%supplies%'
or gl.ACCOUNT in (select ACCOUNT from [bluebin].[PeoplesoftGLAccount]))


GROUP  BY 
jh.FISCAL_YEAR,
jh.POSTED_DATE,
jh.ACCOUNTING_PERIOD,
df.FacilityID,
df.FacilityName,


jl.ACCOUNT,
gl.DESCR,
d.DEPTID,
d.DESCR

order by 
df.FacilityName,
jl.ACCOUNT,
jh.FISCAL_YEAR,
jh.ACCOUNTING_PERIOD,
d.DEPTID,
jh.POSTED_DATE 


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
	--di.ItemDescription as ClinicalDescription,
	case when @UseClinicalDescription = 1 then
		case 
			when bn.INV_BRAND_NAME is null or bn.INV_BRAND_NAME = ''  then
					case 
						when di.ItemDescription is null or di.ItemDescription = '' then '*NEEDS*'  
						else di.ItemDescription 
						end 
		else bn.INV_BRAND_NAME end 
	else di.ItemDescription end as ClinicalDescription,
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
		left join bluebin.DimItem di on Bins.INV_ITEM_ID = di.ItemID
		left join BRAND_NAMES_INV bn on Bins.INV_ITEM_ID = bn.INV_ITEM_ID
WHERE LEFT(Carts.LOCATION, 2) IN (SELECT [ConfigValue] FROM   [bluebin].[Config] WHERE  [ConfigName] = 'REQ_LOCATION' AND Active = 1) or Carts.LOCATION in (Select REQ_LOCATION from bluebin.ALT_REQ_LOCATION) and Bins.COMPARTMENT <> ''

--and Bins.INV_ITEM_ID = '1000250'
group by
df.FacilityID,
	df.FacilityName,
	Bins.INV_ITEM_ID,
	--di.ItemDescription,
		case when @UseClinicalDescription = 1 then
		case 
			when bn.INV_BRAND_NAME is null or bn.INV_BRAND_NAME = ''  then
					case 
						when di.ItemDescription is null or di.ItemDescription = '' then '*NEEDS*'  
						else di.ItemDescription
						 end 
		else bn.INV_BRAND_NAME end 
	else di.ItemDescription end,
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

declare @Facility int = (select ConfigValue from bluebin.Config where ConfigName = 'PS_DefaultFacility')
declare @FacilityName varchar(30) = (select PSFacilityName from bluebin.DimFacility where FacilityID = @Facility)
declare @DefaultLT int = (Select max(ConfigValue) from bluebin.Config where ConfigName = 'DefaultLeadTime')
declare @POTimeAdjust int = (Select max(ConfigValue) from bluebin.Config where ConfigName = 'PS_POTimeAdjust')
;

WITH FirstScans
     AS (

		select
		LocationID,
		ItemID,
		COALESCE(DEMAND_DATE,SCHED_DTTM,NULL) as FirstScanDate
		from 
				(
				SELECT db.LocationID,
					   db.ItemID,
						Min(ct.DEMAND_DATE) AS DEMAND_DATE,
						min(id.SCHED_DTTM) as SCHED_DTTM
				 FROM   bluebin.DimBin db
				 LEFT JOIN dbo.CART_CT_INF_INV ct on db.LocationID = ct.INV_CART_ID and db.ItemID = ct.INV_ITEM_ID and ct.CART_COUNT_QTY > 0 AND ct.PROCESS_INSTANCE > 0
				 LEFT JOIN IN_DEMAND id on db.LocationID = id.LOCATION and db.ItemID = id.INV_ITEM_ID
				 GROUP  BY 
				 db.LocationID,
				  db.ItemID
				  ) a 
				   
				   ),
--**************************
Orders
     AS (
				select
                PO_LN.INV_ITEM_ID                         AS ItemID,
                PO_LN_DST.LOCATION                        AS LocationID,
                PO_LN.PO_ID                               AS OrderNum,
                PO_LN.LINE_NBR                            AS LineNum,
                RECEIPT_DTTM                              AS CloseDate,
                QTY_PO                                    AS OrderQty,
                PO_LN.UNIT_OF_MEASURE                     AS OrderUOM,
                DATEADD(hour,@POTimeAdjust,PO_HDR.PO_DT) as PO_DT,
				PO_LN_DST.ACCOUNT
         FROM   dbo.PO_LINE_DISTRIB PO_LN_DST
                INNER JOIN dbo.PO_LINE PO_LN
                        ON PO_LN_DST.PO_ID = PO_LN.PO_ID
                           AND PO_LN_DST.LINE_NBR = PO_LN.LINE_NBR
                INNER JOIN dbo.PO_HDR
                        ON PO_LN.PO_ID = PO_HDR.PO_ID
							AND PO_LN.BUSINESS_UNIT = PO_HDR.BUSINESS_UNIT
                LEFT JOIN
					(select PO_ID,LINE_NBR,max(RECEIPT_DTTM) as RECEIPT_DTTM from dbo.RECV_LN_SHIP group by PO_ID,LINE_NBR) SHIP
						ON PO_LN.PO_ID = SHIP.PO_ID
                          AND PO_LN.LINE_NBR = SHIP.LINE_NBR
				--LEFT JOIN dbo.RECV_LN_SHIP SHIP
    --                   ON PO_LN.PO_ID = SHIP.PO_ID
    --                      AND PO_LN.LINE_NBR = SHIP.LINE_NBR
                LEFT JOIN FirstScans
                       ON RIGHT(('000000000000000000' + PO_LN.INV_ITEM_ID),18) = RIGHT(('000000000000000000' + FirstScans.ItemID),18)
                          AND PO_LN_DST.LOCATION = FirstScans.LocationID
         WHERE   ISNULL(PO_LN.CANCEL_STATUS,'') NOT IN ( 'X', 'D' )

				) 
				,

Lines AS (
SELECT 
	   a.ItemID,
       a.LocationID,
       a.OrderNum,
       a.LineNum,
       a.PO_DT                AS OrderDate,
       a.CloseDate,
       a.OrderQty,
       a.OrderUOM,
	   a.ACCOUNT
FROM   Orders a


UNION ALL
SELECT 
       INV_ITEM_ID as ItemID,
       LOCATION as LocationID,
       Picks.ORDER_NO as OrderNum,
       Picks.ORDER_INT_LINE_NO as LineNum,
       COALESCE(Picks.SCHED_DTTM,Picks.DEMAND_DATE) as OrderDate,
       Picks.PICK_CONFIRM_DTTM as CloseDate,
       Cast(Picks.QTY_PICKED AS INT) AS OrderQty, 
	UNIT_OF_MEASURE as OrderUOM,
	Picks.ACCOUNT

FROM   dbo.IN_DEMAND  Picks

		LEFT JOIN FirstScans
		ON Picks.INV_ITEM_ID = FirstScans.ItemID AND Picks.LOCATION = FirstScans.LocationID
WHERE   (CANCEL_DTTM IS NULL  or CANCEL_DTTM < '1900-01-02')
	   AND DEMAND_DATE >= ISNULL(FirstScanDate,'1900-01-02')
	   )


SELECT 
COALESCE(df.FacilityID,@Facility) AS COMPANY,
COALESCE(df.FacilityName,@FacilityName) AS FacilityName,
l.OrderDate AS Date,
case when dl.BlueBinFlag = 1 then 'BlueBin' else 'Non BlueBin' end AS LineType,
ISNULL(l.ACCOUNT,'None') AS AcctUnit,
COALESCE(gl.DESCR,l.ACCOUNT,'None') AS AcctUnitName,
l.LocationID AS Location,
dl.LocationName as LocationName,
1               AS LineCount,
'' as NAME
from Lines l
inner join bluebin.DimLocation dl on  l.LocationID = dl.LocationID
inner join bluebin.DimFacility df on rtrim(dl.LocationFacility) = rtrim(df.FacilityID)
left join GL_ACCOUNT_TBL gl on l.ACCOUNT = gl.ACCOUNT



END
GO
grant exec on tb_LineVolume to public
GO




--*********************************************************************************************
--Tableau Sproc  These load data into the datasources for Tableau
--*********************************************************************************************

if exists (select * from dbo.sysobjects where id = object_id(N'tb_ROILineVolume') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure tb_ROILineVolume
GO

--exec tb_ROILineVolume

CREATE PROCEDURE tb_ROILineVolume


AS
BEGIN
SET NOCOUNT ON

declare @Facility int = (select ConfigValue from bluebin.Config where ConfigName = 'PS_DefaultFacility')
declare @FacilityName varchar(30) = (select PSFacilityName from bluebin.DimFacility where FacilityID = @Facility)
declare @DefaultLT int = (Select max(ConfigValue) from bluebin.Config where ConfigName = 'DefaultLeadTime')
declare @POTimeAdjust int = (Select max(ConfigValue) from bluebin.Config where ConfigName = 'PS_POTimeAdjust')
;

WITH FirstScans
     AS (

		select
		LocationID,
		ItemID,
		COALESCE(DEMAND_DATE,SCHED_DTTM,NULL) as FirstScanDate
		from 
				(
				SELECT db.LocationID,
					   db.ItemID,
						Min(ct.DEMAND_DATE) AS DEMAND_DATE,
						min(id.SCHED_DTTM) as SCHED_DTTM
				 FROM   bluebin.DimBin db
				 LEFT JOIN dbo.CART_CT_INF_INV ct on db.LocationID = ct.INV_CART_ID and db.ItemID = ct.INV_ITEM_ID and ct.CART_COUNT_QTY > 0 AND ct.PROCESS_INSTANCE > 0
				 LEFT JOIN IN_DEMAND id on db.LocationID = id.LOCATION and db.ItemID = id.INV_ITEM_ID
				 GROUP  BY 
				 db.LocationID,
				  db.ItemID
				  ) a 
				   
				   ),
--**************************
Orders
     AS (
				select
                PO_LN.INV_ITEM_ID                         AS ItemID,
                PO_LN_DST.LOCATION                        AS LocationID,
                PO_LN.PO_ID                               AS OrderNum,
                PO_LN.LINE_NBR                            AS LineNum,
                RECEIPT_DTTM                              AS CloseDate,
                QTY_PO                                    AS OrderQty,
                PO_LN.UNIT_OF_MEASURE                     AS OrderUOM,
                DATEADD(hour,@POTimeAdjust,PO_HDR.PO_DT) as PO_DT,
				PO_LN_DST.ACCOUNT
         FROM   dbo.PO_LINE_DISTRIB PO_LN_DST
                INNER JOIN dbo.PO_LINE PO_LN
                        ON PO_LN_DST.PO_ID = PO_LN.PO_ID
                           AND PO_LN_DST.LINE_NBR = PO_LN.LINE_NBR
                INNER JOIN dbo.PO_HDR
                        ON PO_LN.PO_ID = PO_HDR.PO_ID
						AND PO_LN.BUSINESS_UNIT = PO_HDR.BUSINESS_UNIT
                LEFT JOIN
					(select PO_ID,LINE_NBR,max(RECEIPT_DTTM) as RECEIPT_DTTM from dbo.RECV_LN_SHIP group by PO_ID,LINE_NBR) SHIP
						ON PO_LN.PO_ID = SHIP.PO_ID
                          AND PO_LN.LINE_NBR = SHIP.LINE_NBR
				--LEFT JOIN dbo.RECV_LN_SHIP SHIP
    --                   ON PO_LN.PO_ID = SHIP.PO_ID
    --                      AND PO_LN.LINE_NBR = SHIP.LINE_NBR
                LEFT JOIN FirstScans
                       ON RIGHT(('000000000000000000' + PO_LN.INV_ITEM_ID),18) = RIGHT(('000000000000000000' + FirstScans.ItemID),18)
                          AND PO_LN_DST.LOCATION = FirstScans.LocationID
         WHERE   PO_LN.CANCEL_STATUS NOT IN ( 'X', 'D' )

				)

				,

Lines AS (
SELECT 
	   a.ItemID,
       a.LocationID,
       a.OrderNum,
       a.LineNum,
       a.PO_DT                AS OrderDate,
       a.CloseDate,
       a.OrderQty,
       a.OrderUOM,
	   a.ACCOUNT
FROM   Orders a


UNION ALL
SELECT 
       INV_ITEM_ID as ItemID,
       LOCATION as LocationID,
       Picks.ORDER_NO as OrderNum,
       Picks.ORDER_INT_LINE_NO as LineNum,
       Picks.SCHED_DTTM as OrderDate,
       Picks.PICK_CONFIRM_DTTM as CloseDate,
       Cast(Picks.QTY_PICKED AS INT) AS OrderQty, 
	UNIT_OF_MEASURE as OrderUOM,
	Picks.ACCOUNT

FROM   dbo.IN_DEMAND Picks

		LEFT JOIN FirstScans
		ON Picks.INV_ITEM_ID = FirstScans.ItemID AND Picks.LOCATION = FirstScans.LocationID
WHERE   (CANCEL_DTTM IS NULL  or CANCEL_DTTM < '1900-01-02')
	   AND DEMAND_DATE >= ISNULL(FirstScanDate,'1900-01-02')
	   )
   


select 
COALESCE(df.FacilityID,@Facility) AS COMPANY,
COALESCE(df.FacilityName,@FacilityName) AS FacilityName,
l.OrderDate as [Date],
'BlueBin' AS LineType,
l.LocationID AS Location,
dl.LocationName as LocationName,

case when hdbj.OldLocationID = 'NEW' then hdbj.NewLocationID + '(N)'
else hdbj.OldLocationID + '(O) & ' +  hdbj.NewLocationID + '(N)' 
end as LocationLinking,
1 AS LineCount
from Lines l

inner join bluebin.DimLocation dl on  l.LocationID = dl.LocationID
inner join bluebin.DimFacility df on rtrim(dl.LocationFacility) = rtrim(df.FacilityID)
inner join bluebin.HistoricalDimBinJoin hdbj on l.LocationID = hdbj.NewLocationID

UNION ALL

select 
COALESCE(df.FacilityID,@Facility) AS COMPANY,
COALESCE(df.FacilityName,@FacilityName) AS FacilityName,
l.OrderDate as [Date],
'BlueBin' AS LineType,
l.LocationID AS Location,
dl.LocationName as LocationName,

case when hdbj.OldLocationID = 'NEW' then hdbj.NewLocationID + '(N)'
else hdbj.OldLocationID + '(O) & ' +  hdbj.NewLocationID + '(N)' 
end as LocationLinking,
1 AS LineCount
from Lines l
inner join bluebin.DimLocation dl on  l.LocationID = dl.LocationID
inner join bluebin.DimFacility df on rtrim(dl.LocationFacility) = rtrim(df.FacilityID)
inner join bluebin.HistoricalDimBinJoin hdbj on l.LocationID = hdbj.OldLocationID



END
GO
grant exec on tb_ROILineVolume to public
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

--****************************
--Must exec etl_DimWarehouseItem to make changes visible for tb_WarehouseSize
--****************************
exec etl_DimWarehouseItem
GO
--****************************


--*********************************************************************************************
--Tableau Sproc  These load data into the datasources for Tableau
--*********************************************************************************************
--Updated GB 20180322 added config for possibility of pulling in SOHQty that = 0 as well

if exists (select * from dbo.sysobjects where id = object_id(N'tb_WarehouseSize') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure tb_WarehouseSize
GO

--exec tb_WarehouseSize

CREATE PROCEDURE tb_WarehouseSize

--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON

declare @WHSOHQtyMinimum int
select @WHSOHQtyMinimum = ConfigValue from bluebin.Config where ConfigName = 'WHSOHQtyMinimum'

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
WHERE  SOHQty >= @WHSOHQtyMinimum --b.DOC_TYPE = 'IS' and Year(b.TRANS_DATE) >= Year(Getdate()) - 1
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
inner join [bluebin].[BlueBinResource] bbr on bbt.[BlueBinResourceID] = bbr.[BlueBinResourceID] and bbr.Active = 1
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

if exists (select * from dbo.sysobjects where id = object_id(N'tb_KanbansAdjusted') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure tb_KanbansAdjusted
GO

--exec tb_KanbansAdjusted  
/*
20171025 GB - updated to be 30 days instead of 7
declare

declare @ItemID varchar(32) = '35744'
declare @Location varchar(5) = 'DN044'
select * from bluebin.DimBinHistory where ItemID = @ItemID and LocationID = @Location
select * from bluebin.DimBin where ItemID = @ItemID and LocationID = @Location
select * from tableau.Kanban where ItemID = @ItemID and LocationID = @Location and [Date] > getdate() -7 and Scan = 1
*/

CREATE PROCEDURE [dbo].[tb_KanbansAdjusted] 
	
AS
BEGIN

select 
[Week]
,[Date]
,FacilityID
,FacilityName
,LocationID
,LocationName
,ItemID
,ItemDescription
,BinQty
,case when BinOrderChange = 1 and BinChange = 0 then BinQty else YestBinQty end as YestBinQty
,BinUOM
,case when BinOrderChange = 1 and BinChange = 0 then BinUOM else YestBinUOM end as YestBinUOM
,Sequence
,case when BinOrderChange = 1 and BinChange = 0 then Sequence else YestSequence end as YestSequence
,OrderQty
,OrderUOM
,BinChange
,BinOrderChange
,BinCurrentStatus


 from 
(
select 
case when a.OrderQty is not null and a.OrderQty <> a.BinQty and a.OrderUOM = a.BinUOM and db.BinCurrentStatus <> 'Never Scanned' and a.OrderQty <> 0  
	then DATEPART(WEEK,a.[Date]) else DATEPART(WEEK,dbh.[Date]) end as [Week]
,case when a.OrderQty is not null and a.OrderQty <> a.BinQty and a.OrderUOM = a.BinUOM and db.BinCurrentStatus <> 'Never Scanned' and a.OrderQty <> 0  
	then a.Date else dbh.[Date] end as [Date]
--,dbh.[Date]-1 as Yesterday
,db.BinFacility as FacilityID
,df.FacilityName
,db.LocationID
,dl.LocationName
,db.ItemID
,di.ItemDescription
,db.BinQty as BinQty
,dbh.LastBinQty as YestBinQty
,db.BinUOM
,dbh.LastBinUOM as YestBinUOM
,db.BinSequence as Sequence
,dbh.LastSequence as YestSequence
,ISNULL(a.OrderQty,0) as OrderQty
,ISNULL(a.OrderUOM,'N/A') as OrderUOM
,case when (dbh.BinQty <> dbh.LastBinQty or dbh.Sequence <> dbh.LastSequence) and dbh.LastBinQty >= 1 and dbh.LastSequence <> 'N/A' then 1 else 0 end as BinChange
,case when a.OrderQty is not null and a.OrderQty <> a.BinQty and a.OrderUOM = a.BinUOM and db.BinCurrentStatus <> 'Never Scanned' and a.OrderQty <> 0  then 1 else 0 end as BinOrderChange
,db.BinCurrentStatus





from bluebin.DimBin db 
inner join bluebin.DimFacility df on db.BinFacility = df.FacilityID
inner join bluebin.DimLocation dl on db.LocationID = dl.LocationID
inner join bluebin.DimItem di on db.ItemID = di.ItemID

left join(select distinct dbh.[Date],dbh.BinKey,dbh.FacilityID,dbh.LocationID,dbh.ItemID,dbh.BinQty,dbh.BinUOM,dbh.[Sequence],dbh.LastBinQty,dbh.LastBinUOM,dbh.[LastSequence] 
			from bluebin.DimBinHistory dbh
			inner join (select FacilityID,LocationID,ItemID,max(Date) as LastDate from bluebin.DimBinHistory group by FacilityID,LocationID,ItemID) mmax 
							on dbh.FacilityID = mmax.FacilityID and dbh.LocationID = mmax.LocationID and dbh.ItemID = mmax.ItemID and dbh.[Date] = mmax.LastDate) dbh on db.BinFacility = dbh.FacilityID and db.LocationID = dbh.LocationID and db.ItemID = dbh.ItemID and dbh.[Date] >= getdate() -30

left join (select FacilityID,LocationID,ItemID,[Date],OrderQty,OrderUOM,BinUOM,BinQty from tableau.Kanban where Scan = 1 and OrderQty <> BinQty and OrderQty <> 0 and Date >= getdate() -30) a on db.BinFacility= a.FacilityID and db.LocationID = a.LocationID and db.ItemID = a.ItemID-- and a.[Date] >= dbh.LastDate


--where dbh.[Date] >= getdate() -7 
--and a.LocationID = 'B7435' and a.ItemID = '30003' 
--order by dbh.FacilityID,dbh.LocationID,dbh.ItemID
) a
where BinChange = 1 or BinOrderChange = 1
group by 
Week,
Date,
FacilityID,
FacilityName,
LocationID,
LocationName,
ItemID,
ItemDescription,
BinQty,
YestBinQty,
BinUOM,
YestBinUOM,
Sequence,
YestSequence,
OrderQty,
OrderUOM,
BinChange,
BinOrderChange,
BinCurrentStatus
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
declare @Facility int = (select ConfigValue from bluebin.Config where ConfigName = 'PS_DefaultFacility')
declare @FacilityName varchar(30) = (select PSFacilityName from bluebin.DimFacility where FacilityID = @Facility)
  

select 
k.OrderDate as CREATION_DATE,
df.FacilityID as COMPANY,
df.FacilityName,
k.LocationID as REQ_LOCATION,
k.OrderNum as REQ_NUMBER,
k.LineNum as Lines,
'BlueBin' as NAME,
dl.BlueBinFlag
from tableau.Kanban k
inner join bluebin.DimLocation dl on  k.FacilityID = dl.LocationFacility and k.LocationID = dl.LocationID 
inner join bluebin.DimFacility df on rtrim(dl.LocationFacility) = rtrim(df.FacilityID)
--left join REQUESTER r on rh.REQUESTER = r.REQUESTER and rq.COMPANY = r.COMPANY
where k.OrderDate > getdate()-15 and Scan > 0



GO
grant exec on tb_OrderVolume to public
GO

--*********************************************************************************************
--Tableau Sproc  These load data into the datasources for Tableau
--*********************************************************************************************
--Created GB 20180410

if exists (select * from dbo.sysobjects where id = object_id(N'tb_ItemUtilization') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure tb_ItemUtilization
GO

--select BinStatus,* from tableau.Kanban where BinKey > 7142 order by BinKey,Date
--exec tb_ItemUtilization 
CREATE PROCEDURE tb_ItemUtilization

--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON

select 
dd.Date,
convert(int,((getdate()-1)-dd.Date)) as [Days],
ISNULL(slow.SlowCt,0) as SlowCt,
ISNULL(stale.StaleCt,0) as StaleCt,
ISNULL(slow.SlowCt,0) + ISNULL(stale.StaleCt,0) as SlowStaleCt,
ISNULL(ct.TotalCt,0) - (ISNULL(slow.SlowCt,0) + ISNULL(stale.StaleCt,0)) as NonSlowStaleCt,
ISNULL(ct.TotalCt,0) as TotalCt,
(ISNULL((ISNULL(ct.TotalCt,0) - (ISNULL(slow.SlowCt,0) + ISNULL(stale.StaleCt,0)))*100,0)/ISNULL(ct.TotalCt,1)) as DailyUtilization
from bluebin.DimDate dd

left join (select Date,count(*) as SlowCt from tableau.Kanban where BinStatus = 'Slow' group by Date) slow on dd.Date = slow.Date
left join (select Date,count(*) as StaleCt from tableau.Kanban where BinStatus = 'Stale' group by Date) stale on dd.Date = stale.Date
left join (select Date,count(*) as TotalCt from tableau.Kanban group by Date) ct on dd.Date = ct.Date
where dd.Date > getdate() -91 and dd.Date < getdate() and ct.TotalCt > 0

order by dd.Date desc


END
GO
grant exec on tb_ItemUtilization to public
GO

--*********************************************************************************************
--Tableau Sproc  These load data into the datasources for Tableau
--*********************************************************************************************

if exists (select * from dbo.sysobjects where id = object_id(N'tb_LocationForecast') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure tb_LocationForecast
GO

--exec tb_LocationForecast
--select top 10* from tableau.Sourcing


CREATE PROCEDURE tb_LocationForecast

--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON

select 
FacilityName,
LocationName,
LocationID,
ItemID,
ItemClinicalDescription,
BinUOM,
ItemType,
--convert(int,TotalPar) as TotalPar,
--[Month],
FirstPODate,
--Sum(OrderQty)/365 as AvgDailyQty,
--Sum(OrderQty)/12 as AvgMonthlyQty,
Sum(OrderQty) as TotalOrderQty,
case when Denominator > 365 then Sum(OrderQty)/365 else Sum(OrderQty)/Denominator end as AvgDailyQty,
case when Denominator > 365 then Sum(OrderQty)/12 else Sum(OrderQty)/Denominator30 end as AvgMonthlyQty

--Sum(OrderQty*BinCurrentCost) as Cost
from (
	select
	k.FacilityName,
	dl.LocationName,
	dl.LocationID,
	k.ItemNumber as ItemID,
	di.ItemClinicalDescription,
	k.[PODate],
	dateadd(month,datediff(month,0,k.[PODate]),0) as [Month],
	k.BuyUOM as BinUOM,
	k.POItemType as ItemType,
	k.QtyOrdered as OrderQty,
	db.BinQty as TotalPar,
	db.BinCurrentCost,
	convert(Decimal(13,4),a.Denominator) as Denominator,
	convert(Decimal(13,4),a.Denominator)/30 as Denominator30,
	a.FirstPODate
	from tableau.Sourcing k
	left join bluebin.DimBin db on k.PurchaseFacility = db.BinFacility and k.PurchaseLocation = db.LocationID and k.ItemNumber = db.ItemID
	inner join bluebin.DimLocation dl on k.PurchaseLocation = dl.LocationID
	inner join bluebin.DimItem di on k.ItemNumber = di.ItemID
	inner join (
				select 
					Company,
					PurchaseLocation,
					ItemNumber,
					min(PODate) as FirstPODate,
					DATEDIFF(day,min(PODate),getdate()) as Denominator
					from tableau.Sourcing 
					where  (PurchaseLocation is not null or PurchaseLocation <> '') --and PODate > getdate() -365 
					group by
					Company,
					PurchaseLocation,
					ItemNumber
					--order by 5 asc
				) a on k.Company = a.Company and k.PurchaseLocation = a.PurchaseLocation and k.ItemNumber = a.ItemNumber

	where k.QtyOrdered is not null and k.BlueBinFlag = 'No' and PODate > getdate() -365
	--and k.PODate > getdate() -10
	) a

group by
FacilityName,
LocationName,
LocationID,
ItemID,
ItemClinicalDescription,
BinUOM,
ItemType,
FirstPODate,
Denominator,
Denominator30
--convert(int,TotalPar),
--[Month]
order by 1,2,4

END
GO
grant exec on tb_LocationForecast to public
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
			where fs.OrderDate >= @TodayDate
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


if exists (select * from dbo.sysobjects where id = object_id(N'etl_DimBinHistory') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure etl_DimBinHistory
GO

--exec etl_DimBinHistory  update bluebin.DimBinHistory set Date = Date -1 

CREATE PROCEDURE [dbo].[etl_DimBinHistory] 
	
AS

/*
select * from bluebin.DimBinHistory order by Date desc
select * from bluebin.DimBin where LocationID = 'B6183' and ItemID = '700'  
select * from tableau.Kanban where LocationID = 'B6183' and ItemID = '700' and convert(Date,[Date]) = convert(Date,getdate()-1)
update bluebin.DimBinHistory set LastUpdated = getdate() -3 where DimBinHistoryID = 6161
truncate table bluebin.DimBinHistory

delete from bluebin.DimBinHistory where BinQty = LastBinQty and BinUOM = LastBinUOM and [Sequence] = [LastSequence] and Date <> (select min(Date) from bluebin.DimBinHistory)
delete from bluebin.DimBinHistory where [Date] = '2017-04-18'
exec etl_DimBinHistory

exec tb_KanbansAdjusted
exec tb_KanbansAdjustedHB
select * from bluebin.DimBinHistory where [Date] = '2017-04-17' and (BinQty <> LastBinQty or BinUOM <> LastBinUOM or [Sequence] <> [LastSequence])
*/
Delete from bluebin.DimBinHistory where [Date] < convert(Date,getdate()-100)


IF (select count(*) from bluebin.DimBinHistory) < 1
BEGIN
--insert into bluebin.DimBinHistory ([Date],BinKey,FacilityID,LocationID,ItemID,BinQty,BinUOM,[Sequence],LastBinQty,LastBinUOM,[LastSequence]) 
--select distinct convert(Date,getdate()-2),BinKey,BinFacility,LocationID,ItemID,BinQty,BinUOM,BinSequence,BinQty,BinUOM,BinSequence from bluebin.DimBin
--where ItemID = '47532'
insert into bluebin.DimBinHistory ([Date],BinKey,FacilityID,LocationID,ItemID,BinQty,BinUOM,[Sequence],LastBinQty,LastBinUOM,[LastSequence]) 
select distinct convert(Date,getdate()-1),BinKey,BinFacility,LocationID,ItemID,BinQty,BinUOM,BinSequence,BinQty,BinUOM,BinSequence from bluebin.DimBin
--where ItemID = '256'
END

if not exists (select * from bluebin.DimBinHistory where [Date] = convert(Date,getdate()-1))
BEGIN

insert into bluebin.DimBinHistory ([Date],BinKey,FacilityID,LocationID,ItemID,BinQty,BinUOM,[Sequence],LastBinQty,LastBinUOM,[LastSequence]) 
select convert(Date,getdate()-1),db.BinKey,db.BinFacility,db.LocationID,db.ItemID,convert(int,db.BinQty),db.BinUOM,db.BinSequence,ISNULL(dbh.BinQty,0),ISNULL(dbh.BinUOM,'N/A'),ISNULL(dbh.Sequence,'N/A')
from bluebin.DimBin db
left join 
	(select distinct dbh.[Date],dbh.BinKey,dbh.FacilityID,dbh.LocationID,dbh.ItemID,dbh.BinQty,dbh.BinUOM,dbh.[Sequence] 
			from bluebin.DimBinHistory dbh
			inner join (select FacilityID,LocationID,ItemID,max(Date) as LastDate from bluebin.DimBinHistory group by FacilityID,LocationID,ItemID) mmax 
							on dbh.FacilityID = mmax.FacilityID and dbh.LocationID = mmax.LocationID and dbh.ItemID = mmax.ItemID and dbh.[Date] = mmax.LastDate
			--where [Date] = convert(Date,getdate()-2)
			) dbh on db.BinFacility = dbh.FacilityID and db.LocationID = dbh.LocationID and db.ItemID = dbh.ItemID
where convert(int,db.BinQty) <> ISNULL(dbh.BinQty,0) or db.BinUOM <> ISNULL(dbh.BinUOM,'N/A') or db.BinSequence <> ISNULL(dbh.Sequence,'N/A')

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

--Declare @A table (ConeDeployed int,Deployed datetime,ExpectedDelivery Datetime,ConeReturned int,Returned datetime,FacilityID int,FacilityName varchar(255),LocationID varchar(15),LocationName varchar(50),ItemID varchar(32),ItemDescription varchar(50),BinSequence varchar(20),SubProduct varchar(3),AllLocations varchar(max))
	
--insert into @A	
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



--if not exists (select * from @A)
--BEGIN
--select 
--	1 as ConeDeployed,
--	getdate() as Deployed,
--	getdate() as ExpectedDelivery,
--	0 as ConeReturned,
--	'' as Returned,
--	'' asFacilityID,
--	'' as FacilityName,
--	'None' as LocationID,
--	'None' as LocationName,
--	'' as ItemID,
--	'' as ItemDescription,
--	'' as BinSequence,
--	'' as SubProduct,
--	'' as AllLocations
	
--	END
--ELSE
--BEGIN
--select * from @A
--END


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

--declare @A Table ([Date] Date,FacilityID int,FacilityName varchar(255),LocationID varchar(10),LocationName varchar(30),ItemID varchar(32),ItemDescription varchar(30),OrderDate datetime,OrderNum varchar(10),LineNum int,OrderQty int)

--insert into @A
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
convert(varchar(10),scan.ScanBatchID) as OrderNum,
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


--if not exists (select * from @A)
--BEGIN
--select 
--getdate() as [Date],
--'' as FacilityID,
--'' as FacilityName,
--'None' as LocationID,
--'None' as LocationName,
--'' as ItemID,
--'' as ItemDescription,
--'' as OrderDate,
--'' as OrderNum,
--'' as LineNum,
--'' as OrderQty
--END
--ELSE
--BEGIN
--select * from @A order by LocationID
--END
GO

grant exec on tb_CurrentStockOuts to public
GO

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

if exists (select * from dbo.sysobjects where id = object_id(N'tb_GembaDashboard') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure tb_GembaDashboard
GO

--exec tb_GembaDashboard 
CREATE PROCEDURE tb_GembaDashboard


--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON

declare @GembaIdentifier varchar(50)
select @GembaIdentifier = ConfigValue from bluebin.Config where ConfigName = 'GembaIdentifier'

if @GembaIdentifier = '' 
BEGIN
set @GembaIdentifier = 'XXXXX'
END

select 
	g.[GembaAuditNodeID],
	df.FacilityName,
	dl.[LocationID],
	dl.LocationID as AuditLocationID,
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
		
    g.[LastUpdated],
	PS_Comments,
	RS_Comments,
	NIS_Comments,
	SS_Comments,
	AdditionalComments,
	case
		when AdditionalComments like '%'+ @GembaIdentifier + '%' then 'Yes' else 'No' end as GembaIdent
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
WHERE dl.BlueBinFlag = 1 and (g.Active = 1 or g.Active is null)
            order by dl.LocationID,[Date] asc

END
GO
grant exec on tb_GembaDashboard to public
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

select distinct
[Week],
[Date],
FacilityID,
FacilityName,
SUM(BinChange) as BinChange,
Sum(BinOrderChange) as BinOrderChange
from (
select 
[Week]
,[Date]
,FacilityID
,FacilityName
,LocationID
,LocationName
,ItemID
,ItemDescription
,BinQty
,case when BinOrderChange = 1 and BinChange = 0 then BinQty else YestBinQty end as YestBinQty
,BinUOM
,case when BinOrderChange = 1 and BinChange = 0 then BinUOM else YestBinUOM end as YestBinUOM
,Sequence
,case when BinOrderChange = 1 and BinChange = 0 then Sequence else YestSequence end as YestSequence
,OrderQty
,OrderUOM
,BinChange
,BinOrderChange
,BinCurrentStatus


 from 
(
select 
case when a.OrderQty is not null and a.OrderQty <> a.BinQty and a.OrderUOM = a.BinUOM and db.BinCurrentStatus <> 'Never Scanned' and a.OrderQty <> 0  
	then DATEPART(WEEK,a.[Date]) else DATEPART(WEEK,dbh.[Date]) end as [Week]
,case when a.OrderQty is not null and a.OrderQty <> a.BinQty and a.OrderUOM = a.BinUOM and db.BinCurrentStatus <> 'Never Scanned' and a.OrderQty <> 0  
	then a.Date else dbh.[Date] end as [Date]
--,dbh.[Date]-1 as Yesterday
,db.BinFacility as FacilityID
,df.FacilityName
,db.LocationID
,dl.LocationName
,db.ItemID
,di.ItemDescription
,db.BinQty as BinQty
,dbh.LastBinQty as YestBinQty
,db.BinUOM
,dbh.LastBinUOM as YestBinUOM
,db.BinSequence as Sequence
,dbh.LastSequence as YestSequence
,ISNULL(a.OrderQty,0) as OrderQty
,ISNULL(a.OrderUOM,'N/A') as OrderUOM
,case when (dbh.BinQty <> dbh.LastBinQty or dbh.Sequence <> dbh.LastSequence) and dbh.LastBinQty >= 1 and dbh.LastSequence <> 'N/A' then 1 else 0 end as BinChange
,case when a.OrderQty is not null and a.OrderQty <> a.BinQty and a.OrderUOM = a.BinUOM and db.BinCurrentStatus <> 'Never Scanned' and a.OrderQty <> 0  then 1 else 0 end as BinOrderChange
,db.BinCurrentStatus

from bluebin.DimBin db 
inner join bluebin.DimFacility df on db.BinFacility = df.FacilityID
inner join bluebin.DimLocation dl on db.LocationID = dl.LocationID
inner join bluebin.DimItem di on db.ItemID = di.ItemID

left join(select distinct dbh.[Date],dbh.BinKey,dbh.FacilityID,dbh.LocationID,dbh.ItemID,dbh.BinQty,dbh.BinUOM,dbh.[Sequence],dbh.LastBinQty,dbh.LastBinUOM,dbh.[LastSequence] 
			from bluebin.DimBinHistory dbh
			inner join (select FacilityID,LocationID,ItemID,max(Date) as LastDate from bluebin.DimBinHistory group by FacilityID,LocationID,ItemID) mmax 
							on dbh.FacilityID = mmax.FacilityID and dbh.LocationID = mmax.LocationID and dbh.ItemID = mmax.ItemID and dbh.[Date] = mmax.LastDate) dbh on db.BinFacility = dbh.FacilityID and db.LocationID = dbh.LocationID and db.ItemID = dbh.ItemID and dbh.[Date] >= getdate() -7

left join (select FacilityID,LocationID,ItemID,[Date],OrderQty,OrderUOM,BinUOM,BinQty from tableau.Kanban where Scan = 1 and OrderQty <> BinQty and OrderQty <> 0 and Date >= getdate() -7) a on db.BinFacility= a.FacilityID and db.LocationID = a.LocationID and db.ItemID = a.ItemID-- and a.[Date] >= dbh.LastDate


--where dbh.[Date] >= getdate() -7 
--and a.LocationID = 'B7435' and a.ItemID = '30003' 
--order by dbh.FacilityID,dbh.LocationID,dbh.ItemID
) a
where BinChange = 1 or BinOrderChange = 1
group by 
Week,
Date,
FacilityID,
FacilityName,
LocationID,
LocationName,
ItemID,
ItemDescription,
BinQty,
YestBinQty,
BinUOM,
YestBinUOM,
Sequence,
YestSequence,
OrderQty,
OrderUOM,
BinChange,
BinOrderChange,
BinCurrentStatus


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
case when p.REQ_ID is null or p.REQ_ID = ''
then 
	case when OrderNum like 'MSR%' then OrderNum
		else OrderNum + ' (PO)' end
	else ISNULL(p.REQ_ID,'') end as [Order Num],
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
and p.REQ_ID <> '0'
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
--Updated GB 20180307 Altered Facility pulling based on multiple facilities

if exists (select * from dbo.sysobjects where id = object_id(N'tb_StatCalls') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure tb_StatCalls
GO


--exec tb_StatCalls
CREATE PROCEDURE tb_StatCalls
AS
BEGIN
SET NOCOUNT ON

declare @Facility int = (select ConfigValue from bluebin.Config where ConfigName = 'PS_DefaultFacility')
declare @FacilityName varchar(30) = (select PSFacilityName from bluebin.DimFacility where FacilityID = @Facility)

SELECT 
COALESCE(df.FacilityID,@Facility) as FROM_TO_CMPY,
--case when @Facility is not null or @Facility <> '' then COALESCE(@Facility,BUSINESS_UNIT) else BUSINESS_UNIT end as FROM_TO_CMPY,
COALESCE(df.PSFacilityName,@FacilityName) as FacilityName,
lt.LOCATION as LocationID,
lt.DESCR as LocationName,
case when ISNULL(dl.BlueBinFlag,0) = 1 then 'Yes' else 'No' end as BlueBinFlag,
DEMAND_DATE       AS [Date],
COUNT(*) as StatCalls,
case when BUSINESS_UNIT <> SOURCE_BUS_UNIT then SOURCE_BUS_UNIT else BUSINESS_UNIT end as Department,
case when ORDER_NO LIKE 'MSR%' then 'Yes' else 'No' end as WHSource

FROM   IN_DEMAND
       LEFT JOIN LOCATION_TBL lt on rtrim(IN_DEMAND.LOCATION) = rtrim(lt.LOCATION)
	   LEFT JOIN bluebin.DimLocation dl ON lt.LOCATION = dl.LocationID
	   LEFT JOIN bluebin.DimFacility df on IN_DEMAND.BUSINESS_UNIT= df.FacilityName
	   

WHERE  PICK_BATCH_ID = 0
       AND (BUSINESS_UNIT in (Select ConfigValue from bluebin.Config where ConfigName = 'PS_BUSINESSUNITSTAT') or SOURCE_BUS_UNIT in (Select ConfigValue from bluebin.Config where ConfigName = 'PS_BUSINESSUNIT'))
	   AND (IN_FULFILL_STATE in (select ConfigValue from bluebin.Config where ConfigName = 'PS_InFulfillState') or IN_FULFILL_STATE is null)


GROUP BY
--DimLocation.LocationID,
--DimLocation.LocationName,
BUSINESS_UNIT,
df.FacilityID,
SOURCE_BUS_UNIT,
df.PSFacilityName,
lt.LOCATION,
lt.DESCR,
dl.BlueBinFlag,
DEMAND_DATE,
ORDER_NO
Order by DEMAND_DATE



END
GO
grant exec on tb_StatCalls to public
GO

--*********************************************************************************************
--Tableau Sproc  These load data into the datasources for Tableau
--*********************************************************************************************

IF EXISTS ( SELECT  *
            FROM    sys.objects
            WHERE   object_id = OBJECT_ID(N'tb_TimeStudyStrider')
                    AND type IN ( N'P', N'PC' ) ) 

--exec tb_TimeStudyStrider
DROP PROCEDURE  tb_TimeStudyStrider
GO

CREATE PROCEDURE tb_TimeStudyStrider

AS
BEGIN
SET NOCOUNT ON

/* CTE Table */
Declare @StriderActivityTimes TABLE ( Activity varchar(100),FacilityID int,BlueBinResourceID int, ResourceName varchar(50),AvgS DECIMAL(10,2), AvgM DECIMAL(10,2), AvgH DECIMAL(10,2), LastUpdated date)

/* Bin Fill */
INSERT INTO @StriderActivityTimes
select 
'Bin Fill' as Activity,
c.FacilityID,
c.BlueBinResourceID,
df.LastName + ', ' + df.FirstName as ResourceName,
CAST(AVG(AllSecItem) AS DECIMAL(10,2)) as AvgS,
CAST(AVG(AllSecItem)/60 AS DECIMAL(10,2)) as AvgM,
CAST(AVG(AllSecItem)/360 AS DECIMAL(10,2)) as AvgH,
convert(Date,getdate()) as LastUpdated

from (
		select FacilityID,BlueBinResourceID,CAST(AVG(SecItem) AS DECIMAL(10,2)) as AllSecItem from (
			select FacilityID,BlueBinResourceID,DATEDIFF(s,StartTime,StopTime)/SKUS as SecItem from bluebin.TimeStudyBinFill where MostRecent = 1) as a
			group by FacilityID,BlueBinResourceID
		UNION 
		select FacilityID,BlueBinResourceID,CAST(AVG(SecItem) AS DECIMAL(10,2)) from (
			select FacilityID,BlueBinResourceID,DATEDIFF(s,StartTime,StopTime)/SKUS as SecItem from bluebin.TimeStudyBinFill where MostRecent = 0) as b
			group by FacilityID,BlueBinResourceID
		) as c 
		inner join bluebin.BlueBinResource df on c.BlueBinResourceID = df.BlueBinResourceID 
		group by c.FacilityID,c.BlueBinResourceID,df.LastName + ', ' + df.FirstName
		
/* Node Service */
INSERT INTO @StriderActivityTimes
select 
'NodeService' as Activity,
c.FacilityID,
c.BlueBinResourceID,
df.LastName + ', ' + df.FirstName as ResourceName,
CAST(AVG(AllSecItem) AS DECIMAL(10,2)) as AvgS,
CAST(AVG(AllSecItem)/60 AS DECIMAL(10,2)) as AvgM,
CAST(AVG(AllSecItem)/360 AS DECIMAL(10,2)) as AvgH,
convert(Date,getdate()) as LastUpdated
from (
		select FacilityID,BlueBinResourceID,CAST(AVG(SecItem) AS DECIMAL(10,2)) as AllSecItem from (
			select FacilityID,BlueBinResourceID,DATEDIFF(s,StartTime,StopTime)/SKUS as SecItem 
			from bluebin.TimeStudyNodeService 
			where TimeStudyProcessID = (Select ConfigID from bluebin.Config where ConfigName = 'Node Service' and ConfigValue = 'Node service time') 
			and MostRecent = 1) as a
			group by FacilityID,BlueBinResourceID
		UNION 
		select FacilityID,BlueBinResourceID,CAST(AVG(SecItem) AS DECIMAL(10,2)) from (
			select FacilityID,BlueBinResourceID,DATEDIFF(s,StartTime,StopTime)/SKUS as SecItem 
			from bluebin.TimeStudyNodeService 
			where  TimeStudyProcessID = (Select ConfigID from bluebin.Config where ConfigName = 'Node Service' and ConfigValue = 'Node service time')
			and MostRecent = 0) as b
			group by FacilityID,BlueBinResourceID
		) as c 
		inner join bluebin.BlueBinResource df on c.BlueBinResourceID = df.BlueBinResourceID 
		group by c.FacilityID,c.BlueBinResourceID,df.LastName + ', ' + df.FirstName

/* Travel Times All */
INSERT INTO @StriderActivityTimes
select 
'TravelTimeAll' as Activity,
c.FacilityID,
c.BlueBinResourceID,
df.LastName + ', ' + df.FirstName as ResourceName,
CAST(AVG(AllSecItem) AS DECIMAL(10,2)) as AvgS,
CAST(AVG(AllSecItem)/60 AS DECIMAL(10,2)) as AvgM,
CAST(AVG(AllSecItem)/360 AS DECIMAL(10,2)) as AvgH,
convert(Date,getdate()) as LastUpdated
from (
		select FacilityID,BlueBinResourceID,CAST(AVG(SecItem) AS DECIMAL(10,2)) as AllSecItem from (
			select FacilityID,BlueBinResourceID,DATEDIFF(s,StartTime,StopTime) as SecItem 
			from bluebin.TimeStudyNodeService 
			where TimeStudyProcessID in (Select ConfigID from bluebin.Config where ConfigName = 'Node Service' and ConfigValue in ('Travel Back to Stage','Travel time to next node','Leave Stage to enter node')) 
			and MostRecent = 1) as a
			group by FacilityID,BlueBinResourceID
		UNION 
		select FacilityID,BlueBinResourceID,CAST(AVG(SecItem) AS DECIMAL(10,2)) from (
			select FacilityID,BlueBinResourceID,DATEDIFF(s,StartTime,StopTime) as SecItem 
			from bluebin.TimeStudyNodeService 
			where  TimeStudyProcessID in (Select ConfigID from bluebin.Config where ConfigName = 'Node Service' and ConfigValue in ('Travel Back to Stage','Travel time to next node','Leave Stage to enter node'))
			and MostRecent = 0) as b
			group by FacilityID,BlueBinResourceID
		) as c 
		inner join bluebin.BlueBinResource df on c.BlueBinResourceID = df.BlueBinResourceID 
		group by c.FacilityID,c.BlueBinResourceID,df.LastName + ', ' + df.FirstName

/* Travel Times To Stage */
INSERT INTO @StriderActivityTimes
select 
'TravelTimeToStage' as Activity,
c.FacilityID,
c.BlueBinResourceID,
df.LastName + ', ' + df.FirstName as ResourceName,
CAST(AVG(AllSecItem) AS DECIMAL(10,2)) as AvgS,
CAST(AVG(AllSecItem)/60 AS DECIMAL(10,2)) as AvgM,
CAST(AVG(AllSecItem)/360 AS DECIMAL(10,2)) as AvgH,
convert(Date,getdate()) as LastUpdated
from (
		select FacilityID,BlueBinResourceID,CAST(AVG(SecItem) AS DECIMAL(10,2)) as AllSecItem from (
			select FacilityID,BlueBinResourceID,DATEDIFF(s,StartTime,StopTime) as SecItem 
			from bluebin.TimeStudyNodeService 
			where TimeStudyProcessID in (Select ConfigID from bluebin.Config where ConfigName = 'Node Service' and ConfigValue in ('Travel Back to Stage')) 
			and MostRecent = 1) as a
			group by FacilityID,BlueBinResourceID
		UNION 
		select FacilityID,BlueBinResourceID,CAST(AVG(SecItem) AS DECIMAL(10,2)) from (
			select FacilityID,BlueBinResourceID,DATEDIFF(s,StartTime,StopTime) as SecItem 
			from bluebin.TimeStudyNodeService 
			where  TimeStudyProcessID in (Select ConfigID from bluebin.Config where ConfigName = 'Node Service' and ConfigValue in ('Travel Back to Stage'))
			and MostRecent = 0) as b
			group by FacilityID,BlueBinResourceID
		) as c 
		inner join bluebin.BlueBinResource df on c.BlueBinResourceID = df.BlueBinResourceID 
		group by c.FacilityID,c.BlueBinResourceID,df.LastName + ', ' + df.FirstName


/* Travel Times Next Node */
INSERT INTO @StriderActivityTimes
select 
'TravelTimeNextNode' as Activity,
c.FacilityID,
c.BlueBinResourceID,
df.LastName + ', ' + df.FirstName as ResourceName,
CAST(AVG(AllSecItem) AS DECIMAL(10,2)) as AvgS,
CAST(AVG(AllSecItem)/60 AS DECIMAL(10,2)) as AvgM,
CAST(AVG(AllSecItem)/360 AS DECIMAL(10,2)) as AvgH,
convert(Date,getdate()) as LastUpdated
from (
		select FacilityID,BlueBinResourceID,CAST(AVG(SecItem) AS DECIMAL(10,2)) as AllSecItem from (
			select FacilityID,BlueBinResourceID,DATEDIFF(s,StartTime,StopTime) as SecItem 
			from bluebin.TimeStudyNodeService 
			where TimeStudyProcessID in (Select ConfigID from bluebin.Config where ConfigName = 'Node Service' and ConfigValue in ('Travel time to next node')) 
			and MostRecent = 1) as a
			group by FacilityID,BlueBinResourceID
		UNION 
		select FacilityID,BlueBinResourceID,CAST(AVG(SecItem) AS DECIMAL(10,2)) from (
			select FacilityID,BlueBinResourceID,DATEDIFF(s,StartTime,StopTime) as SecItem 
			from bluebin.TimeStudyNodeService 
			where  TimeStudyProcessID in (Select ConfigID from bluebin.Config where ConfigName = 'Node Service' and ConfigValue in ('Travel time to next node'))
			and MostRecent = 0) as b
			group by FacilityID,BlueBinResourceID
		) as c 
		inner join bluebin.BlueBinResource df on c.BlueBinResourceID = df.BlueBinResourceID 
		group by c.FacilityID,c.BlueBinResourceID,df.LastName + ', ' + df.FirstName

/* Travel Times From Stage */
INSERT INTO @StriderActivityTimes
select 
'TravelTimeFromStage' as Activity,
c.FacilityID,
c.BlueBinResourceID,
df.LastName + ', ' + df.FirstName as ResourceName,
CAST(AVG(AllSecItem) AS DECIMAL(10,2)) as AvgS,
CAST(AVG(AllSecItem)/60 AS DECIMAL(10,2)) as AvgM,
CAST(AVG(AllSecItem)/360 AS DECIMAL(10,2)) as AvgH,
convert(Date,getdate()) as LastUpdated
from (
		select FacilityID,BlueBinResourceID,CAST(AVG(SecItem) AS DECIMAL(10,2)) as AllSecItem from (
			select FacilityID,BlueBinResourceID,DATEDIFF(s,StartTime,StopTime) as SecItem 
			from bluebin.TimeStudyNodeService 
			where TimeStudyProcessID in (Select ConfigID from bluebin.Config where ConfigName = 'Node Service' and ConfigValue in ('Leave Stage to enter node')) 
			and MostRecent = 1) as a
			group by FacilityID,BlueBinResourceID
		UNION 
		select FacilityID,BlueBinResourceID,CAST(AVG(SecItem) AS DECIMAL(10,2)) from (
			select FacilityID,BlueBinResourceID,DATEDIFF(s,StartTime,StopTime) as SecItem 
			from bluebin.TimeStudyNodeService 
			where  TimeStudyProcessID in (Select ConfigID from bluebin.Config where ConfigName = 'Node Service' and ConfigValue in ('Leave Stage to enter node'))
			and MostRecent = 0) as b
			group by FacilityID,BlueBinResourceID
		) as c
		inner join bluebin.BlueBinResource df on c.BlueBinResourceID = df.BlueBinResourceID 
		group by c.FacilityID,c.BlueBinResourceID,df.LastName + ', ' + df.FirstName




declare @ReturnsBinTH DECIMAL(10,2) = (select max(ConfigValue) from bluebin.Config where ConfigName = 'Returns Bins Threshhold')--default is Bin #s





/* Returns Bins Small */
INSERT INTO @StriderActivityTimes
select 
'Returns Bins Small' as Activity,
c.FacilityID,df.BlueBinResourceID,
df.LastName + ', ' + df.FirstName as ResourceName,
CAST(AVG(AllSecItem) AS DECIMAL(10,2)) as AvgS,
CAST(AVG(AllSecItem)/60 AS DECIMAL(10,2)) as AvgM,
CAST(AVG(AllSecItem)/360 AS DECIMAL(10,2)) as AvgH,
convert(Date,getdate()) as LastUpdated
from (
		select FacilityID,BlueBinResourceID,CAST(AVG(SecItem) AS DECIMAL(10,2)) as AllSecItem from (
			select FacilityID,BlueBinResourceID,DATEDIFF(s,StartTime,StopTime) as SecItem 
			from bluebin.TimeStudyNodeService 
			where TimeStudyProcessID in (Select ConfigID from bluebin.Config where ConfigName = 'Node Service' and ConfigValue in ('Returns bin time')) 
			and MostRecent = 1
			and SKUS <= @ReturnsBinTH) as a
			group by FacilityID,BlueBinResourceID
		UNION 
		select FacilityID,BlueBinResourceID,CAST(AVG(SecItem) AS DECIMAL(10,2)) from (
			select FacilityID,BlueBinResourceID,DATEDIFF(s,StartTime,StopTime) as SecItem 
			from bluebin.TimeStudyNodeService 
			where  TimeStudyProcessID in (Select ConfigID from bluebin.Config where ConfigName = 'Node Service' and ConfigValue in ('Returns bin time'))
			and MostRecent = 0
			and SKUS <=@ReturnsBinTH) as b
			group by FacilityID,BlueBinResourceID
		) as c 
		right join bluebin.BlueBinResource df on c.BlueBinResourceID = df.BlueBinResourceID
		 
		group by c.FacilityID,df.BlueBinResourceID,df.LastName + ', ' + df.FirstName
		 
/* Returns Bins Large */

INSERT INTO @StriderActivityTimes
select 
'Returns Bins Large' as Activity,
c.FacilityID,
df.BlueBinResourceID,
df.LastName + ', ' + df.FirstName as ResourceName,
CAST(AVG(AllSecItem) AS DECIMAL(10,2)) as AvgS,
CAST(AVG(AllSecItem)/60 AS DECIMAL(10,2)) as AvgM,
CAST(AVG(AllSecItem)/360 AS DECIMAL(10,2)) as AvgH,
convert(Date,getdate()) as LastUpdated
from (
		select FacilityID,BlueBinResourceID,CAST(AVG(SecItem) AS DECIMAL(10,2)) as AllSecItem from (
			select FacilityID,BlueBinResourceID,DATEDIFF(s,StartTime,StopTime) as SecItem 
			from bluebin.TimeStudyNodeService 
			where TimeStudyProcessID in (Select ConfigID from bluebin.Config where ConfigName = 'Node Service' and ConfigValue in ('Returns bin time')) 
			and MostRecent = 1
			and SKUS > @ReturnsBinTH) as a
			group by FacilityID,BlueBinResourceID
		UNION 
		select FacilityID,BlueBinResourceID,CAST(AVG(SecItem) AS DECIMAL(10,2)) from (
			select FacilityID,BlueBinResourceID,DATEDIFF(s,StartTime,StopTime) as SecItem 
			from bluebin.TimeStudyNodeService 
			where  TimeStudyProcessID in (Select ConfigID from bluebin.Config where ConfigName = 'Node Service' and ConfigValue in ('Returns bin time'))
			and MostRecent = 0
			and SKUS > @ReturnsBinTH) as b
			group by FacilityID,BlueBinResourceID
		) as c 
		right join bluebin.BlueBinResource df on c.BlueBinResourceID = df.BlueBinResourceID
		 
		group by c.FacilityID,df.BlueBinResourceID,df.LastName + ', ' + df.FirstName



/* Double Bin StockOut Sweep*/

INSERT INTO @StriderActivityTimes
select 
'Double Bin StockOut Sweep' as Activity,
c.FacilityID,
c.BlueBinResourceID,
df.LastName + ', ' + df.FirstName as ResourceName,
CAST(AVG(AllSecItem) AS DECIMAL(10,2)) as AvgS,
CAST(AVG(AllSecItem)/60 AS DECIMAL(10,2)) as AvgM,
CAST(AVG(AllSecItem)/360 AS DECIMAL(10,2)) as AvgH,
convert(Date,getdate()) as LastUpdated
from (
		select FacilityID,BlueBinResourceID,CAST(AVG(SecItem) AS DECIMAL(10,2)) as AllSecItem from (
			select FacilityID,BlueBinResourceID,DATEDIFF(s,StartTime,StopTime)/SKUS as SecItem 
			from bluebin.TimeStudyStockOut 
			where TimeStudyProcessID in (Select ConfigID from bluebin.Config where ConfigName = 'Double Bin StockOut' 
			and ConfigValue in ('Write down Item numbers and sweep Stage')) 
			and MostRecent = 1) as a
			group by FacilityID,BlueBinResourceID
		UNION 
		select FacilityID,BlueBinResourceID,CAST(AVG(SecItem) AS DECIMAL(10,2)) from (
			select FacilityID,BlueBinResourceID,DATEDIFF(s,StartTime,StopTime)/SKUS as SecItem 
			from bluebin.TimeStudyStockOut 
			where  TimeStudyProcessID in (Select ConfigID from bluebin.Config where ConfigName = 'Double Bin StockOut' 
			and ConfigValue in ('Write down Item numbers and sweep Stage'))
			and MostRecent = 0) as b
			group by FacilityID,BlueBinResourceID
		) as c 
		inner join bluebin.BlueBinResource df on c.BlueBinResourceID = df.BlueBinResourceID 
		group by c.FacilityID,c.BlueBinResourceID,df.LastName + ', ' + df.FirstName

/* Double Bin StockOut Key out */

INSERT INTO @StriderActivityTimes
select 
'Double Bin StockOut Key out' as Activity,
c.FacilityID,
c.BlueBinResourceID,
df.LastName + ', ' + df.FirstName as ResourceName,
CAST(AVG(AllSecItem) AS DECIMAL(10,2)) as AvgS,
CAST(AVG(AllSecItem)/60 AS DECIMAL(10,2)) as AvgM,
CAST(AVG(AllSecItem)/360 AS DECIMAL(10,2)) as AvgH,
convert(Date,getdate()) as LastUpdated
from (
		select FacilityID,BlueBinResourceID,CAST(AVG(SecItem) AS DECIMAL(10,2)) as AllSecItem from (
			select FacilityID,BlueBinResourceID,DATEDIFF(s,StartTime,StopTime)/SKUS as SecItem 
			from bluebin.TimeStudyStockOut 
			where TimeStudyProcessID in (Select ConfigID from bluebin.Config where ConfigName = 'Double Bin StockOut' 
			and ConfigValue in ('Key out MSR')) 
			and MostRecent = 1) as a
			group by FacilityID,BlueBinResourceID
		UNION 
		select FacilityID,BlueBinResourceID,CAST(AVG(SecItem) AS DECIMAL(10,2)) from (
			select FacilityID,BlueBinResourceID,DATEDIFF(s,StartTime,StopTime)/SKUS as SecItem 
			from bluebin.TimeStudyStockOut 
			where  TimeStudyProcessID in (Select ConfigID from bluebin.Config where ConfigName = 'Double Bin StockOut' 
			and ConfigValue in ('Key out MSR'))
			and MostRecent = 0) as b
			group by FacilityID,BlueBinResourceID
		) as c 
		inner join bluebin.BlueBinResource df on c.BlueBinResourceID = df.BlueBinResourceID 
		group by c.FacilityID,c.BlueBinResourceID,df.LastName + ', ' + df.FirstName


/* Double Bin StockOut Pick Items */

INSERT INTO @StriderActivityTimes
select 
'Double Bin StockOut Pick Items' as Activity,
c.FacilityID,
c.BlueBinResourceID,
df.LastName + ', ' + df.FirstName as ResourceName,
CAST(AVG(AllSecItem) AS DECIMAL(10,2)) as AvgS,
CAST(AVG(AllSecItem)/60 AS DECIMAL(10,2)) as AvgM,
CAST(AVG(AllSecItem)/360 AS DECIMAL(10,2)) as AvgH,
convert(Date,getdate()) as LastUpdated
from (
		select FacilityID,BlueBinResourceID,CAST(AVG(SecItem) AS DECIMAL(10,2)) as AllSecItem from (
			select FacilityID,BlueBinResourceID,DATEDIFF(s,StartTime,StopTime)/SKUS as SecItem 
			from bluebin.TimeStudyStockOut 
			where TimeStudyProcessID in (Select ConfigID from bluebin.Config where ConfigName = 'Double Bin StockOut' 
			and ConfigValue in ('Pick Items')) 
			and MostRecent = 1) as a
			group by FacilityID,BlueBinResourceID
		UNION 
		select FacilityID,BlueBinResourceID,CAST(AVG(SecItem) AS DECIMAL(10,2)) from (
			select FacilityID,BlueBinResourceID,DATEDIFF(s,StartTime,StopTime)/SKUS as SecItem 
			from bluebin.TimeStudyStockOut 
			where  TimeStudyProcessID in (Select ConfigID from bluebin.Config where ConfigName = 'Double Bin StockOut' 
			and ConfigValue in ('Pick Items'))
			and MostRecent = 0) as b
			group by FacilityID,BlueBinResourceID
		) as c 
		inner join bluebin.BlueBinResource df on c.BlueBinResourceID = df.BlueBinResourceID 
		group by c.FacilityID,c.BlueBinResourceID,df.LastName + ', ' + df.FirstName


/* Double Bin StockOut Deliver Items */

INSERT INTO @StriderActivityTimes
select 
'Double Bin StockOut Deliver Items' as Activity,
c.FacilityID,
c.BlueBinResourceID,
df.LastName + ', ' + df.FirstName as ResourceName,
CAST(AVG(AllSecItem) AS DECIMAL(10,2)) as AvgS,
CAST(AVG(AllSecItem)/60 AS DECIMAL(10,2)) as AvgM,
CAST(AVG(AllSecItem)/360 AS DECIMAL(10,2)) as AvgH,
convert(Date,getdate()) as LastUpdated
from (
		select FacilityID,BlueBinResourceID,CAST(AVG(SecItem) AS DECIMAL(10,2)) as AllSecItem from (
			select FacilityID,BlueBinResourceID,DATEDIFF(s,StartTime,StopTime)/SKUS as SecItem 
			from bluebin.TimeStudyStockOut 
			where TimeStudyProcessID in (Select ConfigID from bluebin.Config where ConfigName = 'Double Bin StockOut' 
			and ConfigValue in ('Deliver Items')) 
			and MostRecent = 1
			) as a
			group by FacilityID,BlueBinResourceID
		UNION 
		select FacilityID,BlueBinResourceID,CAST(AVG(SecItem) AS DECIMAL(10,2)) from (
			select FacilityID,BlueBinResourceID,DATEDIFF(s,StartTime,StopTime)/SKUS as SecItem 
			from bluebin.TimeStudyStockOut 
			where  TimeStudyProcessID in (Select ConfigID from bluebin.Config where ConfigName = 'Double Bin StockOut' 
			and ConfigValue in ('Deliver Items'))
			and MostRecent = 0) as b
			group by FacilityID,BlueBinResourceID
		) as c 
		inner join bluebin.BlueBinResource df on c.BlueBinResourceID = df.BlueBinResourceID 
		group by c.FacilityID,c.BlueBinResourceID,df.LastName + ', ' + df.FirstName
/* Double Bin StockOut All */

INSERT INTO @StriderActivityTimes
select 
'Double Bin StockOut All' as Activity,
FacilityID,
BlueBinResourceID,
ResourceName,
SUM(AvgS) as AvgS,
SUM(AvgM) as AvgS,
SUM(AvgH) as AvgS,
convert(Date,getdate()) as LastUpdated
from @StriderActivityTimes
where Activity like 'Double Bin%'
group by
FacilityID,
BlueBinResourceID,
ResourceName

select 
sat.Activity,
sat.FacilityID,
df.FacilityName,
sat.BlueBinResourceID,
sat.ResourceName,
sat.AvgS as ResourceAvgS,
fat.AvgS as OverallAvgS,
sat.AvgS - fat.AvgS as DifferenceAvgS,

sat.AvgM as ResourceAvgM,
fat.AvgM as OverallAvgM,
sat.AvgM - fat.AvgM as DifferenceAvgM,

sat.AvgH as ResourceAvgH,
fat.AvgH as OverallAvgH,
sat.AvgH - fat.AvgH as DifferenceAvgH,
sat.LastUpdated
 
from @StriderActivityTimes sat
inner join bluebin.FactActivityTimes fat on sat.Activity = fat.Activity and sat.FacilityID = fat.FacilityID
inner join bluebin.DimFacility df on sat.FacilityID = df.FacilityID
where sat.AvgS is not null
order by sat.ResourceName,fat.Activity

END
GO

grant exec on tb_TimeStudyStrider to public
GO


--*********************************************************************************************
--Tableau Sproc  These load data into the datasources for Tableau
--*********************************************************************************************

IF EXISTS ( SELECT  *
            FROM    sys.objects
            WHERE   object_id = OBJECT_ID(N'tb_TimeStudyAverages')
                    AND type IN ( N'P', N'PC' ) ) 

--exec tb_TimeStudyAverages
DROP PROCEDURE  tb_TimeStudyAverages
GO

CREATE PROCEDURE tb_TimeStudyAverages

AS
BEGIN
SET NOCOUNT ON

declare @TodaysOrders TABLE ([Date] datetime,FacilityID int,FacilityName varchar(50),LocationID varchar(10),LocationName varchar(50),TodaysLines int)
declare @TodaysPicks TABLE ([Date] datetime,FacilityID int,FacilityName varchar(50),LocationID varchar(10),LocationName varchar(50),Picks int)
declare @StockOuts TABLE ([Date] datetime,FacilityID int,FacilityName varchar(50),LocationID varchar(10),LocationName varchar(50),StockOuts int)
declare @Groups TABLE (FacilityID int,LocationID varchar(10),GroupName varchar(50))
/*
--Alternate Todays Orders based on sproc and FactScan
declare @TodaysOrders TABLE ([Date] datetime,FacilityID int,FacilityName varchar(50),LocationID varchar(10),LocationName varchar(50),TodaysLines int,YesLines int,Trend varchar(10))
insert into @TodaysOrders
EXEC tb_TodaysOrders
*/
/* Todays Orders Table */
insert into @TodaysOrders
--EXEC tb_TodaysOrders
select
[Date],
FacilityID,
FacilityName,
LocationID,
LocationName,
ISNULL(SUM(Scan),0) as TodaysLines 
from tableau.Kanban
where [Date] = (select max(Date) from tableau.Kanban where Scan = 1) 
group by 
[Date],
FacilityID,
FacilityName,
LocationID,
LocationName


/* Todays Picks Table */
insert into @TodaysPicks
select
[Date],
FacilityID,
FacilityName,
LocationID,
LocationName,
ISNULL(SUM(Scan),0) as Picks  
from tableau.Kanban
where [Date] = (select max(Date) from tableau.Kanban where Scan = 1) and ItemType in ('I','MSR')
group by 
[Date],
FacilityID,
FacilityName,
LocationID,
LocationName



/* Todays StockOuts Table */
insert into @StockOuts
select
[Date],
FacilityID,
FacilityName,
LocationID,
LocationName,
ISNULL(SUM(StockOut),0) as StockOuts  
from tableau.Kanban
where [Date] = (select max(Date) from tableau.Kanban where Scan = 1)
group by 
[Date],
FacilityID,
FacilityName,
LocationID,
LocationName

/* Todays StockOuts Table */
insert into @Groups
select
FacilityID,
LocationID,
GroupName 
from bluebin.TimeStudyGroup


/*
--Parameter based entries that were based on no FacilityID
Declare @BinFill DECIMAL(10,2) = (select FacilityID,AvgM from bluebin.FactActivityTimes where Activity = 'Bin Fill')
Declare @NodeService DECIMAL(10,2) = (select FacilityID,AvgM from bluebin.FactActivityTimes where Activity = 'NodeService')
Declare @TravelTimeAll DECIMAL(10,2) = (select FacilityID,AvgM from bluebin.FactActivityTimes where Activity = 'TravelTimeAll')
Declare @ScanningBin DECIMAL(10,2) = (select FacilityID,AvgM from bluebin.FactActivityTimes where Activity = 'Scanning Bin')
Declare @ReturnsBinsSmall DECIMAL(10,2) = (select FacilityID,AvgM from bluebin.FactActivityTimes where Activity = 'Returns Bins Small')
Declare @ReturnsBinsLarge DECIMAL(10,2) = (select FacilityID,AvgM from bluebin.FactActivityTimes where Activity = 'Returns Bins Large')
Declare @DoubleBinStockOutAll DECIMAL(10,2) = (select FacilityID,AvgM from bluebin.FactActivityTimes where Activity = 'Double Bin StockOut All')
Declare @ScanningTime DECIMAL(10,2) = (select FacilityID,AvgM from bluebin.FactActivityTimes where Activity = 'Scanning Time')
Declare @ScanningNew DECIMAL(10,2) = (select FacilityID,AvgM from bluebin.FactActivityTimes where Activity = 'Scanning New')
Declare @ScanningMove DECIMAL(10,2) = (select FacilityID,AvgM from bluebin.FactActivityTimes where Activity = 'Scanning Move')
Declare @StoreroomPickLines DECIMAL(10,2) = (select FacilityID,AvgM from bluebin.FactActivityTimes where Activity = 'Storeroom Pick Lines')
*/
declare @ReturnsBinTH DECIMAL(10,2) = (select max(ConfigValue) from bluebin.Config where ConfigName = 'Returns Bins Threshhold')--default is Bin #s

select 
*
,case when TodaysLines = 0 then 0 else (BinFill + TravelTime + NodeService + ReturnsBins + StockOutTime + Scanning + PickTime) end as TotalTimeM
,case when TodaysLines = 0 then 0 else (BinFill + TravelTime + NodeService + ReturnsBins + StockOutTime + Scanning + PickTime)/60 end  as TotalTimeH
from 
(
select 
t.[Date],
t.FacilityID,
t.FacilityName,
t.LocationID,
t.LocationName,
ISNULL(g.GroupName,'None') as GroupName,
ISNULL(t.TodaysLines,0) as TodaysLines,
ISNULL(t.TodaysLines * (select AvgM from bluebin.FactActivityTimes where Activity = 'Bin Fill' and FacilityID = t.FacilityID),0) as BinFill,
ISNULL((select AvgM from bluebin.FactActivityTimes where Activity = 'TravelTimeAll' and FacilityID = t.FacilityID),0)  as TravelTime,
ISNULL(t.TodaysLines * (select AvgM from bluebin.FactActivityTimes where Activity = 'NodeService' and FacilityID = t.FacilityID),0)  as NodeService,
case when t.TodaysLines > @ReturnsBinTH then ISNULL((select AvgM from bluebin.FactActivityTimes where Activity = 'Returns Bins Large' and FacilityID = t.FacilityID),0)  else ISNULL((select AvgM from bluebin.FactActivityTimes where Activity = 'Returns Bins Small' and FacilityID = t.FacilityID),0) end as ReturnsBins,
ISNULL(s.StockOuts,0) as StockOuts,
ISNULL(s.StockOuts * (select AvgM from bluebin.FactActivityTimes where Activity = 'Double Bin StockOut All' and FacilityID = t.FacilityID),0) as StockOutTime,
ISNULL((t.TodaysLines * (select AvgM from bluebin.FactActivityTimes where Activity = 'Scanning Bin' and FacilityID = t.FacilityID))+ (select AvgM from bluebin.FactActivityTimes where Activity = 'Scanning Move' and FacilityID = t.FacilityID),0) as Scanning,
ISNULL(p.Picks,0) as StoreroomPickLines,
ISNULL(p.Picks,0) * (select AvgM from bluebin.FactActivityTimes where Activity = 'Storeroom Pick Lines' and FacilityID = t.FacilityID) as PickTime

from @TodaysOrders t
left join @TodaysPicks p on t.FacilityID = p.FacilityID and t.LocationID = p.LocationID
left join @StockOuts s on t.FacilityID = s.FacilityID and t.LocationID = s.LocationID
left join @Groups g on t.FacilityID = g.FacilityID and t.LocationID = g.LocationID
--left join bluebin.FactActivityTimes fat on t.FacilityID = fat.FacilityID
) as  a

order by FacilityID,LocationID

END
GO

grant exec on tb_TimeStudyAverages to public
GO

--*********************************************************************************************
--Tableau Sproc  These load data into the datasources for Tableau
--*********************************************************************************************
--Updated GB 20180307 Altered Facility pulling based on multiple facilities

if exists (select * from dbo.sysobjects where id = object_id(N'tb_StatCallsDetail') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure tb_StatCallsDetail
GO


--exec tb_StatCallsDetail
CREATE PROCEDURE [dbo].[tb_StatCallsDetail]
AS
BEGIN
SET NOCOUNT ON

declare @Facility int = (select ConfigValue from bluebin.Config where ConfigName = 'PS_DefaultFacility')
declare @FacilityName varchar(30) = (select PSFacilityName from bluebin.DimFacility where FacilityID = @Facility)


SELECT
--case when @Facility is not null or @Facility <> '' then @Facility else ''end as FROM_TO_CMPY,
--case when @Facility is not null or @Facility <> '' then (select FacilityName from bluebin.DimFacility where FacilityID = @Facility) else ''end as FacilityName,
COALESCE(df.FacilityID,@Facility) as FROM_TO_CMPY,
COALESCE(df.PSFacilityName,@FacilityName) as FacilityName,
lt.LOCATION as LocationID,
lt.DESCR as LocationName,
INV_ITEM_ID as ItemID,
ORDER_NO as OrderNo,
DEMAND_DATE  AS [Date],
ORDER_INT_LINE_NO as LINE_NBR,
SUM((QTY_REQUESTED*-1)) as QUANTITY,
--QTY_REQUESTED as QUANTITY,
    'N/A' as Department,
case when ISNULL(dl.BlueBinFlag,0) = 1 then 'Yes' else 'No' end as BlueBinFlag,
case	when ISNULL(dl.BlueBinFlag,0) = 0 
		then case	when INV_ITEM_ID is null or INV_ITEM_ID = '' 
					then 'Not Managed Special' 
					else 'Not Managed Standard' end
		else 'Managed' end as Category,
0 as Cost,	--Need
case when ORDER_NO LIKE 'MSR%' then 'Yes' else 'No' end as WHSource


FROM   IN_DEMAND
       INNER JOIN LOCATION_TBL lt on IN_DEMAND.LOCATION = lt.LOCATION
	   LEFT JOIN bluebin.DimLocation dl ON lt.LOCATION = dl.LocationID
	   LEFT JOIN bluebin.DimFacility df on IN_DEMAND.BUSINESS_UNIT= df.FacilityName

WHERE  PICK_BATCH_ID = 0
       --AND BUSINESS_UNIT in (Select ConfigValue from bluebin.Config where ConfigName = 'PS_BUSINESSUNIT')
	   AND (BUSINESS_UNIT in (Select ConfigValue from bluebin.Config where ConfigName = 'PS_BUSINESSUNITSTAT') or SOURCE_BUS_UNIT in (Select ConfigValue from bluebin.Config where ConfigName = 'PS_BUSINESSUNIT'))
	   AND (IN_FULFILL_STATE in (select ConfigValue from bluebin.Config where ConfigName = 'PS_InFulfillState') or IN_FULFILL_STATE is null)
	   and DEMAND_DATE > getdate() -90
		--AND dl.BlueBinFlag = 1
Group by
df.FacilityID,
df.PSFacilityName,
lt.LOCATION,
lt.DESCR,
INV_ITEM_ID,
ORDER_NO,
DEMAND_DATE,
ORDER_INT_LINE_NO,
ISNULL(dl.BlueBinFlag,0)
Order by DEMAND_DATE,ORDER_NO,ORDER_INT_LINE_NO


END

GO
grant exec on tb_StatCallsDetail to public
GO

--*********************************************************************************************
--Tableau Sproc  These load data into the datasources for Tableau
--*********************************************************************************************
--Updated GB 20180307 Altered Facility pulling based on multiple facilities

if exists (select * from dbo.sysobjects where id = object_id(N'tb_StatCallsLocation') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure tb_StatCallsLocation
GO

--exec tb_StatCallsLocation
CREATE PROCEDURE tb_StatCallsLocation
AS
BEGIN
SET NOCOUNT ON

declare @Facility int = (select ConfigValue from bluebin.Config where ConfigName = 'PS_DefaultFacility')
declare @FacilityName varchar(30) = (select PSFacilityName from bluebin.DimFacility where FacilityID = @Facility)

SELECT 
--case when @Facility is not null or @Facility <> '' then @Facility else ''end as FROM_TO_CMPY,
--case when @Facility is not null or @Facility <> '' then (select FacilityName from bluebin.DimFacility where FacilityID = @Facility) else ''end as FacilityName,
COALESCE(df.FacilityID,@Facility) as FROM_TO_CMPY,
COALESCE(df.PSFacilityName,@FacilityName) as FacilityName,
lt.LOCATION as LocationID,
lt.DESCR as LocationName,
ISNULL(dl.BlueBinFlag,0) as BlueBinFlag,
DEMAND_DATE       AS [Date],
COUNT(*) as StatCalls,
'' as Department,
'No' as WHSource

FROM   dbo.IN_DEMAND
       INNER JOIN dbo.LOCATION_TBL lt on IN_DEMAND.LOCATION = lt.LOCATION
	   LEFT JOIN bluebin.DimLocation dl ON lt.LOCATION = dl.LocationID
	   LEFT JOIN bluebin.DimFacility df on IN_DEMAND.BUSINESS_UNIT= df.FacilityName

WHERE  PICK_BATCH_ID = 0
       --AND BUSINESS_UNIT in (Select ConfigValue from bluebin.Config where ConfigName = 'PS_BUSINESSUNIT')
	   AND (BUSINESS_UNIT in (Select ConfigValue from bluebin.Config where ConfigName = 'PS_BUSINESSUNITSTAT') or SOURCE_BUS_UNIT in (Select ConfigValue from bluebin.Config where ConfigName = 'PS_BUSINESSUNIT'))
	   AND (IN_FULFILL_STATE in (select ConfigValue from bluebin.Config where ConfigName = 'PS_InFulfillState') or IN_FULFILL_STATE is null)
GROUP BY
--DimLocation.LocationID,
--DimLocation.LocationName,
df.FacilityID,
df.PSFacilityName,
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
			) c on a.MonthEnd = c.Date and a.FacilityName COLLATE DATABASE_DEFAULT = c.FacilityName COLLATE DATABASE_DEFAULT and a.LocationID COLLATE DATABASE_DEFAULT = c.LocationID COLLATE DATABASE_DEFAULT
order by a.Date desc       



END
GO
grant exec on tb_WarehouseHistory to public
GO

--*********************************************************************************************
--Tableau Sproc  These load data into the datasources for Tableau
--*********************************************************************************************

if exists (select * from dbo.sysobjects where id = object_id(N'tb_SupplyStandards') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure tb_SupplyStandards
GO

--exec tb_SupplyStandards


CREATE PROCEDURE tb_SupplyStandards

--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON

;



select 
'' as FacilityID,
'' as FacilityName,
'' as PONumber,
'' as AcctUnit,
'' as AcctUnitName,
'' as ItemID,
'' as ItemClinicalDescription,
'' as Category,
'' as POAmt,
'' as POs



END
GO
grant exec on tb_SupplyStandards to public
GO



--*********************************************************************************************
--Tableau Sproc  These load data into the datasources for Tableau
--*********************************************************************************************

IF EXISTS ( SELECT  *
            FROM    sys.objects
            WHERE   object_id = OBJECT_ID(N'tb_OldParValuation')
                    AND type IN ( N'P', N'PC' ) ) 

--exec tb_OldParValuation
DROP PROCEDURE  tb_OldParValuation
GO

CREATE PROCEDURE tb_OldParValuation

AS

/*
select top 100* from bluebin.HistoricalDimBin
select top 100* from bluebin.DimBin
select * from bluebin.HistoricalDimBinJoin
*/

With A as
(
select 
COALESCE(i.FacilityID,i2.FacilityID,NULL) as FacilityID,
--NEW
case when i.NewLocationID is NULL then i2.NewLocationID else ISNULL(i.NewLocationID,'') end as NewLocationID,
case when i.NewLocationName is NULL then i2.NewLocationName else ISNULL(i.NewLocationName,'') end as NewLocationName,
ISNULL(i.ItemID,'') as NewItem,
(ISNULL(i.BinQty,0)*2)*ISNULL(i.AvgCost,0) as NewCost,
--OLD
case when i2.OldLocationID is NULL then i.OldLocationID else ISNULL(i2.OldLocationID,'') end as OldLocationID,
case when i2.OldLocationName is NULL then i.OldLocationName else ISNULL(i2.OldLocationName,'') end as OldLocationName,
ISNULL(i2.ItemID,'') as OldItem,
(ISNULL(i2.BinQty,0)*2)*ISNULL(i2.AvgCost,0) as OldCost,

--Generic counter/Identifiers
ISNULL(i2.OldCt,0) as OldCt,
ISNULL(i.NewCt,0) as NewCt,
case when i.ItemID is null and i2.ItemID is not null then 1 else 0 end as RemovedCt,
case when i2.ItemID is null and i.ItemID is not null then 1 else 0 end as AddedCt,
case when i.ItemID is not null and i2.ItemID is not null then 1 else 0 end as StayedCt




from		(
			select i.BinFacility as FacilityID,i.LocationID as NewLocationID,lj.NewLocationName,i.ItemID,i.BinQty,i.BinUOM,
			--p.AvgCost,
			ISNULL(i.BinCurrentCost,0) as BinCurrentCost,
			case when ISNULL(p.AvgCost,0) = 0 then ISNULL(i.BinCurrentCost,0) else ISNULL(p.AvgCost,0) end as AvgCost,
			lj.OldLocationID,lj.OldLocationName,1 as NewCt 
			from bluebin.DimBin i
			left join (
						select Company,PurchaseLocation,ItemNumber,BuyUOM,Avg(UnitCost) AvgCost from tableau.Sourcing
						where PurchaseLocation is not null
						group by Company,PurchaseLocation,ItemNumber,BuyUOM) p on i.BinFacility = p.Company and i.LocationID = p.PurchaseLocation and i.ItemID = p.ItemNumber and i.BinUOM = p.BuyUOM
			right join (select hdbj.*,dl.LocationName as NewLocationName from bluebin.HistoricalDimBinJoin hdbj left join bluebin.DimLocation dl on hdbj.NewLocationID = dl.LocationID) lj on i.LocationID = lj.NewLocationID
			) i
full outer join 
			( 
			select i.FacilityID,i.LocationID as OldLocationID,lj.OldLocationName,i.ItemID,i.BinUOM,
			--p.AvgCost,
			ISNULL(i.BinCurrentCost,0) as BinCurrentCost,
			case when ISNULL(p.AvgCost,0) = 0 then ISNULL(i.BinCurrentCost,0) else ISNULL(p.AvgCost,0) end as AvgCost,
			i.BinQty,lj.NewLocationID,lj.NewLocationName,1 as OldCt 
			from bluebin.HistoricalDimBin i 
			left join (
						select Company,PurchaseLocation,ItemNumber,BuyUOM,Avg(UnitCost) AvgCost from tableau.Sourcing
						where PurchaseLocation is not null
						group by Company,PurchaseLocation,ItemNumber,BuyUOM) p on i.FacilityID = p.Company and i.LocationID = p.PurchaseLocation and i.ItemID  = p.ItemNumber and i.BinUOM = p.BuyUOM
			right join (select hdbj.*,dl.LocationName as NewLocationName from bluebin.HistoricalDimBinJoin hdbj left join bluebin.DimLocation dl on hdbj.NewLocationID = dl.LocationID) lj on i.LocationID = lj.OldLocationID
			) i2 on i.NewLocationID = i2.NewLocationID and i.ItemID = i2.ItemID

)


select 
A.FacilityID,
df.FacilityName,
A.NewLocationID,
A.NewLocationName,
A.OldLocationID,
A.OldLocationName as OldNodeHeader,
sum(A.NewCt) as NewCt,
sum(A.NewCt*A.NewCost) as NewCost,

sum(A.OldCt) as OldCt,
sum(A.OldCt*A.OldCost) as OldCost,

sum(A.RemovedCt) as RemovedCt,
sum(A.RemovedCt*A.OldCost) as RemovedCost,

sum(A.AddedCt) as AddedCt,
sum(A.AddedCt*A.NewCost) as AddedCost,

sum(A.StayedCt) as StayedCt,
sum(A.StayedCt*A.NewCost) as StayedCost

from A
inner join bluebin.DimFacility df on A.FacilityID = df.FacilityID
group by 
A.FacilityID,
df.FacilityName,
A.NewLocationID,
A.NewLocationName,
A.OldLocationID,
A.OldLocationName

order by 1



GO

grant exec on tb_OldParValuation to public
GO

--*********************************************************************************************
--Tableau Sproc  These load data into the datasources for Tableau
--*********************************************************************************************
--Updated GB 20180320  Updated the logic to show a Cart
--Updated GB 20180307  Updated the INV_ITEM_ID pull to r and changd Facility Pull for multiple

IF EXISTS ( SELECT  *
            FROM    sys.objects
            WHERE   object_id = OBJECT_ID(N'tb_BinSequence')
                    AND type IN ( N'P', N'PC' ) ) 

--exec tb_BinSequence
DROP PROCEDURE  tb_BinSequence
GO

CREATE PROCEDURE tb_BinSequence

AS

BEGIN

;

/*
select * from REQ_LINE_SHIP where REQ_ID = '0000089501' order by LINE_NBR
select * from PO_LINE_DISTRIB where REQ_ID like '%89501%' order by LINE_NBR
select * from REQ_LN_DISTRIB where REQ_ID like '%89501%' order by LINE_NBR
*/
SET NOCOUNT ON


;

declare @Facility int = (select ConfigValue from bluebin.Config where ConfigName = 'PS_DefaultFacility')
declare @FacilityName varchar(30) = (select PSFacilityName from bluebin.DimFacility where FacilityID = @Facility)
;
WITH A as
(
select 
Row_number()
         OVER(
           Partition BY db.BinKey
           ORDER BY p.CREATION_DATE ASC,p.REQ_NUMBER,p.LINE_NBR) AS Scanseq,
		   --ORDER BY p.REC_ACT_DATE ASC,p.PO_NUMBER,p.LINE_NBR) AS Scanseq,
p.COMPANY as FacilityID,
df.FacilityName,
p.REQ_LOCATION as LocationID,
dl.LocationName,
p.ITEM as ItemID,
di.ItemDescription,
db.BinSequence,
db.BinKey,
p.CREATION_DATE as OrderDate,
p.REQ_NUMBER as OrderNum,
--p.REC_ACT_DATE as OrderDate,
--p.PO_NUMBER as OrderNum,
p.LINE_NBR as OrderLineNum,
p.QUANTITY as OrderQty,
p.CUSTOM_C1_C as OrderSequence

from 
(select COALESCE(df.FacilityID,@Facility) as COMPANY, 
		r.INV_ITEM_ID as ITEM,
		rs.REQ_DT AS CREATION_DATE,
		rs.REQ_ID as REQ_NUMBER,
		rs.LINE_NBR,
		'' as QUANTITY,
		rs.CUSTOM_C1_C,
		po.LOCATION as REQ_LOCATION 
		from REQ_LINE_SHIP rs
		inner join REQ_LN_DISTRIB po on right(('0000000000' + po.REQ_ID),10) = rs.REQ_ID and po.LINE_NBR = rs.LINE_NBR and po.BUSINESS_UNIT = rs.BUSINESS_UNIT
		left join REQ_LINE r on right(('0000000000' + r.REQ_ID),10) = rs.REQ_ID and r.LINE_NBR = rs.LINE_NBR and r.BUSINESS_UNIT = rs.BUSINESS_UNIT
		left join bluebin.DimFacility df on rs.BUSINESS_UNIT = df.FacilityName 
			where CUSTOM_C1_C in ('A','B')) p
			
--(select p.COMPANY, p.ITEM,p.REC_ACT_DATE,p.PO_NUMBER,p.LINE_NBR,p.QUANTITY,p.PO_USER_FLD_4,posrc.REQ_LOCATION 
--		from POLINE p 
--			inner join POLINESRC posrc on p.PO_NUMBER = posrc.PO_NUMBER and p.LINE_NBR = posrc.LINE_NBR 
--			where p.PO_USER_FLD_4 in ('A','B')) p
inner join bluebin.DimBin db on p.COMPANY = db.BinFacility and p.REQ_LOCATION = db.LocationID and p.ITEM = db.ItemID
inner join bluebin.DimFacility df on db.BinFacility = df.FacilityID 
inner join bluebin.DimLocation dl on db.LocationID = dl.LocationID
inner join bluebin.DimItem di on db.ItemID = di.ItemID

where CUSTOM_C1_C in ('A','B') --and QUANTITY <> CXL_QTY
and p.CREATION_DATE > getdate() -90
--and p.REC_ACT_DATE > getdate() -90
group by
p.COMPANY,
df.FacilityName,
p.REQ_LOCATION ,
dl.LocationName,
p.ITEM,
di.ItemDescription,
db.BinSequence,
db.BinKey,
p.CREATION_DATE,
p.REQ_NUMBER,

p.LINE_NBR,
p.QUANTITY,
p.CUSTOM_C1_C
)

select 
IDENTITY (INT, 1, 1) AS RecID, 
A.*,
CASE WHEN A.Scanseq = '1' THEN 'N/A' ELSE
	CASE WHEN A.OrderSequence = b.OrderSequence THEN 'No' ELSE 'Yes' END END AS InSequence,

CASE 
   WHEN A.Scanseq = '1' THEN 0  -- 'N/A' 
ELSE
	CASE 
	   WHEN A.OrderSequence = b.OrderSequence THEN 1  -- 'No' 
	ELSE 0  -- 'Yes' 
	END 
END AS OutOfSequenceValue,
0 AS OutofSequenceCount,

CASE
      WHEN A.BinSequence LIKE '%CD' 
		or A.BinSequence LIKE '%CO'  
		or A.BinSequence LIKE '%CS'  
		or A.BinSequence LIKE '%CF' 
		or A.BinSequence LIKE '%CP' 
		or A.BinSequence LIKE '%CR' THEN 'Card'
   ELSE 'Bin'
END AS BinOrCard 

into #temp01

from A
left join A b on A.BinKey = b.BinKey and A.Scanseq = b.Scanseq+1
-- order by 
-- A.BinKey,A.Scanseq

ALTER TABLE #temp01
ADD OutofSequenceRecentDate DATETIME

UPDATE
   t1
SET
   OutofSequenceCount = t2.OutofSequenceCount
FROM
   #temp01 t1
      INNER JOIN 
         (SELECT ItemID, OrderDate, SUM(OutofSequenceValue) AS 'OutofSequenceCount' 
		  FROM #temp01 
		  GROUP BY ItemID, OrderDate
		 ) AS t2
ON 
   t1.ItemID = t2.ItemID AND
   t1.OrderDate = t2.OrderDate 
WHERE
   t1.RecID IN 
(SELECT
   c.RecID
 FROM
    (SELECT ItemID, OrderDate, MAX(RecID) AS 'RecID' 
	 FROM #temp01 
	 WHERE OutOfSequenceValue = 1
	 GROUP BY ItemID, OrderDate
    ) AS c
)

UPDATE
   t1
SET
   OutofSequenceRecentDate = t2.OrderDate
FROM
   #temp01 t1
      INNER JOIN (SELECT ItemID, LocationID, MAX(OrderDate) AS 'OrderDate' 
	              FROM #temp01 
				  WHERE OutOfSequenceValue = 1
				  GROUP BY ItemID, LocationID
				 ) AS t2
         ON
            t1.ItemID = t2.ItemID AND
            t1.LocationID = t2.LocationID 
WHERE
   t1.RecID IN 
(SELECT
   c.RecID
 FROM
    (SELECT ItemID, LocationID, MAX(RecID) AS 'RecID' 
	 FROM #temp01 
	 WHERE OutOfSequenceValue = 1
	 GROUP BY ItemID, LocationID
    ) AS c
)

   

SELECT *  FROM #temp01 
-- where itemid = 1640 and OrderDate = '5/23/17'
-- order by itemid, OrderDate

--where itemid = '5014552' 
-- order by itemid, LocationID
ORDER BY BinKey, Scanseq

DROP TABLE #temp01

END

GO

grant exec on tb_BinSequence to public
GO





--*****************************************************
--**************************SPROC**********************

if exists (select * from dbo.sysobjects where id = object_id(N'sp_CleanPeoplesoftStageTables') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_CleanPeoplesoftStageTables
GO

--exec sp_CleanPeoplesoftStageTables

CREATE PROCEDURE sp_CleanPeoplesoftStageTables
--WITH ENCRYPTION
AS
BEGIN


--*****************Remove Stage Tables Data**************************
if exists (select * from sys.tables where name = 'REQ_LINE_SHIPstage')
BEGIN
truncate table dbo.REQ_LINE_SHIPstage
END



if exists (select * from sys.tables where name = 'BRAND_NAMES_INVstage')
BEGIN
truncate table dbo.BRAND_NAMES_INVstage
END

if exists (select * from sys.tables where name = 'BU_ATTRIB_INVstage')
BEGIN
truncate table dbo.BU_ATTRIB_INVstage
END

if exists (select * from sys.tables where name = 'BU_ITEMS_INVstage')
BEGIN
truncate table dbo.BU_ITEMS_INVstage
END

if exists (select * from sys.tables where name = 'CART_ATTRIB_INVstage')
BEGIN
truncate table dbo.CART_ATTRIB_INVstage
END

if exists (select * from sys.tables where name = 'CART_CT_INF_INVstage')
BEGIN
truncate table dbo.CART_CT_INF_INVstage
END

if exists (select * from sys.tables where name = 'DEMAND_INF_INVstage')
BEGIN
truncate table dbo.DEMAND_INF_INVstage
END

if exists (select * from sys.tables where name = 'CART_TEMPL_INVstage')
BEGIN
truncate table dbo.CART_TEMPL_INVstage
END

if exists (select * from sys.tables where name = 'IN_DEMANDstage')
BEGIN
truncate table dbo.IN_DEMANDstage
END

if exists (select * from sys.tables where name = 'ITEM_MFGstage')
BEGIN
truncate table dbo.ITEM_MFGstage
END

if exists (select * from sys.tables where name = 'ITM_VENDORstage')
BEGIN
truncate table dbo.ITM_VENDORstage
END

if exists (select * from sys.tables where name = 'LOCATION_TBLstage')
BEGIN
truncate table dbo.LOCATION_TBLstage
END

if exists (select * from sys.tables where name = 'MANUFACTURERstage')
BEGIN
truncate table dbo.MANUFACTURERstage
END

if exists (select * from sys.tables where name = 'MASTER_ITEM_TBLstage')
BEGIN
truncate table dbo.MASTER_ITEM_TBLstage
END

if exists (select * from sys.tables where name = 'PO_HDRstage')
BEGIN
truncate table dbo.PO_HDRstage
END

if exists (select * from sys.tables where name = 'PO_LINEstage')
BEGIN
truncate table dbo.PO_LINEstage
END

if exists (select * from sys.tables where name = 'PO_LINE_DISTRIBstage')
BEGIN
truncate table dbo.PO_LINE_DISTRIBstage
END

if exists (select * from sys.tables where name = 'PURCH_ITEM_ATTRstage')
BEGIN
truncate table dbo.PURCH_ITEM_ATTRstage
END

if exists (select * from sys.tables where name = 'PURCH_ITEM_BUstage')
BEGIN
truncate table dbo.PURCH_ITEM_BUstage
END

if exists (select * from sys.tables where name = 'RECV_HDRstage')
BEGIN
truncate table dbo.RECV_HDRstage
END

if exists (select * from sys.tables where name = 'RECV_LN_DISTRIBstage')
BEGIN
truncate table dbo.RECV_LN_DISTRIBstage
END

if exists (select * from sys.tables where name = 'RECV_LN_SHIPstage')
BEGIN
truncate table dbo.RECV_LN_SHIPstage
END

if exists (select * from sys.tables where name = 'REQ_HDRstage')
BEGIN
truncate table dbo.REQ_HDRstage
END

if exists (select * from sys.tables where name = 'REQ_LINEstage')
BEGIN
truncate table dbo.REQ_LINEstage
END

if exists (select * from sys.tables where name = 'REQ_LN_DISTRIBstage')
BEGIN
truncate table dbo.REQ_LN_DISTRIBstage
END

if exists (select * from sys.tables where name = 'VENDORstage')
BEGIN
truncate table dbo.VENDORstage
END


if exists (select * from sys.tables where name = 'REQ_LINE_SHIPstage')
BEGIN
truncate table dbo.REQ_LINE_SHIPstage
END

if exists (select * from sys.tables where name = 'DEPT_TBLstage')
BEGIN
truncate table dbo.DEPT_TBLstage
END

if exists (select * from sys.tables where name = 'GL_ACCOUNT_TBLstage')
BEGIN
truncate table dbo.GL_ACCOUNT_TBLstage
END

if exists (select * from sys.tables where name = 'JRNL_HEADERstage')
BEGIN
truncate table dbo.JRNL_HEADERstage
END

if exists (select * from sys.tables where name = 'JRNL_LNstage')
BEGIN
truncate table dbo.JRNL_LNstage
END

if exists (select * from sys.tables where name = 'CM_ACCTG_LINEstage')
BEGIN
truncate table dbo.CM_ACCTG_LINEstage
END

if exists (select * from sys.tables where name = 'RECV_LN_ACCTGstage')
BEGIN
truncate table dbo.RECV_LN_ACCTGstage
END

if exists (select * from sys.tables where name = 'VCHR_ACCTG_LINEstage')
BEGIN
truncate table dbo.VCHR_ACCTG_LINEstage
END


--*****************END Remove Stage Tables Data**************************




--*****************Remove Main Tables Data (Non Transactional)**************************
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

if exists (select * from sys.tables where name = 'CART_TEMPL_INV')
BEGIN
truncate table dbo.CART_TEMPL_INV
END

if exists (select * from sys.tables where name = 'CART_CT_INF_INV')
BEGIN
truncate table dbo.CART_CT_INF_INV
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

if exists (select * from sys.tables where name = 'PURCH_ITEM_BU')
BEGIN
truncate table dbo.PURCH_ITEM_BU
END

if exists (select * from sys.tables where name = 'VENDOR')
BEGIN
truncate table dbo.VENDOR
END
--*****************END Remove MainTables Data**************************

END

GO
grant exec on sp_CleanPeoplesoftStageTables to public
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

if exists (select * from sys.tables where name = 'CART_CT_INF_INV')
BEGIN
truncate table dbo.CART_CT_INF_INV
END

if exists (select * from sys.tables where name = 'DEMAND_INF_INV')
BEGIN
truncate table dbo.DEMAND_INF_INV
END

if exists (select * from sys.tables where name = 'CART_TEMPL_INV')
BEGIN
truncate table dbo.CART_TEMPL_INV
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

if exists (select * from sys.tables where name = 'PURCH_ITEM_ATTR')
BEGIN
truncate table dbo.PURCH_ITEM_ATTR
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


if exists (select * from sys.tables where name = 'REQ_LINE_SHIP')
BEGIN
truncate table dbo.REQ_LINE_SHIP
END

if exists (select * from sys.tables where name = 'DEPT_TBL')
BEGIN
truncate table dbo.DEPT_TBL
END

if exists (select * from sys.tables where name = 'GL_ACCOUNT_TBL')
BEGIN
truncate table dbo.GL_ACCOUNT_TBL
END

if exists (select * from sys.tables where name = 'JRNL_HEADER')
BEGIN
truncate table dbo.JRNL_HEADER
END

if exists (select * from sys.tables where name = 'JRNL_LN')
BEGIN
truncate table dbo.JRNL_LN
END

if exists (select * from sys.tables where name = 'CM_ACCTG_LINE')
BEGIN
truncate table dbo.CM_ACCTG_LINE
END

if exists (select * from sys.tables where name = 'RECV_LN_ACCTG')
BEGIN
truncate table dbo.RECV_LN_ACCTG
END

if exists (select * from sys.tables where name = 'VCHR_ACCTG_LINE')
BEGIN
truncate table dbo.VCHR_ACCTG_LINE
END




END

GO
grant exec on sp_CleanPeoplesoftTables to public
GO



/*
*************************************************************************************************************
Tableau Table sprocs
*************************************************************************************************************
*/

--*********************************************************************************************
--Tableau Table Sproc  These load data tables as alternate datasources for Tableau
--*********************************************************************************************


if exists (select * from dbo.sysobjects where id = object_id(N'tb_QCNDashboardTable') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure tb_QCNDashboardTable
GO

--exec tb_QCNDashboardTable 
CREATE PROCEDURE tb_QCNDashboardTable

--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON

truncate table tableau.QCNDashboard

insert into tableau.QCNDashboard
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
--
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
            --order by q.[DateEntered] asc--,convert(int,(getdate() - q.[DateEntered])) desc

END

GO



grant exec on tb_QCNDashboardTable to public
GO


--*********************************************************************************************
--Tableau Table Sproc  These load data tables as alternate datasources for Tableau
--*********************************************************************************************


if exists (select * from dbo.sysobjects where id = object_id(N'tb_GembaDashboardTable') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure tb_GembaDashboardTable
GO

--exec tb_GembaDashboardTable 
CREATE PROCEDURE tb_GembaDashboardTable


--WITH ENCRYPTION
AS
BEGIN


SET NOCOUNT ON

truncate table tableau.GembaDashboard

declare @GembaIdentifier varchar(50)
select @GembaIdentifier = ConfigValue from bluebin.Config where ConfigName = 'GembaIdentifier'

if @GembaIdentifier = '' 
BEGIN
set @GembaIdentifier = 'XXXXX'
END

insert into tableau.GembaDashboard
select 
	g.[GembaAuditNodeID],
	df.FacilityName,
	dl.[LocationID],
	dl.LocationID as AuditLocationID,
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
		
    g.[LastUpdated],
	PS_Comments,
	RS_Comments,
	NIS_Comments,
	SS_Comments,
	AdditionalComments,
	case
		when AdditionalComments like '%'+ @GembaIdentifier + '%' then 'Yes' else 'No' end as GembaIdent

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
WHERE dl.BlueBinFlag = 1 and (g.Active = 1 or g.Active is null)
            --order by dl.LocationID,[Date] asc

END

GO

grant exec on tb_GembaDashboardTable to public
GO



--*********************************************************************************************
--Tableau Table Sproc  These load data tables as alternate datasources for Tableau
--*********************************************************************************************


if exists (select * from dbo.sysobjects where id = object_id(N'tb_ConesDeployedTable') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure tb_ConesDeployedTable
GO

--exec tb_ConesDeployedTable 

CREATE PROCEDURE tb_ConesDeployedTable


--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON

truncate table tableau.ConesDeployed
--Declare @A table (ConeDeployed int,Deployed datetime,ExpectedDelivery Datetime,ConeReturned int,Returned datetime,FacilityID int,FacilityName varchar(255),LocationID varchar(15),LocationName varchar(50),ItemID varchar(32),ItemDescription varchar(50),BinSequence varchar(20),SubProduct varchar(3),AllLocations varchar(max))
	
insert into tableau.ConesDeployed	
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

grant exec on tb_ConesDeployedTable to appusers
GO








--End Tableau table Sprocs
--************************************************************************************************************








Print 'Tableau (tb) sprocs updated'
Print 'DB: ' + DB_NAME() + ' updated'
GO