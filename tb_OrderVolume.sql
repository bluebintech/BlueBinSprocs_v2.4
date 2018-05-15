--*********************************************************************************************
--Tableau Sproc  These load data into the datasources for Tableau
--*********************************************************************************************
--Updated GB 20180426 maxed out resources

IF EXISTS ( SELECT  *
            FROM    sys.objects
            WHERE   object_id = OBJECT_ID(N'tb_OrderVolume')
                    AND type IN ( N'P', N'PC' ) ) 

DROP PROCEDURE  tb_OrderVolume
GO

CREATE PROCEDURE	tb_OrderVolume
--exec tb_OrderVolume  
AS

SET NOCOUNT on

select 
rq.CREATION_DATE,
rq.COMPANY,
df.FacilityName,
rq.REQ_LOCATION,
rq.REQ_NUMBER,rq.LINE_NBR,
rq.LINE_NBR as Lines,
max(isnull(r.NAME,'Unknown')) as NAME,
dl.BlueBinFlag
from REQLINE rq
inner join bluebin.DimLocation dl on rtrim(rq.COMPANY) = rtrim(dl.LocationFacility) and rq.REQ_LOCATION = dl.LocationID
inner join bluebin.DimFacility df on rtrim(rq.COMPANY) = rtrim(df.FacilityID)
inner join REQHEADER rh on rq.REQ_NUMBER = rh.REQ_NUMBER
left join REQUESTER r on rh.REQUESTER = r.REQUESTER and rq.COMPANY = r.COMPANY
where rq.CREATION_DATE > getdate()-15 
--and df.FacilityName = 'Nemours-Orlando' and rq.CREATION_DATE = '2018-04-20 00:00:00.000'

group by 
rq.CREATION_DATE,
rq.COMPANY,
df.FacilityName,
rq.REQ_LOCATION,
rq.REQ_NUMBER,
rq.LINE_NBR,
dl.BlueBinFlag

order by 2,rq.REQ_NUMBER,rq.LINE_NBR


GO
grant exec on tb_OrderVolume to public
GO
