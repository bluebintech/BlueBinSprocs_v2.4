
--*****************************************************
--**************************SPROC**********************

if exists (select * from dbo.sysobjects where id = object_id(N'sp_DeleteTimeStudyBinFill') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_DeleteTimeStudyBinFill
GO

--exec sp_DeleteTimeStudyBinFill 'TEST'

CREATE PROCEDURE sp_DeleteTimeStudyBinFill
@TimeStudyBinFillID int



--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON
	
UPDATE bluebin.[TimeStudyBinFill] 
set Active = 0, MostRecent = 0
WHERE [TimeStudyBinFillID] = @TimeStudyBinFillID 
				

END
GO
grant exec on sp_DeleteTimeStudyBinFill to appusers
GO
