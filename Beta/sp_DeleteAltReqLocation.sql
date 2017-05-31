if exists (select * from dbo.sysobjects where id = object_id(N'sp_DeleteAltReqLocation') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_DeleteAltReqLocation
GO

--exec sp_EditAltReqLocation 'TEST'

CREATE PROCEDURE sp_DeleteAltReqLocation
@LocationID varchar(12)


--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON
	DELETE FROM bluebin.ALT_REQ_LOCATION 
	WHERE [REQ_LOCATION] = @LocationID 


END
GO
grant exec on sp_DeleteAltReqLocation to appusers
GO
