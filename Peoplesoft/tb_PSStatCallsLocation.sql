--*********************************************************************************************
--Tableau Sproc  These load data into the datasources for Tableau
--*********************************************************************************************
--Updated GB 20180307 Altered Facility pulling based on multiple facilities


if exists (select * from dbo.sysobjects where id = object_id(N'tb_StatCallsLocation') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure tb_StatCallsLocation
GO

--exec tb_StatCallsLocation
CREATE PROCEDURE tb_StatCallsLocation
AS
BEGIN
SET NOCOUNT ON

declare @Facility int = (select ConfigValue from bluebin.Config where ConfigName = 'PS_DefaultFacility')
declare @FacilityName varchar(30) = (select PSFacilityName from bluebin.DimFacility where FacilityID = @Facility)

SELECT 
--case when @Facility is not null or @Facility <> '' then @Facility else ''end as FROM_TO_CMPY,
--case when @Facility is not null or @Facility <> '' then (select FacilityName from bluebin.DimFacility where FacilityID = @Facility) else ''end as FacilityName,
COALESCE(df.FacilityID,@Facility) as FROM_TO_CMPY,
COALESCE(df.PSFacilityName,@FacilityName) as FacilityName,
lt.LOCATION as LocationID,
lt.DESCR as LocationName,
ISNULL(dl.BlueBinFlag,0) as BlueBinFlag,
DEMAND_DATE       AS [Date],
COUNT(*) as StatCalls,
'' as Department,
'No' as WHSource

FROM   dbo.IN_DEMAND
       INNER JOIN dbo.LOCATION_TBL lt on IN_DEMAND.LOCATION = lt.LOCATION
	   LEFT JOIN bluebin.DimLocation dl ON lt.LOCATION = dl.LocationID
	   LEFT JOIN bluebin.DimFacility df on IN_DEMAND.BUSINESS_UNIT= df.FacilityName

WHERE  PICK_BATCH_ID = 0
       --AND BUSINESS_UNIT in (Select ConfigValue from bluebin.Config where ConfigName = 'PS_BUSINESSUNIT')
	   AND (BUSINESS_UNIT in (Select ConfigValue from bluebin.Config where ConfigName = 'PS_BUSINESSUNITSTAT') or SOURCE_BUS_UNIT in (Select ConfigValue from bluebin.Config where ConfigName = 'PS_BUSINESSUNIT'))
	   AND (IN_FULFILL_STATE in (select ConfigValue from bluebin.Config where ConfigName = 'PS_InFulfillState') or IN_FULFILL_STATE is null)
GROUP BY
--DimLocation.LocationID,
--DimLocation.LocationName,
df.FacilityID,
df.PSFacilityName,
lt.LOCATION,
lt.DESCR,
dl.BlueBinFlag,
DEMAND_DATE
Order by DEMAND_DATE



END
GO
grant exec on tb_StatCallsLocation to public
GO
