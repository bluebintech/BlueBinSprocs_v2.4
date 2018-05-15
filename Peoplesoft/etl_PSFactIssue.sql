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