--*********************************************************************************************
--Tableau Sproc  These load data into the datasources for Tableau
--*********************************************************************************************
--Updated GB 20180307 Altered Facility pulling based on multiple facilities

if exists (select * from dbo.sysobjects where id = object_id(N'tb_StatCalls') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure tb_StatCalls
GO


--exec tb_StatCalls
CREATE PROCEDURE tb_StatCalls
AS
BEGIN
SET NOCOUNT ON

declare @Facility int = (select ConfigValue from bluebin.Config where ConfigName = 'PS_DefaultFacility')
declare @FacilityName varchar(30) = (select PSFacilityName from bluebin.DimFacility where FacilityID = @Facility)

SELECT 
COALESCE(df.FacilityID,@Facility) as FROM_TO_CMPY,
--case when @Facility is not null or @Facility <> '' then COALESCE(@Facility,BUSINESS_UNIT) else BUSINESS_UNIT end as FROM_TO_CMPY,
COALESCE(df.PSFacilityName,@FacilityName) as FacilityName,
lt.LOCATION as LocationID,
lt.DESCR as LocationName,
case when ISNULL(dl.BlueBinFlag,0) = 1 then 'Yes' else 'No' end as BlueBinFlag,
DEMAND_DATE       AS [Date],
COUNT(*) as StatCalls,
case when BUSINESS_UNIT <> SOURCE_BUS_UNIT then SOURCE_BUS_UNIT else BUSINESS_UNIT end as Department,
case when ORDER_NO LIKE 'MSR%' then 'Yes' else 'No' end as WHSource

FROM   IN_DEMAND
       LEFT JOIN LOCATION_TBL lt on rtrim(IN_DEMAND.LOCATION) = rtrim(lt.LOCATION)
	   LEFT JOIN bluebin.DimLocation dl ON lt.LOCATION = dl.LocationID
	   LEFT JOIN bluebin.DimFacility df on IN_DEMAND.BUSINESS_UNIT= df.FacilityName
	   

WHERE  PICK_BATCH_ID = 0
       AND (BUSINESS_UNIT in (Select ConfigValue from bluebin.Config where ConfigName = 'PS_BUSINESSUNITSTAT') or SOURCE_BUS_UNIT in (Select ConfigValue from bluebin.Config where ConfigName = 'PS_BUSINESSUNIT'))
	   AND (IN_FULFILL_STATE in (select ConfigValue from bluebin.Config where ConfigName = 'PS_InFulfillState') or IN_FULFILL_STATE is null)


GROUP BY
--DimLocation.LocationID,
--DimLocation.LocationName,
BUSINESS_UNIT,
df.FacilityID,
SOURCE_BUS_UNIT,
df.PSFacilityName,
lt.LOCATION,
lt.DESCR,
dl.BlueBinFlag,
DEMAND_DATE,
ORDER_NO
Order by DEMAND_DATE



END
GO
grant exec on tb_StatCalls to public
GO
