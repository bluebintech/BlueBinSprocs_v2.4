--*****************************************************
--**************************SPROC**********************

if exists (Select * from dbo.sysobjects where id = object_id(N'sp_DeleteHistoricalDimBinJoin') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_DeleteHistoricalDimBinJoin
GO

--exec sp_DeleteHistoricalDimBinJoin ''

CREATE PROCEDURE sp_DeleteHistoricalDimBinJoin
@HistoricalDimBinJoinID int


--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON
	delete from bluebin.[HistoricalDimBinJoin] where HistoricalDimBinJoinID = @HistoricalDimBinJoinID

END
GO
grant exec on sp_DeleteHistoricalDimBinJoin to appusers
GO