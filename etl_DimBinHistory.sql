--*********************************************************************************************
--Tableau Sproc  These load data into the datasources for Tableau
--*********************************************************************************************


if exists (select * from dbo.sysobjects where id = object_id(N'etl_DimBinHistory') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure etl_DimBinHistory
GO

--exec etl_DimBinHistory  update bluebin.DimBinHistory set Date = Date -1 

CREATE PROCEDURE [dbo].[etl_DimBinHistory] 
	
AS

/*
select * from bluebin.DimBinHistory order by Date desc
select * from bluebin.DimBin where LocationID = 'B6183' and ItemID = '700'  
select * from tableau.Kanban where LocationID = 'B6183' and ItemID = '700' and convert(Date,[Date]) = convert(Date,getdate()-1)
update bluebin.DimBinHistory set LastUpdated = getdate() -3 where DimBinHistoryID = 6161
truncate table bluebin.DimBinHistory

delete from bluebin.DimBinHistory where BinQty = LastBinQty and BinUOM = LastBinUOM and [Sequence] = [LastSequence] and Date <> (select min(Date) from bluebin.DimBinHistory)
delete from bluebin.DimBinHistory where [Date] = '2017-04-18'
exec etl_DimBinHistory

exec tb_KanbansAdjusted
exec tb_KanbansAdjustedHB
select * from bluebin.DimBinHistory where [Date] = '2017-04-17' and (BinQty <> LastBinQty or BinUOM <> LastBinUOM or [Sequence] <> [LastSequence])
*/
Delete from bluebin.DimBinHistory where [Date] < convert(Date,getdate()-100)


IF (select count(*) from bluebin.DimBinHistory) < 1
BEGIN
--insert into bluebin.DimBinHistory ([Date],BinKey,FacilityID,LocationID,ItemID,BinQty,BinUOM,[Sequence],LastBinQty,LastBinUOM,[LastSequence]) 
--select distinct convert(Date,getdate()-2),BinKey,BinFacility,LocationID,ItemID,BinQty,BinUOM,BinSequence,BinQty,BinUOM,BinSequence from bluebin.DimBin
--where ItemID = '47532'
insert into bluebin.DimBinHistory ([Date],BinKey,FacilityID,LocationID,ItemID,BinQty,BinUOM,[Sequence],LastBinQty,LastBinUOM,[LastSequence]) 
select distinct convert(Date,getdate()-1),BinKey,BinFacility,LocationID,ItemID,BinQty,BinUOM,BinSequence,BinQty,BinUOM,BinSequence from bluebin.DimBin
--where ItemID = '256'
END

if not exists (select * from bluebin.DimBinHistory where [Date] = convert(Date,getdate()-1))
BEGIN

insert into bluebin.DimBinHistory ([Date],BinKey,FacilityID,LocationID,ItemID,BinQty,BinUOM,[Sequence],LastBinQty,LastBinUOM,[LastSequence]) 
select convert(Date,getdate()-1),db.BinKey,db.BinFacility,db.LocationID,db.ItemID,convert(int,db.BinQty),db.BinUOM,db.BinSequence,ISNULL(dbh.BinQty,0),ISNULL(dbh.BinUOM,'N/A'),ISNULL(dbh.Sequence,'N/A')
from bluebin.DimBin db
left join 
	(select distinct dbh.[Date],dbh.BinKey,dbh.FacilityID,dbh.LocationID,dbh.ItemID,dbh.BinQty,dbh.BinUOM,dbh.[Sequence] 
			from bluebin.DimBinHistory dbh
			inner join (select FacilityID,LocationID,ItemID,max(Date) as LastDate from bluebin.DimBinHistory group by FacilityID,LocationID,ItemID) mmax 
							on dbh.FacilityID = mmax.FacilityID and dbh.LocationID = mmax.LocationID and dbh.ItemID = mmax.ItemID and dbh.[Date] = mmax.LastDate
			--where [Date] = convert(Date,getdate()-2)
			) dbh on db.BinFacility = dbh.FacilityID and db.LocationID = dbh.LocationID and db.ItemID = dbh.ItemID
where convert(int,db.BinQty) <> ISNULL(dbh.BinQty,0) or db.BinUOM <> ISNULL(dbh.BinUOM,'N/A') or db.BinSequence <> ISNULL(dbh.Sequence,'N/A')

END


GO
UPDATE etl.JobSteps
SET LastModifiedDate = GETDATE()
WHERE StepName = 'DimBinHistory'

GO
grant exec on etl_DimBinHistory to public
GO
