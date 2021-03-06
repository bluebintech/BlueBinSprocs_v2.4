--*********************************************************************************************
--Tableau Sproc  These load data into the datasources for Tableau
--*********************************************************************************************

if exists (select * from dbo.sysobjects where id = object_id(N'tb_KanbansAdjusted') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure tb_KanbansAdjusted
GO

--exec tb_KanbansAdjusted  
/*
declare @ItemID varchar(32) = '07018'
declare @Location varchar(5) = 'BK004'
select * from bluebin.DimBinHistory where ItemID = @ItemID and LocationID = @Location
select * from bluebin.DimBin where ItemID = @ItemID and LocationID = @Location
select * from tableau.Kanban where ItemID = @ItemID and LocationID = @Location and [Date] > getdate() -7 and Scan = 1
*/

CREATE PROCEDURE [dbo].[tb_KanbansAdjusted] 
	
AS

BEGIN


select 
[Week]
,[Date]
,FacilityID
,FacilityName
,LocationID
,LocationName
,ItemID
,ItemDescription
,BinQty
,case when BinOrderChange = 1 and BinChange = 0 then BinQty else YestBinQty end as YestBinQty
,BinUOM
,case when BinOrderChange = 1 and BinChange = 0 then BinUOM else YestBinUOM end as YestBinUOM
,Sequence
,case when BinOrderChange = 1 and BinChange = 0 then Sequence else YestSequence end as YestSequence
,OrderQty
,OrderUOM
,BinChange
,BinOrderChange
,BinCurrentStatus


 from 
(
select 
case when a.OrderQty is not null and a.OrderQty <> a.BinQty and a.OrderUOM = a.BinUOM and db.BinCurrentStatus <> 'Never Scanned' and a.OrderQty <> 0  
	then DATEPART(WEEK,a.[Date]) else DATEPART(WEEK,dbh.[Date]) end as [Week]
,case when a.OrderQty is not null and a.OrderQty <> a.BinQty and a.OrderUOM = a.BinUOM and db.BinCurrentStatus <> 'Never Scanned' and a.OrderQty <> 0  
	then a.Date else dbh.[Date] end as [Date]
--,dbh.[Date]-1 as Yesterday
,db.BinFacility as FacilityID
,df.FacilityName
,db.LocationID
,dl.LocationName
,db.ItemID
,di.ItemDescription
,db.BinQty as BinQty
,dbh.LastBinQty as YestBinQty
,db.BinUOM
,dbh.LastBinUOM as YestBinUOM
,db.BinSequence as Sequence
,dbh.LastSequence as YestSequence
,ISNULL(a.OrderQty,0) as OrderQty
,ISNULL(a.OrderUOM,'N/A') as OrderUOM
,case when (dbh.BinQty <> dbh.LastBinQty or dbh.Sequence <> dbh.LastSequence) and dbh.LastBinQty >= 1 and dbh.LastSequence <> 'N/A' then 1 else 0 end as BinChange
,case when a.OrderQty is not null and a.OrderQty <> a.BinQty and a.OrderUOM = a.BinUOM and db.BinCurrentStatus <> 'Never Scanned' and a.OrderQty <> 0  then 1 else 0 end as BinOrderChange
,db.BinCurrentStatus

from bluebin.DimBin db 
inner join bluebin.DimFacility df on db.BinFacility = df.FacilityID
inner join bluebin.DimLocation dl on db.LocationID = dl.LocationID
inner join bluebin.DimItem di on db.ItemID = di.ItemID

left join(select distinct dbh.[Date],dbh.BinKey,dbh.FacilityID,dbh.LocationID,dbh.ItemID,dbh.BinQty,dbh.BinUOM,dbh.[Sequence],dbh.LastBinQty,dbh.LastBinUOM,dbh.[LastSequence] 
			from bluebin.DimBinHistory dbh
			inner join (select FacilityID,LocationID,ItemID,max(Date) as LastDate from bluebin.DimBinHistory group by FacilityID,LocationID,ItemID) mmax 
							on dbh.FacilityID = mmax.FacilityID and dbh.LocationID = mmax.LocationID and dbh.ItemID = mmax.ItemID and dbh.[Date] = mmax.LastDate) dbh on db.BinFacility = dbh.FacilityID and db.LocationID = dbh.LocationID and db.ItemID = dbh.ItemID and dbh.[Date] >= getdate() -7

left join (select FacilityID,LocationID,ItemID,[Date],OrderQty,OrderUOM,BinUOM,BinQty from tableau.Kanban where Scan = 1 and OrderQty <> BinQty and OrderQty <> 0 and Date >= getdate() -7) a on db.BinFacility= a.FacilityID and db.LocationID = a.LocationID and db.ItemID = a.ItemID-- and a.[Date] >= dbh.LastDate


--where dbh.[Date] >= getdate() -7 
--and a.LocationID = 'B7435' and a.ItemID = '30003' 
--order by dbh.FacilityID,dbh.LocationID,dbh.ItemID
) a
where BinChange = 1 or BinOrderChange = 1
group by 
Week,
Date,
FacilityID,
FacilityName,
LocationID,
LocationName,
ItemID,
ItemDescription,
BinQty,
YestBinQty,
BinUOM,
YestBinUOM,
Sequence,
YestSequence,
OrderQty,
OrderUOM,
BinChange,
BinOrderChange,
BinCurrentStatus
order by FacilityID,LocationID,ItemID





END
GO
grant exec on tb_KanbansAdjusted to public
GO

