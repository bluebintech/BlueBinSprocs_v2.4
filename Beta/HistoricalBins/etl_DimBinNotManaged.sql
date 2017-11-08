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
/***************************		DROP HistoricalDimBin		********************************/
BEGIN TRY
    DROP TABLE bluebin.DimBinNotManaged
END TRY

BEGIN CATCH
END CATCH





/***********************************		CREATE	HistoricalDimBin		***********************************/

SELECT 
		   rtrim(ltrim(convert(varchar(10),i.COMPANY))) +'-' + rtrim(ltrim(convert(varchar(10),i.LOCATION))) + '-' + rtrim(ltrim(convert(varchar(10),i.ITEM))) AS FLI,
		   i.COMPANY AS FacilityID,
           i.LOCATION AS LocationID,
		   i.ITEM AS ItemID,
           UOM AS BinUOM,
           REORDER_POINT AS BinQty,
           CASE
             WHEN LEADTIME_DAYS = 0 or LEADTIME_DAYS is null THEN (Select max(ConfigValue) from bluebin.Config where ConfigName = 'DefaultLeadTime')
             ELSE LEADTIME_DAYS
           END  AS BinLeadTime,
           COALESCE(COALESCE(ItemReqs.UNIT_COST, ItemOrders.ENT_UNIT_CST), ItemStore.LAST_ISS_COST) AS BinCurrentCost,
           CASE
			 WHEN UPPER(ltrim(rtrim(i.USER_FIELD1))) in (Select ConfigValue from bluebin.Config where ConfigName = 'ConsignmentFlag') OR Consignment.CONSIGNMENT_FL = 'Y'  THEN 'Y'
             ELSE 'N'
           END  AS BinConsignmentFlag,
           ItemAccounts.ISS_ACCOUNT AS BinGLAccount,
		   getdate() as [BaselineDate]
		   --'2017-05-03 00:00:00' as [BaselineDate]
    INTO bluebin.DimBinNotManaged
    FROM   ITEMLOC i			   
           LEFT JOIN (
					SELECT Row_number() 
								OVER(
									Partition BY ITEM, ENTERED_UOM
									ORDER BY CREATION_DATE DESC) AS Itemreqseq,
					ITEM,
					ENTERED_UOM,
					UNIT_COST
					FROM   REQLINE a 
					) ItemReqs
						ON i.ITEM = ItemReqs.ITEM
						AND i.UOM = ItemReqs.ENTERED_UOM
						AND ItemReqs.Itemreqseq = 1
           LEFT JOIN (
					SELECT Row_number()
							 OVER(
							   Partition BY ITEM, ENT_BUY_UOM
							   ORDER BY PO_NUMBER DESC) AS ItemOrderSeq,
						   ITEM,
						   ENT_BUY_UOM,
						   ENT_UNIT_CST
					FROM   POLINE
					WHERE  ITEM_TYPE IN ( 'I', 'N' )		   
				) ItemOrders
                  ON i.ITEM = ItemOrders.ITEM
                     AND i.UOM = ItemOrders.ENT_BUY_UOM
                     AND ItemOrders.ItemOrderSeq = 1
		   LEFT JOIN (
					SELECT distinct a.ITEM,
							--a.GL_CATEGORY,
							max(b.ISS_ACCOUNT) as ISS_ACCOUNT--,a.LOCATION
					FROM   ITEMLOC a 
							LEFT JOIN ICCATEGORY b
									ON a.GL_CATEGORY = b.GL_CATEGORY
										AND a.LOCATION = b.LOCATION
					WHERE  
					a.LOCATION in (select ConfigValue from bluebin.Config where ConfigName = 'LOCATION') 
					and a.ACTIVE_STATUS = 'A' 
					group by a.ITEM		   
		   
			) ItemAccounts
                  ON i.ITEM = ItemAccounts.ITEM
           LEFT JOIN (
					SELECT distinct 
					i.ITEM,
					c.LAST_ISS_COST
					FROM   ITEMLOC i
					left join (select ITEMLOC.ITEM,max(ITEMLOC.LAST_ISS_COST) as LAST_ISS_COST from ITEMLOC
									inner join (select ITEM,max(LAST_ISSUE_DT) as t from ITEMLOC group by ITEM) cost on ITEMLOC.ITEM = cost.ITEM and ITEMLOC.LAST_ISSUE_DT = cost.t
									group by ITEMLOC.ITEM ) c on i.ITEM = c.ITEM
					WHERE  i.LOCATION in (select ConfigValue from bluebin.Config where ConfigName = 'LOCATION')  and i.ACTIVE_STATUS = 'A'  		   
		   
		   ) ItemStore
                  ON i.ITEM = ItemStore.ITEM
		   LEFT JOIN (
					SELECT distinct ITEM,CONSIGNMENT_FL 
					FROM ITEMMAST
					WHERE  ITEM in (select ITEM from ITEMLOC where LOCATION in (select ConfigValue from bluebin.Config where ConfigName = 'LOCATION'))   
		   
		   ) Consignment
                  ON i.ITEM = Consignment.ITEM
	where 
		rtrim(ltrim(convert(varchar(10),i.COMPANY))) +'-' + rtrim(ltrim(convert(varchar(10),i.LOCATION)))  not in (select rtrim(ltrim(LocationFacility)) +'-' + rtrim(ltrim(LocationID))  from bluebin.DimLocation where BlueBinFlag = 1)
		and rtrim(ltrim(convert(varchar(10),i.COMPANY))) +'-' + rtrim(ltrim(convert(varchar(10),i.LOCATION))) + '-' + rtrim(ltrim(convert(varchar(32),i.ITEM))) not in (select rtrim(ltrim(convert(varchar(10),BinFacility))) + '-' + LocationID + '-' + ItemID from bluebin.DimBin)
	order by 1
	



GO

UPDATE etl.JobSteps
SET LastModifiedDate = GETDATE()
WHERE StepName = 'DimBinNotManaged'


