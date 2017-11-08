

--/******************************************

--			DimLocation

--******************************************/

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
           REQ_LOCATION              AS LocationID,
           NAME                       AS LocationName,
           COMPANY                    AS LocationFacility,
           CASE
             WHEN ACTIVE_STATUS = 'A' and (
											LEFT(REQ_LOCATION, 2) IN (SELECT [ConfigValue]
                                            FROM   [bluebin].[Config]
                                            WHERE  [ConfigName] = 'REQ_LOCATION'
                                                   AND Active = 1) 
										or convert(varchar(10),COMPANY)+'-'+REQ_LOCATION in (select convert(varchar(10),COMPANY)+'-'+REQ_LOCATION from bluebin.ALT_REQ_LOCATION)
											)		   
												   
										THEN 1
             ELSE 0
           END                        AS BlueBinFlag,
		   ACTIVE_STATUS
    INTO   bluebin.DimLocation
    FROM   
		(
		select distinct REQ_LOCATION,NAME,COMPANY,ACTIVE_STATUS FROM RQLOC
		) a 
	--where COMPANY like '3201' and REQ_LOCATION = 'NICU'
	

GO

UPDATE etl.JobSteps
SET LastModifiedDate = GETDATE()
WHERE StepName = 'DimLocation'

