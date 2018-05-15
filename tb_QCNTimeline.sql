--*********************************************************************************************
--Tableau Sproc  These load data into the datasources for Tableau
--*********************************************************************************************

if exists (select * from dbo.sysobjects where id = object_id(N'tb_QCNTimeline') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure tb_QCNTimeline
GO

--select * from qcn.QCN
--exec tb_QCNTimeline 
CREATE PROCEDURE tb_QCNTimeline

--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON

--Main query off of the subs to pull the Date, Facility, Location then takes a running total of Opened/Closed and displays.
select
LastDay,
[Date],
WeekName,
FacilityID,
FacilityName,
--LocationID,
--LocationName,
OpenedCt,
ClosedCt,
((SUM(OpenedCt) OVER (PARTITION BY FacilityID ORDER BY [Date] ROWS UNBOUNDED PRECEDING))-(SUM(ClosedCt) OVER (PARTITION BY FacilityID ORDER BY [Date] ROWS UNBOUNDED PRECEDING))) as RunningTotal
	
from
	(select
	LastDay,
	[Date],
	WeekName,
	FacilityID,
	FacilityName,
	--LocationID,
	--LocationName,
	sum(OpenedCt) as OpenedCt,
	sum(ClosedCt) as ClosedCt
	from (
		select 
		 (DATEADD(dd, @@DATEFIRST - DATEPART(dw, dd.Date), dd.Date)) as LastDay,
		 convert(varchar(4),datepart(yyyy,dd.Date))+right(('0'+convert(varchar(2),datepart(ww,dd.Date))),2)as [Date],
		 convert(varchar(4),datepart(yyyy,dd.Date))+' W'+right(('0'+convert(varchar(2),datepart(ww,dd.Date))),2)+' '+
		 left(DATENAME(Month,CONVERT(varchar(50), (DATEADD(dd, @@DATEFIRST - DATEPART(dw, dd.Date), dd.Date)-6), 101)),3)+' '+SUBSTRING(CONVERT(varchar(50), (DATEADD(dd, @@DATEFIRST - DATEPART(dw, dd.Date), dd.Date)-6), 101),4,2)
				+'-'+
					left(DATENAME(Month,CONVERT(varchar(50), (DATEADD(dd, @@DATEFIRST - DATEPART(dw, dd.Date), dd.Date)), 101)),3)+' '+SUBSTRING(CONVERT(varchar(50), (DATEADD(dd, @@DATEFIRST - DATEPART(dw, dd.Date), dd.Date)), 101),4,2) as WeekName,
		dd.FacilityID,
		dd.FacilityName,
		dd.LocationID,
		dd.LocationName,
		ISNULL(aa.OpenedCt,0) as OpenedCt,
		ISNULL(bb.ClosedCt,0) as ClosedCt

		from (
				--General query to populate a date for everyday for every Facility and Location
				select dd.Date,df.FacilityID,df.FacilityName,'Multiple' as LocationID,'Multiple' as LocationName from bluebin.DimDate dd,bluebin.DimFacility df
				UNION ALL
				select dd.Date,df.FacilityID,df.FacilityName,dl.LocationID,LocationName from bluebin.DimDate dd,bluebin.DimFacility df
				inner join bluebin.DimLocation dl on df.FacilityID = dl.LocationFacility and dl.BlueBinFlag = 1 
				where Date < getdate() +1 and Date > = (select min(DateEntered)-1 from tableau.QCNDashboard)) dd
			left join (
				--Query to pull all Opened QCNs by Facility and Location
				select 
						[Date],
						FacilityName,
						LocationID,
						OpenedCt
						from (
							select 
							dd.Date,
							q1.FacilityName,
							q1.LocationID,
							count(ISNULL(q1.DateEntered,0)) as OpenedCt
							from bluebin.DimDate dd
							left join tableau.QCNDashboard q1 on dd.Date = convert(date,q1.DateEntered,112) --and q1.Active = 1
							where q1.FacilityName is not null and dd.Date < getdate() +1 and dd.Date > = (select min(DateEntered)-1 from tableau.QCNDashboard)
							group by dd.Date,q1.FacilityName,q1.LocationID  
					
							 ) a
							 --order by FacilityID,LocationID,Date
							 ) aa on dd.Date = aa.Date and dd.FacilityID = aa.FacilityName and dd.LocationID = aa.LocationID
			left join (
				--Query to pull all Closed QCNs by Facility and Location
				select 
						[Date],
						FacilityName,
						LocationID,
						ClosedCt
						from (
							select 
							dd.Date,
							q2.FacilityName,
							q2.LocationID,
					
							count(ISNULL(q2.DateCompleted,0)) as ClosedCt
							from bluebin.DimDate dd
							left join tableau.QCNDashboard q2 on dd.Date = convert(date,q2.DateCompleted,112) --and q2.Active = 1
							where q2.FacilityName is not null and dd.Date < getdate() +1 and dd.Date > = (select min(DateCompleted)-1 from tableau.QCNDashboard)
							group by dd.Date,q2.FacilityName,q2.LocationID
					
							 ) a
							 --order by FacilityID,LocationID,Date
							 ) bb on dd.Date = bb.Date  and dd.FacilityID = bb.FacilityName and dd.LocationID = bb.LocationID

		where dd.Date < getdate() +1 and dd.Date > = (select min(DateEntered)-1 from tableau.QCNDashboard) and (ISNULL(OpenedCt,0) + ISNULL(ClosedCt,0)) > 0 
		) b
	group by 
	LastDay,
	[Date],
	WeekName,
	FacilityName
	--LocationID,
	--LocationName
	) c 
order by FacilityName,Date desc




END
GO
grant exec on tb_QCNTimeline to public
GO

SELECT * FROM PURCH_ITEM_BU

USE NYCHH_Queens
exec sp_CleanPeoplesoftTables
insert into NYCHH_Queens.dbo.BUS_UNIT_TBL_FS select * from NYCH.dbo.BUS_UNIT_TBL_FS where BUSINESS_UNIT = 'QUE01'
insert into NYCHH_Queens.dbo.BU_ITEMS_INV select * from NYCH.dbo.BU_ITEMS_INV where BUSINESS_UNIT = 'QUE01'
insert into NYCHH_Queens.dbo.CART_ATTRIB_INV select * from NYCH.dbo.CART_ATTRIB_INV where BUSINESS_UNIT = 'QUE01'
insert into NYCHH_Queens.dbo.CART_CT_INF_INV select * from NYCH.dbo.CART_CT_INF_INV where BUSINESS_UNIT = 'QUE01'
insert into NYCHH_Queens.dbo.CART_TEMPL_INV select * from NYCH.dbo.CART_TEMPL_INV where BUSINESS_UNIT = 'QUE01'
insert into NYCHH_Queens.dbo.IN_DEMAND select * from NYCH.dbo.IN_DEMAND where BUSINESS_UNIT = 'QUE01'
insert into NYCHH_Queens.dbo.JRNL_HEADER select * from NYCH.dbo.JRNL_HEADER where BUSINESS_UNIT = 'QUE01'
insert into NYCHH_Queens.dbo.PO_HDR select * from NYCH.dbo.PO_HDR where BUSINESS_UNIT = 'QUE01'
insert into NYCHH_Queens.dbo.JRNL_LN select * from NYCH.dbo.JRNL_LN where BUSINESS_UNIT = 'QUE01'
insert into NYCHH_Queens.dbo.PO_LINE select * from NYCH.dbo.PO_LINE where BUSINESS_UNIT = 'QUE01'
insert into NYCHH_Queens.dbo.PO_LINE_DISTRIB select * from NYCH.dbo.PO_LINE_DISTRIB where BUSINESS_UNIT = 'QUE01'
insert into NYCHH_Queens.dbo.RECV_HDR select * from NYCH.dbo.RECV_HDR where BUSINESS_UNIT = 'QUE01'
insert into NYCHH_Queens.dbo.RECV_LN_DISTRIB select * from NYCH.dbo.RECV_LN_DISTRIB where BUSINESS_UNIT = 'QUE01'
insert into NYCHH_Queens.dbo.RECV_LN_SHIP select * from NYCH.dbo.RECV_LN_SHIP where BUSINESS_UNIT = 'QUE01'
insert into NYCHH_Queens.dbo.REQ_HDR select * from NYCH.dbo.REQ_HDR where BUSINESS_UNIT = 'QUE01'
insert into NYCHH_Queens.dbo.REQ_LINE select * from NYCH.dbo.REQ_LINE where BUSINESS_UNIT = 'QUE01'
insert into NYCHH_Queens.dbo.REQ_LN_DISTRIB select * from NYCH.dbo.REQ_LN_DISTRIB where BUSINESS_UNIT = 'QUE01'
insert into NYCHH_Queens.dbo.REQ_LINE_SHIP select * from NYCH.dbo.REQ_LINE_SHIP where BUSINESS_UNIT = 'QUE01'
insert into NYCHH_Queens.dbo.MASTER_ITEM_TBL select * from NYCH.dbo.MASTER_ITEM_TBL
insert into NYCHH_Queens.dbo.LOCATION_TBL select * from NYCH.dbo.LOCATION_TBL
insert into NYCHH_Queens.dbo.MANUFACTURER select * from NYCH.dbo.MANUFACTURER
insert into NYCHH_Queens.dbo.DEPT_TBL select * from NYCH.dbo.DEPT_TBL
insert into NYCHH_Queens.dbo.GL_ACCOUNT_TBL select * from NYCH.dbo.GL_ACCOUNT_TBL
insert into NYCHH_Queens.dbo.ITM_VENDOR select * from NYCH.dbo.ITM_VENDOR
insert into NYCHH_Queens.dbo.ITEM_MFG select * from NYCH.dbo.ITEM_MFG
insert into NYCHH_Queens.dbo.PURCH_ITEM_BU select * from NYCH.dbo.PURCH_ITEM_BU
insert into NYCHH_Queens.dbo.VENDOR select * from NYCH.dbo.VENDOR
