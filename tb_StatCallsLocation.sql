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
;
WITH A as 
	(

SELECT
    a.FROM_TO_CMPY,
	df.FacilityName,
	--a.LOCATION,
	b.REQ_LOCATION as LocationID,
	dl.LocationName,
	dl.BlueBinFlag,
	TRANS_DATE as Date,
    COUNT(*) as StatCalls,
    case when c.ACCT_UNIT is null then 'None' else LTRIM(RTRIM(c.ACCT_UNIT)) + ' - '+ c.DESCRIPTION  end as Department
FROM
    ICTRANS a 
INNER JOIN
RQLOC b ON a.FROM_TO_CMPY = b.COMPANY AND a.FROM_TO_LOC = b.REQ_LOCATION
LEFT JOIN GLNAMES c ON b.COMPANY = c.COMPANY AND b.ISS_ACCT_UNIT = c.ACCT_UNIT
INNER JOIN bluebin.DimFacility df on a.FROM_TO_CMPY = df.FacilityID
INNER JOIN bluebin.DimLocation dl on b.REQ_LOCATION = dl.LocationID
WHERE SYSTEM_CD = 'IC' AND DOC_TYPE = 'IS' and TRANS_DATE > getdate() -15---and dl.BlueBinFlag = 1
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
) 
			
select 
distinct A.*,
case when 
i.REPL_FROM_LOC is not null then 'Yes' else 'No' end as WHSource
from A
left join ITEMSRC i on A.FROM_TO_CMPY = i.COMPANY and A.LocationID = i.LOCATION and REPLENISH_PRI = '1' and REPL_FROM_LOC in (select ConfigValue from bluebin.Config where ConfigName = 'LOCATION')
Order by A.Date desc



END
GO
grant exec on tb_StatCallsLocation to public
GO
