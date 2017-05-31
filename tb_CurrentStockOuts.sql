--*********************************************************************************************
--Tableau Sproc  These load data into the datasources for Tableau
--*********************************************************************************************

IF EXISTS ( SELECT  *
            FROM    sys.objects
            WHERE   object_id = OBJECT_ID(N'tb_CurrentStockOuts')
                    AND type IN ( N'P', N'PC' ) ) 

--exec tb_CurrentStockOuts
DROP PROCEDURE  tb_CurrentStockOuts
GO

CREATE PROCEDURE tb_CurrentStockOuts

AS

--declare @A Table ([Date] Date,FacilityID int,FacilityName varchar(255),LocationID varchar(10),LocationName varchar(30),ItemID varchar(32),ItemDescription varchar(30),OrderDate datetime,OrderNum varchar(10),LineNum int,OrderQty int)

--insert into @A
select 
[Date],
FacilityID,
FacilityName,
LocationID,
LocationName,
ItemID,
ItemDescription,
OrderDate,
OrderNum,
LineNum,
OrderQty
from tableau.Kanban

where [Date] > getdate() -90 and 
StockOut = 1  and ScanHistseq > (select ConfigValue from bluebin.Config where ConfigName = 'ScanThreshold') and OrderCloseDate is null

UNION

select
scan.Date,
scan.FacilityID,
df.FacilityName,
scan.LocationID,
dl.LocationName,
scan.ItemID,
di.ItemDescription,
scan.Date as OrderDate,
convert(varchar(10),scan.ScanBatchID) as OrderNum,
max(sl.Line) as LineNum,
max(sl.Qty) as OrderQty
from (
select convert(Date,sl.ScanDateTime,112) as Date,sb.ScanBatchID,sb.FacilityID,sb.LocationID,sl.ItemID,count(*) as Ct
from scan.ScanLine sl
inner join scan.ScanBatch sb on sl.ScanBatchID = sb.ScanBatchID
where sb.ScanType = 'TrayOrder' and sb.Active = 1 and convert(Date,sl.ScanDateTime,112) = convert(Date,getdate(),112)
group by convert(Date,sl.ScanDateTime,112),sb.ScanBatchID,sb.FacilityID,sb.LocationID,sl.ItemID
) scan
inner join scan.ScanLine sl on scan.ScanBatchID = sl.ScanBatchID and scan.ItemID = sl.ItemID and scan.Ct > 1
inner join bluebin.DimFacility df on scan.FacilityID = df.FacilityID
inner join bluebin.DimLocation dl on scan.LocationID = dl.LocationID
inner join bluebin.DimItem di on scan.ItemID = di.ItemID
where scan.Ct > 1
group by scan.Date,
scan.FacilityID,
df.FacilityName,
scan.LocationID,
dl.LocationName,
scan.ItemID,
di.ItemDescription,
scan.Date,
scan.ScanBatchID

order by LocationID


--if not exists (select * from @A)
--BEGIN
--select 
--getdate() as [Date],
--'' as FacilityID,
--'' as FacilityName,
--'None' as LocationID,
--'None' as LocationName,
--'' as ItemID,
--'' as ItemDescription,
--'' as OrderDate,
--'' as OrderNum,
--'' as LineNum,
--'' as OrderQty
--END
--ELSE
--BEGIN
--select * from @A order by LocationID
--END
GO

grant exec on tb_CurrentStockOuts to public
GO