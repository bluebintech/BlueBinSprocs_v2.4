--*********************************************************************************************
--Tableau Sproc  These load data into the datasources for Tableau
--*********************************************************************************************

if exists (select * from dbo.sysobjects where id = object_id(N'tb_WarehouseHistory') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure tb_WarehouseHistory
GO

--exec tb_WarehouseHistory

CREATE PROCEDURE tb_WarehouseHistory

--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON

declare @History Table (Date date,FacilityName varchar(50),DollarsOnHand decimal(38,9),LocationID char(5),LocationName char(5),SKUS int,MonthEnd date)

insert into @History 
SELECT 
       Date,
	   FacilityName,
	   DollarsOnHand,
	   LocationID,
	   LocationName,
	   SKUS,
	   case when EOMONTH(getdate()) = EOMONTH(Date) then (select max(Date) from bluebin.FactWHHistory) else EOMONTH(Date) end as MonthEnd
FROM   bluebin.FactWHHistory

SELECT 
       a.Date,
	   a.FacilityName,
	   a.LocationID,
	   a.LocationName,
	   a.SKUS,
	   a.DollarsOnHand,
	   a.MonthEnd,
	   c.DollarsOnHand as MonthEndDollars
FROM @History  a
	inner join (
			SELECT 
				   b.Date,
				   b.FacilityName,
				   b.LocationID,
				   b.LocationName,
				   b.SKUS,
				   b.DollarsOnHand,
				   case when EOMONTH(getdate()) = EOMONTH(b.Date) then (select max(Date) from bluebin.FactWHHistory) else EOMONTH(b.Date) end as MonthEnd
			FROM   bluebin.FactWHHistory b 
			where b.DollarsOnHand > 0 and b.Date = case when EOMONTH(getdate()) = EOMONTH(b.Date) then (select max(Date) from bluebin.FactWHHistory) else EOMONTH(b.Date) end  
			) c on a.MonthEnd = c.Date and a.FacilityName = c.FacilityName and a.LocationID = c.LocationID
order by a.Date desc       



END
GO
grant exec on tb_WarehouseHistory to public
GO


/*
select * into #WHHistory from bluebin.FactWHHistory
drop table #WHHistory
delete from bluebin.FactWHHistory where Date < '2016-09-07'

declare @Date datetime,@Dollars decimal(38,9)
set @Date = '2016-06-02'
set @Dollars = '200000.00'

while @Date < '2016-09-07'
BEGIN
insert into bluebin.FactWHHistory (Date,FacilityName,LocationID,LocationName,DollarsOnHand)
select @Date,'CHOMP','1084','1084',@Dollars

insert into bluebin.FactWHHistory (Date,FacilityName,LocationID,LocationName,DollarsOnHand)
select @Date,'CHOMP','1083','1083',@Dollars


set @Date = DATEADD(day,1,@Date)
set @Dollars = @Dollars + '10000.00'

END

update bluebin.FactWHHistory set DollarsOnHand = '100000' where Date = '2016-08-31'
*/

