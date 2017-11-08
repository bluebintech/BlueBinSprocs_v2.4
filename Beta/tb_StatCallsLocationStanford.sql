--*********************************************************************************************
--Tableau Sproc  These load data into the datasources for Tableau
--*********************************************************************************************

if exists (select * from dbo.sysobjects where id = object_id(N'tb_StatCallsLocation') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure tb_StatCallsLocation
GO

--exec tb_StatCallsLocation
CREATE PROCEDURE tb_StatCallsLocation
AS
BEGIN
SET NOCOUNT ON
declare @StatCallsRQDate Datetime, @StatCallsRQDate1 Datetime, @StatCallsRQDate2 Datetime, @StatCallsRQLoc varchar(10),@StatCallsRQOR int
select @StatCallsRQDate = ConfigValue from bluebin.Config where ConfigName = 'StatCallsRQDate'
select @StatCallsRQLoc = ConfigValue from bluebin.Config where ConfigName = 'StatCallsRQLoc'
select @StatCallsRQOR = ConfigValue from bluebin.Config where ConfigName = 'StatCallsRQOR'

set @StatCallsRQDate1 = case when @StatCallsRQDate = '' or @StatCallsRQOR = 1 then getdate() + 1 else @StatCallsRQDate end
set @StatCallsRQDate2 = case when @StatCallsRQDate = '' then getdate() + 1 else @StatCallsRQDate end
;

WITH A as 
	(

SELECT
    a.FROM_TO_CMPY,
	df.FacilityName,
	--a.LOCATION,
	b.REQ_LOCATION as LocationID,
	dl.LocationName,
	case when dl.BlueBinFlag = 1 then 'Yes' else 'No' end as BlueBinFlag,
	TRANS_DATE as Date,
    COUNT(*) as StatCalls,
    case when c.ACCT_UNIT is null then 'None' else LTRIM(RTRIM(c.ACCT_UNIT)) + ' - '+ c.DESCRIPTION  end as Department
	,'IC' as [Type]
FROM
    ICTRANS a 
INNER JOIN
RQLOC b ON a.FROM_TO_CMPY = b.COMPANY AND a.FROM_TO_LOC = b.REQ_LOCATION
LEFT JOIN GLNAMES c ON b.COMPANY = c.COMPANY AND b.ISS_ACCT_UNIT = c.ACCT_UNIT
INNER JOIN bluebin.DimFacility df on a.FROM_TO_CMPY = df.FacilityID
INNER JOIN bluebin.DimLocation dl on b.REQ_LOCATION = dl.LocationID

WHERE SYSTEM_CD = 'IC' AND DOC_TYPE = 'IS' 
		and a.TRANS_DATE < @StatCallsRQDate1  and a.TRANS_DATE > getdate()-15--and dl.BlueBinFlag = 1
GROUP BY
    a.FROM_TO_CMPY,
	df.FacilityName,
	--a.LOCATION,
	b.REQ_LOCATION,
	dl.LocationName,
	dl.BlueBinFlag,
	TRANS_DATE,
    c.ACCT_UNIT,
    c.DESCRIPTION
),
B as
(
select 
    FROM_TO_CMPY,
	FacilityName,
	LocationID,
	LocationName,
	BlueBinFlag,
	[Date],
    StatCalls,
    Department
	,[Type] 
	from A
UNION
SELECT 
	a.FROM_TO_CMPY,
	a.FacilityName,
	a.LocationID,
	a.LocationName,
	a.BlueBinFlag,
	a.TRANS_DATE as [Date],
    COUNT(*) as StatCalls,
	a.Department
    ,a.[Type]

FROM
    (
	 select distinct 
		 a.*,
			df.FacilityName,
			r.REQ_LOCATION as LocationID,
			dl.LocationName,
			case when dl.BlueBinFlag = 1 then 'Yes' else 'No' end as BlueBinFlag,
			case when c.ACCT_UNIT is null then 'None' else LTRIM(RTRIM(c.ACCT_UNIT)) + ' - '+ c.DESCRIPTION  end as Department
			,'RQ' as [Type]
		 from ICTRANS a
		 inner join REQLINE r on rtrim(a.DOCUMENT) = right(('00000'+rtrim(r.REQ_NUMBER)),10) --and r.REQ_LOCATION = 'W1005' and r.CREATION_DATE = '2017-07-26 00:00:00.000'  
		 --INNER JOIN RQLOC b ON a.FROM_TO_CMPY = b.COMPANY AND a.FROM_TO_LOC = b.REQ_LOCATION
		 INNER JOIN REQHEADER b ON a.FROM_TO_CMPY = b.COMPANY AND r.REQ_NUMBER = b.REQ_NUMBER
		 LEFT JOIN GLNAMES c ON b.COMPANY = c.COMPANY AND b.ACCT_UNIT = c.ACCT_UNIT
		 INNER JOIN bluebin.DimFacility df on a.FROM_TO_CMPY = df.FacilityID
		LEFT JOIN bluebin.DimLocation dl on r.REQ_LOCATION = dl.LocationID
		 where  r.REQ_LOCATION = @StatCallsRQLoc and a.TRANS_DATE > @StatCallsRQDate and a.TRANS_DATE > getdate()-15 --'2017-07-26 00:00:00.000'  
		 ) a

GROUP BY
    a.FROM_TO_CMPY,
	a.FacilityName,
	a.LocationID,
	a.LocationName,
	a.BlueBinFlag,
	a.TRANS_DATE,
    a.Department
    ,a.[Type]
			)

select 
distinct 
FROM_TO_CMPY,
FacilityName,
LocationID,
LocationName,
BlueBinFlag,
[Date],
StatCalls,
Department,
[Type],
case when 
i.REPL_FROM_LOC is not null then 'Yes' else 'No' end as WHSource
from B
left join ITEMSRC i on B.FROM_TO_CMPY = i.COMPANY and B.LocationID = i.LOCATION and REPLENISH_PRI = '1' and REPL_FROM_LOC in (select ConfigValue from bluebin.Config where ConfigName = 'LOCATION')
where [Date] > getdate() -15
--where B.[Type] = 'RQ'
Order by B.[Date],LocationID desc

--exec tb_StatCallsLocation
END
GO
grant exec on tb_StatCallsLocation to public
GO
