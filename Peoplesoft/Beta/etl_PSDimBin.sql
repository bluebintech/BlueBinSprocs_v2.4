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
	   
		--bu.LAST_PRICE_PAID AS BinCurrentCost,
  --     bu.CONSIGNED_FLAG AS BinConsignmentFlag,
		COALESCE(bu.LAST_PRICE_PAID,bu.LAST_PO_PRICE_PAID,bu.PRICE_LIST,0) AS BinCurrentCost,
       COALESCE(bu.CONSIGNED_FLAG_BU,bu.CONSIGNED_FLAG_M,'N') AS BinConsignmentFlag,
       '' AS BinGLAccount,
	   'Awaiting Updated Status'						 AS BinCurrentStatus


INTO   bluebin.DimBin
FROM   
	(
	select distinct 
	c.INV_CART_ID, 
	c.INV_ITEM_ID,
	case when LEN(c.COMPARTMENT) < 6 then '' else c.COMPARTMENT end as COMPARTMENT,
	c.QTY_OPTIMAL,
	c.UNIT_OF_MEASURE
	
	 from dbo.CART_TEMPL_INV c
	 inner join (select INV_CART_ID, INV_ITEM_ID, max(ISNULL(COUNT_ORDER,1)) as COUNT_ORDER from CART_TEMPL_INV --where COUNT_ORDER is not null 
	 --and LEN(COMPARTMENT) >=6 
	 group by INV_CART_ID, INV_ITEM_ID) a 
		on c.INV_CART_ID = a.INV_CART_ID and c.INV_ITEM_ID = a.INV_ITEM_ID and ISNULL(c.COUNT_ORDER,1) = a.COUNT_ORDER
	 --where c.INV_ITEM_ID = '1446' and c.INV_CART_ID = 'L0153'
	 group by 
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
			,p.PRICE_LIST
			,bu.CONSIGNED_FLAG as CONSIGNED_FLAG_BU
			,m.CONSIGNED_FLAG as CONSIGNED_FLAG_M

			from (select INV_ITEM_ID,max(CONSIGNED_FLAG) as CONSIGNED_FLAG from MASTER_ITEM_TBL group by INV_ITEM_ID) m 
			LEFT JOIN PURCH_ITEM_ATTR p on m.INV_ITEM_ID = p.INV_ITEM_ID
			LEFT JOIN BU_ITEMS_INV bu on m.INV_ITEM_ID = bu.INV_ITEM_ID and bu.BUSINESS_UNIT in (select ConfigValue from bluebin.Config where ConfigName = 'PS_BUSINESSUNIT')
			) bu on Bins.INV_ITEM_ID = bu.INV_ITEM_ID

WHERE  
		
		dl.BlueBinFlag = 1 and
		LEN(COMPARTMENT) >=6 and 
		(LEFT(Locations.LOCATION, 2) COLLATE DATABASE_DEFAULT IN (SELECT [ConfigValue] FROM   [bluebin].[Config] WHERE  [ConfigName] = 'REQ_LOCATION' AND Active = 1) 
		or Locations.LOCATION COLLATE DATABASE_DEFAULT in (Select REQ_LOCATION from bluebin.ALT_REQ_LOCATION))

		--and Bins.INV_ITEM_ID = '1446' and Bins.INV_CART_ID = 'L0153'
		
		order by Locations.LOCATION,Bins.INV_ITEM_ID 


/*****************************************		DROP Temp Tables	**************************************/


GO

UPDATE etl.JobSteps
SET LastModifiedDate = GETDATE()
WHERE StepName = 'DimBin'

GO


