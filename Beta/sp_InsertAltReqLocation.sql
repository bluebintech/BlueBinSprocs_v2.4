if exists (select * from dbo.sysobjects where id = object_id(N'sp_InsertAltReqLocation') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_InsertAltReqLocation
GO

--exec sp_InsertAltReqLocation 'TEST'

CREATE PROCEDURE sp_InsertAltReqLocation
@LocationID varchar(12)
,@Company int



--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON
if exists(select * from bluebin.ALT_REQ_LOCATION where REQ_LOCATION = @LocationID)
BEGIN
GOTO THEEND
END
insert into bluebin.ALT_REQ_LOCATION (COMPANY,LocationID,Active,LastUpdated) VALUES (@Company,@LocationID,1,getdate())

END
THEEND:

GO
grant exec on sp_InsertAltReqLocation to appusers
GO