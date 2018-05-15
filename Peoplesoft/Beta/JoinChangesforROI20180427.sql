ALTER table bluebin.HistoricalDimBinJoin ADD GoLiveDate datetime 
select * from bluebin.DimFacility

select * from bluebin.HistoricalDimBinJoin
select top 2* from NYCHH_Kings.bluebin.HistoricalDimBin
select top 2* from NYCHH_Lincoln.bluebin.HistoricalDimBin
select top 2* from NYCHH_Queens.bluebin.HistoricalDimBin
select top 2* from NYCH.bluebin.HistoricalDimBin

ALTER table bluebin.HistoricalDimBinJoin ADD GoLiveDate datetime 
select * from bluebin.DimFacility

truncate table NYCHH_Kings.bluebin.HistoricalDimBin
truncate table NYCHH_Lincoln.bluebin.HistoricalDimBin
truncate table NYCHH_Queens.bluebin.HistoricalDimBin
insert into NYCHH_Kings.bluebin.HistoricalDimBin select * from NYCH.bluebin.HistoricalDimBin where FacilityID = 3
insert into NYCHH_Lincoln.bluebin.HistoricalDimBin select * from NYCH.bluebin.HistoricalDimBin where FacilityID = 4
insert into NYCHH_Queens.bluebin.HistoricalDimBin select * from NYCH.bluebin.HistoricalDimBin where FacilityID = 5

insert into bluebin.HistoricalDimBinJoin
select LocationFacility,LocationID,LocationName,LocationID,getdate(),'','','2018-01-01' from bluebin.DimLocation where BlueBinFlag = 1


select * from bluebin.DimFacility
select * from tableau.Sourcing

update NYCHH_Kings.tableau.Sourcing set Company = '3'
update NYCHH_Lincoln.tableau.Sourcing set Company = '4'
update NYCHH_Queens.tableau.Sourcing set Company = '5'



With A as
(
select 
a.BUSINESS_UNIT,
a.LOCATION,
--a.PO_DT,
--a.PO_ID,
--a.LINE_NBR,
a.INV_ITEM_ID,
a.UNIT_OF_MEASURE,
AVG(convert(decimal(13,5),a.MERCHANDISE_AMT/a.QTY_PO)) as Cost ,
db.BinCurrentCost,
a.GoLiveDate
from (
		select 
		pld.BUSINESS_UNIT,
		pld.LOCATION,
		ph.PO_DT,
		pld.PO_ID,
		pld.LINE_NBR,
		pol.INV_ITEM_ID,
		pol.UNIT_OF_MEASURE,
		pld.MERCHANDISE_AMT,
		pld.QTY_PO,
		gld.GoLiveDate
		from PO_HDR ph
		INNER JOIN PO_LINE_DISTRIB pld on ph.BUSINESS_UNIT = pld.BUSINESS_UNIT and ph.PO_ID = pld.PO_ID
		INNER JOIN PO_LINE pol on pld.BUSINESS_UNIT = pol.BUSINESS_UNIT and pld.PO_ID = pol.PO_ID and pld.LINE_NBR = pol.LINE_NBR
		left join (select OldLocationID,GoLiveDate from bluebin.HistoricalDimBinJoin) gld on pld.LOCATION = gld.OldLocationID
		where ph.PO_DT >= gld.GoLiveDate and pol.INV_ITEM_ID <> '' --and pld.LOCATION = 'QHMB01AE06' 
		) a
		LEFT JOIN bluebin.DimBin db on a.BUSINESS_UNIT = (select FacilityName from bluebin.DimFacility where FacilityID = db.BinFacility) and a.LOCATION = db.LocationID and a.INV_ITEM_ID = db.ItemID and a.UNIT_OF_MEASURE = db.BinUOM
group by
a.BUSINESS_UNIT,
a.LOCATION,
a.INV_ITEM_ID,
a.UNIT_OF_MEASURE,
db.BinCurrentCost,
a.GoLiveDate
--order by a.INV_ITEM_ID
)

update bluebin.HistoricalDimBin set BinCurrentCost = A1.Cost from 
(select LOCATION,INV_ITEM_ID,UNIT_OF_MEASURE,Cost from A) as A1 
where LocationID = A1.LOCATION and ItemID = A1.INV_ITEM_ID and BinUOM = A1.UNIT_OF_MEASURE 

--select * from bluebin.DimBin where LocationID = 'QHMB01AE06'
--select * from bluebin.DimFacility

