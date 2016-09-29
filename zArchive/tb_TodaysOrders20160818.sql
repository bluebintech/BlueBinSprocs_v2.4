IF EXISTS ( SELECT  *
            FROM    sys.objects
            WHERE   object_id = OBJECT_ID(N'tb_TodaysOrders')
                    AND type IN ( N'P', N'PC' ) ) 

DROP PROCEDURE  tb_TodaysOrders
GO

CREATE PROCEDURE	tb_TodaysOrders
--exec tb_TodaysOrders  
AS

SET NOCOUNT on
;
With list as 
(
			select distinct
			rq.COMPANY,
			rq.REQ_LOCATION,
			dl.LocationName
			from REQLINE rq
			inner join bluebin.DimBin db on rq.COMPANY = db.BinFacility and rq.REQ_LOCATION = db.LocationID and rq.ITEM = db.ItemID  
			inner join bluebin.DimLocation dl on db.LocationID = dl.LocationID and dl.BlueBinFlag = 1
			inner join REQHEADER rh on rq.REQ_NUMBER = rh.REQ_NUMBER
			where rq.CREATION_DATE > getdate() -3  and rq.STATUS =9  and rq.KILL_QUANTITY = 0 
			)


select 
convert(datetime,(convert(DATE,getdate()-1)),112) as CREATION_DATE,
[list].COMPANY,
df.FacilityName as FacilityName,
[list].REQ_LOCATION,
[list].LocationName,
ISNULL([current].Lines,0) as TodayLines,
--ISNULL([past].Lines,0) as YestLines,
--CAST([past].Lines as decimal(6,2))/30,
--ROUND(CAST([past].Lines as decimal(6,2))/30,0),
CAST(ISNULL(ROUND(CAST([past].Lines as decimal(6,2))/30,0),0)as int) as YestLines,
case 
	when ISNULL([current].Lines,0) > CAST(ISNULL(ROUND(CAST([past].Lines as decimal(6,2))/30,0),0)as int) then 'UP' 
	when ISNULL([current].Lines,0) < CAST(ISNULL(ROUND(CAST([past].Lines as decimal(6,2))/30,0),0)as int) then 'DOWN'
	else 'EVEN' end as Trend

from 

list
inner join bluebin.DimFacility df on list.COMPANY = df.FacilityID		
--Yesterdays Data
--left join(
--			select 
--			rq.CREATION_DATE as CREATION_DATE,
--			rq.COMPANY,
--			rq.REQ_LOCATION,
--			count(*) as Lines

--			from REQLINE rq
--			inner join bluebin.DimBin db on rq.COMPANY = db.BinFacility and rq.REQ_LOCATION = db.LocationID and rq.ITEM = db.ItemID  
--			inner join REQHEADER rh on rq.REQ_NUMBER = rh.REQ_NUMBER
--			where rq.CREATION_DATE > getdate() -3  and rq.CREATION_DATE < getdate() -2 and rq.STATUS =9  and rq.KILL_QUANTITY = 0 
--			group by
--			rq.CREATION_DATE,
--			rq.COMPANY,
--			rq.REQ_LOCATION
--			) [past] on list.COMPANY = past.COMPANY and list.REQ_LOCATION = past.REQ_LOCATION
left join(
			select 
			--rq.CREATION_DATE as CREATION_DATE,
			rq.COMPANY,
			rq.REQ_LOCATION,
			count(*) as Lines

			from REQLINE rq
			inner join bluebin.DimBin db on rq.COMPANY = db.BinFacility and rq.REQ_LOCATION = db.LocationID and rq.ITEM = db.ItemID  
			inner join REQHEADER rh on rq.REQ_NUMBER = rh.REQ_NUMBER
			where rq.CREATION_DATE > getdate() -32  and rq.CREATION_DATE < getdate() -2 and rq.STATUS =9  and rq.KILL_QUANTITY = 0 
			group by
			--rq.CREATION_DATE,
			rq.COMPANY,
			rq.REQ_LOCATION
			) [past] on list.COMPANY = past.COMPANY and list.REQ_LOCATION = past.REQ_LOCATION
			
--Todays Data
left join (
select 
			rq.CREATION_DATE as CREATION_DATE,
			rq.COMPANY,
			rq.REQ_LOCATION,
			count(*) as Lines
			from REQLINE rq
			inner join bluebin.DimBin db on rq.COMPANY = db.BinFacility and rq.REQ_LOCATION = db.LocationID and rq.ITEM = db.ItemID  
			inner join REQHEADER rh on rq.REQ_NUMBER = rh.REQ_NUMBER
			where rq.CREATION_DATE > getdate() -2 and rq.CREATION_DATE < getdate() -1 and rq.STATUS =9 and rq.KILL_QUANTITY = 0  
					
			group by
			rq.CREATION_DATE,
			rq.COMPANY,
			rq.REQ_LOCATION
			) [current] on list.COMPANY = [current].COMPANY and list.REQ_LOCATION = [current].REQ_LOCATION
 
order by [list].REQ_LOCATION


GO
grant exec on tb_TodaysOrders to public
GO


