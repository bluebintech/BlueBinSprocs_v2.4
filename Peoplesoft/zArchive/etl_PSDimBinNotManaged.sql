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
	   '' AS BinGLAccount,
	   getdate() as [BaselineDate]
		   
INTO bluebin.DimBinNotManaged
FROM   
	(
	select distinct 
	c.BUSINESS_UNIT,
	c.INV_CART_ID, 
	c.INV_ITEM_ID,
	case when LEN(c.COMPARTMENT) < 6 then '' else c.COMPARTMENT end as COMPARTMENT,
	c.QTY_OPTIMAL,
	c.UNIT_OF_MEASURE
	
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
	    order by 1




GO

UPDATE etl.JobSteps
SET LastModifiedDate = GETDATE()
WHERE StepName = 'DimBinNotManaged'


