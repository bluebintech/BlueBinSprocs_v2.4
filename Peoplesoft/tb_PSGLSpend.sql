if exists (select * from dbo.sysobjects where id = object_id(N'tb_GLSpend') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure tb_GLSpend
GO

--exec tb_GLSpend

CREATE PROCEDURE tb_GLSpend

--WITH ENCRYPTION
AS
BEGIN
--SET NOCOUNT ON
declare @DefaultFacility int = (select ConfigValue from bluebin.Config where ConfigName = 'PS_DefaultFacility')

SELECT 
jh.FISCAL_YEAR as FiscalYear,
jh.ACCOUNTING_PERIOD AS AcctPeriod,
@DefaultFacility as COMPANY,
df.FacilityName,
ISNULL(jl.ACCOUNT,'N/A') as Account,                                                                                                              
ISNULL((jl.ACCOUNT + '-' + gl.DESCR),'N/A') AS AccountDesc,     
ISNULL(d.DEPTID,'N/A') AS  AcctUnit,
ISNULL(d.DESCR,'N/A') AS  AcctUnitName, 
jh.POSTED_DATE AS [Date],
Sum(jl.MONETARY_AMOUNT) AS  Amount 

FROM   JRNL_HEADER jh
	INNER JOIN JRNL_LN jl on jl.JOURNAL_ID = jh.JOURNAL_ID
	LEFT JOIN (select g.ACCOUNT,g.ACCOUNT_TYPE,g.DESCR from GL_ACCOUNT_TBL g
					inner join (select ACCOUNT,max(EFFDT) as EFFDT from GL_ACCOUNT_TBL where EFF_STATUS = 'A' group by ACCOUNT) a on g.ACCOUNT = a.ACCOUNT and g.EFFDT = a.EFFDT
					)  gl ON jl.ACCOUNT = gl.ACCOUNT  
	LEFT JOIN (select d.DEPTID,d.DESCR from DEPT_TBL d
					inner join (select DEPTID,max(EFFDT) as EFFDT from DEPT_TBL where EFF_STATUS = 'A' group by DEPTID) a on d.DEPTID = a.DEPTID and d.EFFDT = a.EFFDT
					) d on jl.DEPTID = d.DEPTID
	LEFT JOIN bluebin.DimFacility df on @DefaultFacility = df.FacilityID
WHERE  
jl.ACCOUNT in (select ConfigValue from bluebin.Config where ConfigName = 'GLSummaryAccountID')
--or gl.DESCR like '%supply%' or gl.DESCR like '%supplies%'
or gl.ACCOUNT in (select ACCOUNT from [bluebin].[PeoplesoftGLAccount])

GROUP  BY 
jh.FISCAL_YEAR,
jh.POSTED_DATE,
jh.ACCOUNTING_PERIOD,
df.FacilityName,
jl.ACCOUNT,
gl.DESCR,
d.DEPTID,
d.DESCR

order by 
df.FacilityName,
jl.ACCOUNT,
jh.FISCAL_YEAR,
jh.ACCOUNTING_PERIOD,
d.DEPTID,
jh.POSTED_DATE 


END
GO
grant exec on tb_GLSpend to public
GO




