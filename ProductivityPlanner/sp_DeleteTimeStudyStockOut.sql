
--*****************************************************
--**************************SPROC**********************

if exists (select * from dbo.sysobjects where id = object_id(N'sp_DeleteTimeStudyStockOut') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_DeleteTimeStudyStockOut
GO

--exec sp_DeleteTimeStudyStockOut 'TEST'

CREATE PROCEDURE sp_DeleteTimeStudyStockOut
@TimeStudyStockOutID int



--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON
	
UPDATE bluebin.[TimeStudyStockOut] 
set Active = 0, MostRecent = 0
WHERE [TimeStudyStockOutID] = @TimeStudyStockOutID 
				

END
GO
grant exec on sp_DeleteTimeStudyStockOut to appusers
GO
