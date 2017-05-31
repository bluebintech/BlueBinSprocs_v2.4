if exists (select * from dbo.sysobjects where id = object_id(N'sp_EditAltReqLocation') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_EditAltReqLocation
GO

--exec sp_EditAltReqLocation 10,'3','Tableau',1


CREATE PROCEDURE sp_EditAltReqLocation
@LocationID varchar(12)
,@Company int
,@Active int


--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON
	Update bluebin.ALT_REQ_LOCATION 
	
	set [COMPANY] = @Company,
			[REQ_LOCATION] = @LocationID ,
				Active = @Active, 
					LastUpdated = getdate() 
	
	WHERE [REQ_LOCATION] = @LocationID 

END
GO
grant exec on sp_EditAltReqLocation to appusers
GO
