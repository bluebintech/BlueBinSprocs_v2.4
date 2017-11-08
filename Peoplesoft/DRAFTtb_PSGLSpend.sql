if exists (select * from dbo.sysobjects where id = object_id(N'tb_GLSpend') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure tb_GLSpend
GO

--exec tb_GLSpend

CREATE PROCEDURE tb_GLSpend

--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON

SELECT 
jh.FISCAL_YEAR,
jh.ACCT_PERIOD AS AcctPeriod,
@FacilityID as COMPANY,
df.FacilityName,
jl.ACCOUNT as Account,                                                                                                              
gl.DESCR as ACCOUNT_DESC,     
--       a.ACCT_UNIT                                                                                                                                                                                                  AS AcctUnit,
--       c.DESCRIPTION                                                                                                                                                                                                AS AcctUnitName,
--       Cast(CONVERT(VARCHAR, CASE WHEN ACCT_PERIOD <= 3 THEN ACCT_PERIOD + 9 ELSE ACCT_PERIOD - 3 END) + '/1/' + CONVERT(VARCHAR, CASE WHEN ACCT_PERIOD <=3 THEN FISCAL_YEAR - 1 ELSE FISCAL_YEAR END) AS DATETIME) AS Date,
Sum(MONETARY_AMOUNT) AS  Amount 
FROM   JRNL_HEADER jh
		INNER JOIN JRNL_LN jl on jl.JOURNAL_ID = jh.JOURNAL_ID
--       INNER JOIN GLCHARTDTL b
--               ON a.ACCOUNT = b.ACCOUNT
	INNER JOIN GL_ACCOUNT_TBL gl ON jl.ACCOUNT = gl.ACCT_UNIT
	LEFT JOIN bluebin.DimFacility df on @FacilityID = df.FacilityID
--WHERE  SUMRY_ACCT_ID in (select ConfigValue from bluebin.Config where ConfigName = 'GLSummaryAccountID')
GROUP  BY FISCAL_YEAR,
--          ACCT_PERIOD,
--          a.COMPANY,
--			df.FacilityName,
--			a.ACCOUNT,
--          b.ACCOUNT_DESC,
--          a.ACCT_UNIT,
--          c.DESCRIPTION 


SELECT '' AS FiscalYear,
       '' AS  AcctPeriod,
       '' AS COMPANY,
	   '' AS FacilityName,
	   '' AS  Account,
       '' AS  AccountDesc,
       '' AS  AcctUnit,
       '' AS  AcctUnitName,
       '' AS  Date,
       '' AS  Amount
 


END
GO
grant exec on tb_GLSpend to public
GO




