--*********************************************************************************************
--Tableau Sproc  These load data into the datasources for Tableau
--*********************************************************************************************

if exists (select * from dbo.sysobjects where id = object_id(N'tb_ROILineVolume') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure tb_ROILineVolume
GO

--exec tb_ROILineVolume
--select * from bluebin.HistoricalDimBinJoin
CREATE PROCEDURE tb_ROILineVolume


AS
BEGIN
SET NOCOUNT ON
select 
rq.COMPANY,
df.FacilityName,
rq.CREATION_DATE as [Date],
'BlueBin' AS LineType,
rq.REQ_LOCATION as Location,
dl.LocationName,
case when hdbj.OldLocationID = 'NEW' then hdbj.NewLocationID + '(N)'
else hdbj.OldLocationID + '(O) & ' +  hdbj.NewLocationID + '(N)' 
end as LocationLinking,
1 AS LineCount

from REQLINE rq
INNER JOIN RQLOC b ON rq.COMPANY = b.COMPANY AND rq.REQ_LOCATION = b.REQ_LOCATION
inner join bluebin.DimFacility df on rtrim(rq.COMPANY) = rtrim(df.FacilityID)
inner join REQHEADER rh on rq.REQ_NUMBER = rh.REQ_NUMBER
inner join bluebin.DimLocation dl on rtrim(rq.COMPANY) = rtrim(dl.LocationFacility) and rq.REQ_LOCATION = dl.LocationID
inner join bluebin.HistoricalDimBinJoin hdbj on rtrim(rq.COMPANY) = rtrim(hdbj.FacilityID) and rq.REQ_LOCATION = hdbj.NewLocationID
where rq.CREATION_DATE > = COALESCE(hdbj.GoLiveDate,'1900-01-01')

UNION ALL

select 
rq.COMPANY,
df.FacilityName,
rq.CREATION_DATE as [Date],
'Non BlueBin' AS LineType,
rq.REQ_LOCATION as Location,
hdbj.OldLocationName as LocationName,
case when hdbj.OldLocationID = 'NEW' then hdbj.NewLocationID + '(N)'
else hdbj.OldLocationID + '(O) & ' +  hdbj.NewLocationID + '(N)' 
end as LocationLinking,
1 AS LineCount

from REQLINE rq
INNER JOIN RQLOC b ON rq.COMPANY = b.COMPANY AND rq.REQ_LOCATION = b.REQ_LOCATION
inner join bluebin.DimFacility df on rtrim(rq.COMPANY) = rtrim(df.FacilityID)
inner join REQHEADER rh on rq.REQ_NUMBER = rh.REQ_NUMBER
inner join bluebin.HistoricalDimBinJoin hdbj on rtrim(rq.COMPANY) = rtrim(hdbj.FacilityID) and rq.REQ_LOCATION = hdbj.OldLocationID
where rq.CREATION_DATE < COALESCE(hdbj.GoLiveDate,getdate()+1)


END
GO
grant exec on tb_ROILineVolume to public
GO

