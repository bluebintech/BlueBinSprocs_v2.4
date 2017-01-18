--*********************************************************************************************
--Tableau Sproc  These load data into the datasources for Tableau
--*********************************************************************************************


if exists (select * from dbo.sysobjects where id = object_id(N'etl_DimBinHistory') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure etl_DimBinHistory
GO

--exec etl_DimBinHistory

CREATE PROCEDURE [dbo].[etl_DimBinHistory] 
	
AS

/*
select * from bluebin.DimBinHistory where Date = '2016-12-07' and LastBinQty <> BinQty LastSequence = 'N/A' order by FacilityID,LocationID,ItemID,Date
select * from bluebin.DimBin where LocationID = 'B6183' and ItemID = '700'  
select * from tableau.Kanban where LocationID = 'B6183' and ItemID = '700' and convert(Date,[Date]) = convert(Date,getdate()-1)
update bluebin.DimBinHistory set LastUpdated = getdate() -3 where DimBinHistoryID = 6161
truncate table bluebin.DimBinHistory
*/
Delete from bluebin.DimBinHistory where [Date] < convert(Date,getdate()-100)


IF (select count(*) from bluebin.DimBinHistory) < 1
BEGIN
insert into bluebin.DimBinHistory ([Date],BinKey,FacilityID,LocationID,ItemID,BinQty,BinUOM,[Sequence],LastBinQty,LastBinUOM,[LastSequence]) 
select convert(Date,getdate()-2),BinKey,BinFacility,LocationID,ItemID,BinQty,BinUOM,BinSequence,BinQty,BinUOM,BinSequence from bluebin.DimBin

insert into bluebin.DimBinHistory ([Date],BinKey,FacilityID,LocationID,ItemID,BinQty,BinUOM,[Sequence],LastBinQty,LastBinUOM,[LastSequence]) 
select convert(Date,getdate()-1),BinKey,BinFacility,LocationID,ItemID,BinQty,BinUOM,BinSequence,BinQty,BinUOM,BinSequence from bluebin.DimBin
END

if not exists (select * from bluebin.DimBinHistory where [Date] = convert(Date,getdate()-1))
BEGIN

insert into bluebin.DimBinHistory ([Date],BinKey,FacilityID,LocationID,ItemID,BinQty,BinUOM,[Sequence],LastBinQty,LastBinUOM,[LastSequence]) 
select convert(Date,getdate()-1),db.BinKey,db.BinFacility,db.LocationID,db.ItemID,convert(int,db.BinQty),db.BinUOM,db.BinSequence,ISNULL(dbh.BinQty,0),ISNULL(dbh.BinUOM,'N/A'),ISNULL(dbh.Sequence,'N/A')
from bluebin.DimBin db
left join 
	(select distinct [Date],BinKey,FacilityID,LocationID,ItemID,BinQty,BinUOM,[Sequence] from bluebin.DimBinHistory where [Date] = convert(Date,getdate()-2)) dbh on db.BinFacility = dbh.FacilityID and db.LocationID = dbh.LocationID and db.ItemID = dbh.ItemID

END


GO
UPDATE etl.JobSteps
SET LastModifiedDate = GETDATE()
WHERE StepName = 'DimBinHistory'

GO
grant exec on etl_DimBinHistory to public
GO
