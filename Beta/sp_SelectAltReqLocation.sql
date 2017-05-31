if exists (select * from dbo.sysobjects where id = object_id(N'sp_SelectAltReqLocation') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_SelectAltReqLocation
GO

--exec sp_SelectAltReqLocation ''

CREATE PROCEDURE sp_SelectAltReqLocation
@Location varchar(10)

--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON


Select COMPANY,REQ_LOCATION,Active,LastUpdated from bluebin.ALT_REQ_LOCATION 
where
REQ_LOCATION like '%' + @Location + '%' 
END

GO
grant exec on sp_SelectAltReqLocation to appusers
GO