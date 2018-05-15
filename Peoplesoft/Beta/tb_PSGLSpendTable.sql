--*********************************************************************************************
--Tableau Table Sproc  These load data tables as alternate datasources for Tableau
--*********************************************************************************************
--select * from etl.JobSteps
--insert into etl.JobSteps select (select max(StepNumber) + 1 from etl.JobSteps),'GLSpendTable','tb_GLSpendTable','tableau.tb_GLSpend','1',getdate()

if exists (select * from dbo.sysobjects where id = object_id(N'tb_GLSpendTable') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure tb_GLSpendTable
GO

--exec tb_GLSpendTable

CREATE PROCEDURE tb_GLSpendTable

--WITH ENCRYPTION
AS
BEGIN
--SET NOCOUNT ON
truncate table tableau.GLSpend

declare @DefaultFacility int = (select ConfigValue from bluebin.Config where ConfigName = 'PS_DefaultFacility')
declare @DefaultFacilityName varchar(30) = (select PSFacilityName from bluebin.DimFacility where FacilityID = @DefaultFacility)


SELECT 
jh.FISCAL_YEAR as FiscalYear,
jh.ACCOUNTING_PERIOD AS AcctPeriod,
COALESCE(df.FacilityID,@DefaultFacility) as COMPANY,
COALESCE(df.FacilityName,@DefaultFacilityName) as FacilityName,
ISNULL(jl.ACCOUNT,'N/A') as Account,                                                                                                              
ISNULL((jl.ACCOUNT + '-' + gl.DESCR),'N/A') AS AccountDesc,     
ISNULL(d.DEPTID,'N/A') AS  AcctUnit,
ISNULL(d.DESCR,'N/A') AS  AcctUnitName, 
jh.POSTED_DATE AS [Date],
Sum(jl.MONETARY_AMOUNT) AS  Amount 
into tableau.GLSpend
FROM   JRNL_HEADER jh
	INNER JOIN JRNL_LN jl on jl.JOURNAL_ID = jh.JOURNAL_ID
	LEFT JOIN (select g.ACCOUNT,g.ACCOUNT_TYPE,g.DESCR from GL_ACCOUNT_TBL g
					inner join (select ACCOUNT,max(EFFDT) as EFFDT from GL_ACCOUNT_TBL where EFF_STATUS = 'A' group by ACCOUNT) a on g.ACCOUNT = a.ACCOUNT and g.EFFDT = a.EFFDT
					)  gl ON jl.ACCOUNT = gl.ACCOUNT  
	LEFT JOIN (select d.DEPTID,d.DESCR from DEPT_TBL d
					inner join (select DEPTID,max(EFFDT) as EFFDT from DEPT_TBL where EFF_STATUS = 'A' group by DEPTID) a on d.DEPTID = a.DEPTID and d.EFFDT = a.EFFDT
					) d on jl.DEPTID = d.DEPTID
	LEFT JOIN bluebin.DimFacility df on jh.BUSINESS_UNIT = df.FacilityName


	select JOURNAL_DATE,count(*) from JRNL_LN group by JOURNAL_DATE order by JOURNAL_DATE
	select * from JRNL_HEADER
WHERE  
jh.POSTED_DATE > getdate() -30 and 
(jl.ACCOUNT in (select ConfigValue from bluebin.Config where ConfigName = 'GLSummaryAccountID')
--or gl.DESCR like '%supply%' or gl.DESCR like '%supplies%'
or gl.ACCOUNT in (select ACCOUNT from [bluebin].[PeoplesoftGLAccount]))


GROUP  BY 
jh.FISCAL_YEAR,
jh.POSTED_DATE,
jh.ACCOUNTING_PERIOD,
df.FacilityID,
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
grant exec on tb_GLSpendTable to public
GO




