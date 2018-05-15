--*********************************************************************************************
--Tableau Sproc  These load data into the datasources for Tableau
--*********************************************************************************************
--Updated GB 20180426 maxed out resources

if exists (select * from dbo.sysobjects where id = object_id(N'tb_LineVolume') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure tb_LineVolume
GO

--exec tb_LineVolume

CREATE PROCEDURE tb_LineVolume


AS
BEGIN
SET NOCOUNT ON
select 
rq.COMPANY,
df.FacilityName,
rq.CREATION_DATE as [Date],
case 
	when dl.BlueBinFlag = 1 
	then 'BlueBin' 
	ELSE 'Non BlueBin' 
	end AS LineType,
b.ISS_ACCT_UNIT AS AcctUnit,
ISNULL(c.DESCRIPTION,'Unknown') AS AcctUnitName,
rq.REQ_LOCATION as Location,
dl.LocationName,
rq.REQ_NUMBER,rq.LINE_NBR,
1 AS LineCount,
max(isnull(r.NAME,'Unknown')) as NAME

from REQLINE rq
INNER JOIN RQLOC b ON rq.COMPANY = b.COMPANY AND rq.REQ_LOCATION = b.REQ_LOCATION
LEFT JOIN GLNAMES c ON b.COMPANY = c.COMPANY AND b.ISS_ACCT_UNIT = c.ACCT_UNIT
inner join bluebin.DimFacility df on rtrim(rq.COMPANY) = rtrim(df.FacilityID)
inner join REQHEADER rh on rq.REQ_NUMBER = rh.REQ_NUMBER
inner join bluebin.DimLocation dl on rtrim(rq.COMPANY) = rtrim(dl.LocationFacility) and rq.REQ_LOCATION = dl.LocationID
left join REQUESTER r on rh.REQUESTER = r.REQUESTER and rq.COMPANY = r.COMPANY
--where df.FacilityName = 'Nemours-Orlando' and rq.CREATION_DATE = '2018-04-20 00:00:00.000'
group by
rq.COMPANY,
df.FacilityName,
rq.CREATION_DATE,
case 
	when dl.BlueBinFlag = 1 
	then 'BlueBin' 
	ELSE 'Non BlueBin' 
	end,
b.ISS_ACCT_UNIT,
ISNULL(c.DESCRIPTION,'Unknown'),
rq.REQ_LOCATION,
dl.LocationName,
rq.REQ_NUMBER,rq.LINE_NBR

order by 2


END
GO
grant exec on tb_LineVolume to public
GO

