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


