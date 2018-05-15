--*****************************************************
--**************************SPROC**********************
--Updated GB 201820 Added ServiceTimes

if exists (select * from dbo.sysobjects where id = object_id(N'sp_EditHistoricalDimBinJoin') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_EditHistoricalDimBinJoin
GO

--exec sp_EditHistoricalDimBinJoin '5','NEW','TestOld4',61,'BB004',61
--sp_SelectHistoricalDimBinJoin  select * from bluebin.HistoricalDimBinJoin

CREATE PROCEDURE sp_EditHistoricalDimBinJoin
@HistoricalDimBinJoinID int,
@OldLocationID varchar(10),
@OldLocationName varchar(30),
@OldLocationServiceTime int,
@NewLocationID varchar(10),
@NewLocationServiceTime int

--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON
	
	Update 
	bluebin.HistoricalDimBinJoin 
	set 
	OldLocationID = @OldLocationID,
	OldLocationName = @OldLocationName,
	NewLocationID = @NewLocationID, 
	[LastUpdated]= getdate(),
	OldLocationServiceTime = @OldLocationServiceTime,
	NewLocationServiceTime = @NewLocationServiceTime
	where HistoricalDimBinJoinID = @HistoricalDimBinJoinID
	
END

GO
grant exec on sp_EditHistoricalDimBinJoin to appusers
GO