select top 100*,'CM_ACCTG_LINE' from CM_ACCTG_LINE
/*
This PeopleSoft Application Engine process retrieves costed transactions and finds the correct 
ChartField combinations to use for the debit and credit lines of each accounting entry. Results are stored in the CM_ACCTG_LINE table.
select distinct ACCOUNT,DESCR from CM_ACCTG_LINE where GL_DISTRIB_STATUS = 'D' and DEPTID in (select distinct DEPTID from DEPT_TBL where EFF_STATUS = 'A' and UPPER(DESCR) like '%SUPPLY%')
select * from CM_ACCTG_LINE where ACCOUNT in ('733100','733700','742000') and JOURNAL_DATE > getdate() -500

select distinct c.ACCOUNT,g.DESCR,d.DEPTID,d.DESCR from CM_ACCTG_LINE c
inner join DEPT_TBL d on c.DEPTID = d.DEPTID and d.EFF_STATUS = 'A' and UPPER(d.DESCR) like '%SUPPLY%'
inner join GL_ACCOUNT_TBL g on c.ACCOUNT = g.ACCOUNT
where c.GL_DISTRIB_STATUS = 'D' 


select SUM(MONETARY_AMOUNT) from CM_ACCTG_LINE where ACCOUNT in ('733100','733700','742000') and JOURNAL_DATE > getdate() -500
*/

select top 100*,'DEPT_TBL' from DEPT_TBL where UPPER(DESCR) like '%NICU%' order by DESCR asc
/*
select distinct DEPTID,DESCR from DEPT_TBL where EFF_STATUS = 'A' and UPPER(DESCR) like '%SUPPLY%' order by DESCR asc
UMHC Sourcing & Supply Chain
'A1106012','A1107001','H2106067','H0405021'

DEPTID	DESCR
R3008002	CAMPUS SUPPLY CENTER
R3008002	Campus Supply Center
R3008007	CAMPUS SUPPLY CTR EQUIP RES
R3008007	Campus Supply Ctr Equip Res
R3008003	CAMPUS SUPPLY CTR OPERATIONS
R3008003	Campus Supply Ctr Operations
H4204002	CENTRAL SUPPLY
H7305001	CENTRAL SUPPLY
R5005308	LABORATORY SUPPLY ACCT
C4527007	LIDR SUPPLY CENTER
K1102078	MARKETING & SUPPLY CHAIN MGT
H7305001	MRC CENTRAL SUPPLY
H0405021	SOURCING & SUPPLY CHAIN
H0405004	SUPPLY DISTRIBUTION
H2106067	UMHC SOURCING & SUPPLY CHAIN
A1106012	UMHC Sourcing & Supply Chain
A1107001	UMHC Sourcing & Supply Chain
C0755033	UNIV BOOK AND SUPPLY
*/

select top 100*,'GL_ACCOUNT_TBL' from GL_ACCOUNT_TBL order by ACCOUNT
/*
select distinct ACCOUNT,ACCOUNT_TYPE,DESCR from GL_ACCOUNT_TBL where EFF_STATUS = 'A'  Order by DESCR asc
select * from GL_ACCOUNT_TBL where ACCOUNT in ('733100','733700','742000')
ACCOUNT	ACCOUNT_TYPE	DESCR	EFF_STATUS	EFFDT
742000	E	Other misc expense	A	1900-01-01 00:00:00.000
733100	E	Hospital supplies-medical item	A	1900-01-01 00:00:00.000
733700	E	Non-medical supplies	A	1900-01-01 00:00:00.000
*/

select top 100*,'JRNL_HEADER' from JRNL_HEADER
/*
select distinct LEDGER_GROUP from JRNL_HEADER
select distinct POSTED_DATE from JRNL_HEADER
*/

select top 100*,'JRNL_LN' from JRNL_LN
/*

*/

select top 100*,'RECV_LN_ACCTG' from RECV_LN_ACCTG
/*
Receiver accounting line table

*/

select top 100*,'VCHR_ACCTG_LINE' from VCHR_ACCTG_LINE
/*
Contains information about vouchers, including accounting and journal dates
*/

select top 100* from RECV_LN_DISTRIB 
select top 100* from PO_LINE 
select top 100* from PO_HDR 
select top 100* from PO_LINE_DISTRIB 
select top 100* from PURCH_ITEM_ATTR

select distinct PO_STATUS from PO_HDR where PO_ID in (select PONumber from tableau.Sourcing where POStatus = 'Closed' and PODate > '01-01-2017')

select * from DEPT_TBL where DEPTID = 'H0403003'

select * from CART_TEMPL_INV where INV_ITEM_ID = '2004378'

select * from CART_TEMPL_INV
select * from REQ_LINE