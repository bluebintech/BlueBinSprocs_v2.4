

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
k.OrderDate as CREATION_DATE,
@Facility as COMPANY,
df.FacilityName,
k.LocationID as REQ_LOCATION,
k.OrderNum as REQ_NUMBER,
k.LineNum as Lines,
'BlueBin' as NAME,
dl.BlueBinFlag
from tableau.Kanban k
inner join bluebin.DimLocation dl on @Facility = rtrim(dl.LocationFacility) and k.LocationID = dl.LocationID
inner join bluebin.DimFacility df on @Facility = rtrim(df.FacilityID)
--left join REQUESTER r on rh.REQUESTER = r.REQUESTER and rq.COMPANY = r.COMPANY
where k.OrderDate > getdate()-15 and Scan > 0



GO
grant exec on tb_OrderVolume to public
GO
