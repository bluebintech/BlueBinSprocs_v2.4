--*********************************************************************************************
--Tableau Sproc  These load data into the datasources for Tableau
--*********************************************************************************************

if exists (select * from dbo.sysobjects where id = object_id(N'tb_StatCallsDetail') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure tb_StatCallsDetail
GO


--exec tb_StatCallsDetail
CREATE PROCEDURE [dbo].[tb_StatCallsDetail]
AS
BEGIN
SET NOCOUNT ON
declare @Facility int
   select @Facility = ConfigValue from bluebin.Config where ConfigName = 'PS_DefaultFacility'


SELECT
case when @Facility is not null or @Facility <> '' then @Facility else ''end as FROM_TO_CMPY,
case when @Facility is not null or @Facility <> '' then (select FacilityName from bluebin.DimFacility where FacilityID = @Facility) else ''end as FacilityName,
lt.LOCATION as LocationID,
lt.DESCR as LocationName,
INV_ITEM_ID as ItemID,
ORDER_NO as OrderNo,
DEMAND_DATE  AS [Date],
ORDER_INT_LINE_NO as LINE_NBR,
SUM((QTY_REQUESTED*-1)) as QUANTITY,
--QTY_REQUESTED as QUANTITY,
    'N/A' as Department,
case when ISNULL(dl.BlueBinFlag,0) = 1 then 'Yes' else 'No' end as BlueBinFlag,
case	when ISNULL(dl.BlueBinFlag,0) = 0 
		then case	when INV_ITEM_ID is null or INV_ITEM_ID = '' 
					then 'Not Managed Special' 
					else 'Not Managed Standard' end
		else 'Managed' end as Category,
0 as Cost,	--Need
case when ORDER_NO LIKE 'MSR%' then 'Yes' else 'No' end as WHSource


FROM   IN_DEMAND
       INNER JOIN LOCATION_TBL lt on IN_DEMAND.LOCATION = lt.LOCATION
	   LEFT JOIN bluebin.DimLocation dl ON lt.LOCATION = dl.LocationID

WHERE  PICK_BATCH_ID = 0
       --AND BUSINESS_UNIT in (Select ConfigValue from bluebin.Config where ConfigName = 'PS_BUSINESSUNIT')
	   AND (BUSINESS_UNIT in (Select ConfigValue from bluebin.Config where ConfigName = 'PS_BUSINESSUNITSTAT') or SOURCE_BUS_UNIT in (Select ConfigValue from bluebin.Config where ConfigName = 'PS_BUSINESSUNIT'))
	   AND (IN_FULFILL_STATE in (select ConfigValue from bluebin.Config where ConfigName = 'PS_InFulfillState') or IN_FULFILL_STATE is null)
	   and DEMAND_DATE > getdate() -90
		--AND dl.BlueBinFlag = 1
Group by
lt.LOCATION,
lt.DESCR,
INV_ITEM_ID,
ORDER_NO,
DEMAND_DATE,
ORDER_INT_LINE_NO,
ISNULL(dl.BlueBinFlag,0)
Order by DEMAND_DATE,ORDER_NO,ORDER_INT_LINE_NO

END

GO
grant exec on tb_StatCallsDetail to public
GO
