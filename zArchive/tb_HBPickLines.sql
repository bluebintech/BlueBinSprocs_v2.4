if exists (select * from dbo.sysobjects where id = object_id(N'tb_HBPickLines') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure tb_HBPickLines
GO
--exec tb_HBPickLines
CREATE PROCEDURE tb_HBPickLines
AS
BEGIN
SET NOCOUNT ON


SELECT 
df.FacilityName,
fi.LocationID,
Cast(fi.IssueDate AS DATE) AS Date,
Count(*) AS PickLine

FROM   (
SELECT COMPANY                                                                                AS FacilityKey,
       a.LOCATION as LocationID,
       c.LocationFacility                                                                     AS ShipFacilityKey,                                                                   
       d.ItemKey,
       SYSTEM_CD as SourceSystem,
       CASE
         WHEN SYSTEM_CD = 'RQ' THEN DOCUMENT
         ELSE ''
       END                                                                                    AS ReqNumber,
       CASE
         WHEN SYSTEM_CD = 'RQ' THEN LINE_NBR
         ELSE ''
       END                                                                                    AS ReqLineNumber,
       Cast(CONVERT(VARCHAR, TRANS_DATE, 101) + ' '
            + LEFT(RIGHT('00000' + CONVERT(VARCHAR, ACTUAL_TIME), 4), 2)
            + ':'
            + Substring(RIGHT('00000' + CONVERT(VARCHAR, ACTUAL_TIME), 4), 3, 2) AS DATETIME) AS IssueDate,
       TRAN_UOM as UOM,
       TRAN_UOM_MULT as UOMMult,
       -QUANTITY                                                                              AS IssueQty,
       CASE
         WHEN SYSTEM_CD = 'IC' THEN 1
         ELSE 0
       END                                                                                    AS StatCall,
       1                                                                                      AS IssueCount
FROM   ICTRANS a
       LEFT JOIN bluebin.DimLocation b
               ON a.LOCATION = b.LocationID
                  AND a.COMPANY = b.LocationFacility
       LEFT JOIN bluebin.DimLocation c
               ON a.FROM_TO_LOC = c.LocationID
                  AND a.FROM_TO_CMPY = c.LocationFacility
		LEFT JOIN bluebin.DimItem d
               ON a.ITEM = d.ItemID
WHERE  DOC_TYPE = 'IS'  
and a.DOCUMENT not like '%[A-Z]%' 
and TRANS_DATE > getdate() -15
and a.LOCATION in (select ConfigValue from bluebin.Config where ConfigName = 'LOCATION')) fi

inner join bluebin.DimFacility df on fi.ShipFacilityKey = df.FacilityID
where fi.IssueDate > getdate() -15
GROUP  BY df.FacilityName,fi.LocationID,Cast(fi.IssueDate AS DATE)
order by 1,2,3


END
GO
grant exec on tb_HBPickLines to public
GO
