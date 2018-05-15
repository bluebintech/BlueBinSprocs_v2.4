--*********************************************************************************************
--Tableau Sproc  These load data into the datasources for Tableau
--*********************************************************************************************
--Updated GB 20180226  Added in logic to account for multiple names on an account in GLCHARTDTL

if exists (select * from dbo.sysobjects where id = object_id(N'tb_GLSpend') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure tb_GLSpend
GO

--exec tb_GLSpend  select * from GLTRANS

CREATE PROCEDURE tb_GLSpend

--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON


SELECT 
	   FISCAL_YEAR                                                                                                                                                                                                  AS FiscalYear,
       ACCT_PERIOD                                                                                                                                                                                                  AS AcctPeriod,
       a.COMPANY,
	   df.FacilityName,
	   a.ACCOUNT                                                                                                                                                                                                    AS Account,
       b.ACCOUNT_DESC                                                                                                                                                                                               AS AccountDesc,
       a.ACCT_UNIT                                                                                                                                                                                                  AS AcctUnit,
       c.DESCRIPTION                                                                                                                                                                                                AS AcctUnitName,
       --(DATEADD(m, DATEDIFF(m, 0, a.POSTING_DATE), 0)),
	   --Cast(CONVERT(VARCHAR, CASE WHEN ACCT_PERIOD <= 3 THEN ACCT_PERIOD + 9 ELSE ACCT_PERIOD - 3 END) + '/1/' + CONVERT(VARCHAR, CASE WHEN ACCT_PERIOD <=3 THEN FISCAL_YEAR - 1 ELSE FISCAL_YEAR END) AS DATETIME) AS Date,
       COALESCE(
				(DATEADD(m, DATEDIFF(m, 0, a.POSTING_DATE), 0)),
				(Cast(CONVERT(VARCHAR, CASE WHEN ACCT_PERIOD <= 3 THEN ACCT_PERIOD + 9 ELSE ACCT_PERIOD - 3 END) + '/1/' + CONVERT(VARCHAR, CASE WHEN ACCT_PERIOD <=3 THEN FISCAL_YEAR - 1 ELSE FISCAL_YEAR END) AS DATETIME)),
				NULL
				) as [Date],
	   Sum(TRAN_AMOUNT)                                                                                                                                                                                             AS Amount
FROM   GLTRANS a
       INNER JOIN 
			(select SUMRY_ACCT_ID,ACCOUNT,max(ACCOUNT_DESC) as ACCOUNT_DESC,ACTIVE_STATUS 
				from GLCHARTDTL 
				where 
				--ACCOUNT = '641010' AND
				SUMRY_ACCT_ID in (select ConfigValue from bluebin.Config where ConfigName = 'GLSummaryAccountID') group by SUMRY_ACCT_ID,ACCOUNT,ACTIVE_STATUS 
				) b ON a.ACCOUNT = b.ACCOUNT
       INNER JOIN GLNAMES c
               ON a.ACCT_UNIT = c.ACCT_UNIT
                  AND a.COMPANY = c.COMPANY
		left join bluebin.DimFacility df on a.COMPANY = df.FacilityID
WHERE  
--a.ACCT_UNIT = '609030'
SUMRY_ACCT_ID in (select ConfigValue from bluebin.Config where ConfigName = 'GLSummaryAccountID')
and a.POSTING_DATE is not null
--and FISCAL_YEAR < = datepart(year,dateadd(yy,1,getdate()))
--and ACCT_PERIOD < = 12
GROUP  BY 
		  DATEADD(m, DATEDIFF(m, 0, a.POSTING_DATE), 0),
		  FISCAL_YEAR,
          ACCT_PERIOD,
          a.COMPANY,
			df.FacilityName,
			a.ACCOUNT,
          b.ACCOUNT_DESC,
          a.ACCT_UNIT,
          c.DESCRIPTION 





END
GO
grant exec on tb_GLSpend to public
GO





