BEGIN TRY
DROP TABLE DimLocation
END TRY
BEGIN CATCH
END CATCH
SELECT Row_number()
         OVER(
           ORDER BY EFFDT) AS LocationKey,
       LOCATION            AS LocationId,
       UPPER(DESCR)               AS LocationName,
       EFFDT               AS GoLiveDate
	   INTO DimLocation
FROM   ps.LOCATION_TBL
WHERE  LOCATION LIKE 'B%' 
