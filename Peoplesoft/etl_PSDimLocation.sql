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

