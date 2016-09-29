

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
declare @Facility int
   select @Facility = ConfigValue from bluebin.Config where ConfigName = 'PS_DefaultFacility'
  

select 
rh.REQ_DT as CREATION_DATE,
@Facility as COMPANY,
df.FacilityName,
rd.LOCATION as REQ_LOCATION,
rq.REQ_ID,
rq.LINE_NBR as Lines,
rh.REQUESTOR_ID as Name,
dl.BlueBinFlag
from REQ_LINE rq
INNER JOIN REQ_LN_DISTRIB rd on rq.REQ_ID = rd.REQ_ID
inner join REQ_HDR rh on rq.REQ_ID = rh.REQ_ID
inner join bluebin.DimLocation dl on @Facility = rtrim(dl.LocationFacility) and rd.LOCATION = dl.LocationID
inner join bluebin.DimFacility df on @Facility = rtrim(df.FacilityID)
--left join REQUESTER r on rh.REQUESTER = r.REQUESTER and rq.COMPANY = r.COMPANY
where rh.REQ_DT > getdate()-15



GO
grant exec on tb_OrderVolume to public
GO
