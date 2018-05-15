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
group by 
a.BUSINESS_UNIT,
bu.DESCR
END 
ELSE
BEGIN
 
declare @DefaultFacility int = (select ConfigValue from bluebin.Config where ConfigName = 'PS_DefaultFacility')
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
group by 
a.BUSINESS_UNIT,
bu.DESCR
END
--select * from bluebin.DimFacility

END
GO

UPDATE etl.JobSteps
SET LastModifiedDate = GETDATE()
WHERE StepName = 'DimFacility'
GO