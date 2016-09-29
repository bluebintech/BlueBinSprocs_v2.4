if exists (select * from dbo.sysobjects where id = object_id(N'tb_LineVolume') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure tb_LineVolume
GO

--exec tb_LineVolume

CREATE PROCEDURE tb_LineVolume


AS
BEGIN
SET NOCOUNT ON


--SELECT 
--a.COMPANY,
--df.FacilityName,
--CREATION_DATE   AS Date,
--       CASE
--         WHEN LEFT(a.REQ_LOCATION, 2) IN (SELECT ConfigValue
--                                          FROM   [bluebin].[Config]
--                                          WHERE  ConfigName = 'REQ_LOCATION') 
--											or 
--										  a.REQ_LOCATION in (Select REQ_LOCATION from bluebin.ALT_REQ_LOCATION) 
--										  THEN 'BlueBin'
--         ELSE 'Non BlueBin'
--       END             AS LineType,
--       b.ISS_ACCT_UNIT AS AcctUnit,
--       ISNULL(c.DESCRIPTION,'Unknown')   AS AcctUnitName,
--       a.REQ_LOCATION  AS Location,
--       b.NAME          AS LocationName,
--       1               AS LineCount

--FROM   REQLINE a
--       INNER JOIN RQLOC b
--               ON a.COMPANY = b.COMPANY
--                  AND a.REQ_LOCATION = b.REQ_LOCATION
--       LEFT JOIN GLNAMES c
--               ON b.COMPANY = c.COMPANY
--                  AND b.ISS_ACCT_UNIT = c.ACCT_UNIT 
--	   INNER JOIN bluebin.DimFacility df on rtrim(a.COMPANY) = rtrim(df.FacilityID)
--order by 2

SELECT 
'' AS COMPANY,
'' AS FacilityName,
'' AS Date,
'' AS LineType,
'' AS AcctUnit,
'' AS AcctUnitName,
'' AS Location,
'' AS LocationName,
       1               AS LineCount




END
GO
grant exec on tb_LineVolume to public
GO

