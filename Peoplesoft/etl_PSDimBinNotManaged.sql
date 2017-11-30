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

SELECT 
		   '' as FLI,
		   '' as FacilityID,
           '' as LocationID,
		   '' as ItemID,
           '' as BinUOM,
           '' as BinQty,
           '' as BinLeadTime,
           '' as BinCurrentCost,
           '' as BinConsignmentFlag,
           '' as BinGLAccount,
		   '' as [BaselineDate]
		   
    INTO bluebin.DimBinNotManaged

	



GO

UPDATE etl.JobSteps
SET LastModifiedDate = GETDATE()
WHERE StepName = 'DimBinNotManaged'


