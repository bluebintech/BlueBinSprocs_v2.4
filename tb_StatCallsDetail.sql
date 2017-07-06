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
;
WITH A as 
	(

		SELECT
			a.FROM_TO_CMPY,
			df.FacilityName,
			--a.LOCATION,
			b.REQ_LOCATION as LocationID,
			dl.LocationName,
			a.ITEM as ItemID,
			CASE 
					WHEN LEN(a.DOCUMENT) = 10 and LEFT(DOCUMENT,6) = '000000' THEN RIGHT(a.DOCUMENT,4)
					WHEN LEN(a.DOCUMENT) = 10 and LEFT(DOCUMENT,5) = '00000' THEN RIGHT(a.DOCUMENT,5)
					WHEN LEN(a.DOCUMENT) = 10 and LEFT(DOCUMENT,4) = '0000' THEN RIGHT(a.DOCUMENT,6)
					WHEN LEN(a.DOCUMENT) = 10 and LEFT(DOCUMENT,3) = '000' THEN RIGHT(a.DOCUMENT,7)
				ELSE a.DOCUMENT 
				END AS OrderNo,
			   a.TRANS_DATE as Date,
			   a.LINE_NBR,
			   SUM((a.QUANTITY*-1)) as QUANTITY,
			   --MAX((Cast(CONVERT(VARCHAR, a.TRANS_DATE, 101) + ' '
			   --     + LEFT(RIGHT('00000' + CONVERT(VARCHAR, a.ACTUAL_TIME), 4), 2)
			   --     + ':'
			   --     + Substring(RIGHT('00000' + CONVERT(VARCHAR, a.ACTUAL_TIME), 4), 3, 2) AS DATETIME))) AS TRANS_DATE,
			case when c.ACCT_UNIT is null then 'None' else LTRIM(RTRIM(c.ACCT_UNIT)) + ' - '+ c.DESCRIPTION  end as Department,
			case when dl.BlueBinFlag = 1 then 'Yes' else 'No' end as BlueBinFlag
		FROM
		ICTRANS a 
		INNER JOIN RQLOC b ON a.FROM_TO_CMPY = b.COMPANY AND a.FROM_TO_LOC = b.REQ_LOCATION
		LEFT JOIN GLNAMES c ON b.COMPANY = c.COMPANY AND b.ISS_ACCT_UNIT = c.ACCT_UNIT
		INNER JOIN bluebin.DimFacility df on a.FROM_TO_CMPY = df.FacilityID
		INNER JOIN bluebin.DimLocation dl on b.REQ_LOCATION = dl.LocationID
		WHERE SYSTEM_CD = 'IC' AND DOC_TYPE = 'IS' 
		--and dl.BlueBinFlag = 1 
		and a.TRANS_DATE > getdate() -90
		GROUP BY
			a.FROM_TO_CMPY,
			df.FacilityName,
			--a.LOCATION,
			dl.LocationName,
			a.ITEM,
			a.TRANS_DATE,
			a.DOCUMENT,
			a.LINE_NBR,
			b.REQ_LOCATION,
			dl.BlueBinFlag,
			c.ACCT_UNIT,
			c.DESCRIPTION ) 
			
select 
A.*,
case when 
i.REPL_FROM_LOC is not null then 'Yes' else 'No' end as WHSource
from A
left join ITEMSRC i on A.FROM_TO_CMPY = i.COMPANY and A.LocationID = i.LOCATION and A.ItemID = i.ITEM and REPLENISH_PRI = '1' and REPL_FROM_LOC in (select ConfigValue from bluebin.Config where ConfigName = 'LOCATION')


Order by A.Date,A.OrderNo desc




END
GO
grant exec on tb_StatCallsDetail to public
GO
