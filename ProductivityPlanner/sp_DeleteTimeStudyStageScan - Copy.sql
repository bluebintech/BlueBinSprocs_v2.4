
--*****************************************************
--**************************SPROC**********************

if exists (select * from dbo.sysobjects where id = object_id(N'sp_DeleteTimeStudyStageScan') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_DeleteTimeStudyStageScan
GO

--exec sp_DeleteTimeStudyStageScan 'TEST'

CREATE PROCEDURE sp_DeleteTimeStudyStageScan
@TimeStudyStageScanID int



--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON
	
UPDATE bluebin.[TimeStudyStageScan] 
set Active = 0, MostRecent = 0
WHERE [TimeStudyStageScanID] = @TimeStudyStageScanID 
				

END
GO
grant exec on sp_DeleteTimeStudyStageScan to appusers
GO
