--*****************************************************
--**************************SPROC**********************

if exists (select * from dbo.sysobjects where id = object_id(N'sp_EditHistoricalDimBinJoin') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_EditHistoricalDimBinJoin
GO

--exec sp_EditHistoricalDimBinJoin '6','1','NEW','ED SUTURE MOBILE SUPPLY','S2390'
--sp_SelectHistoricalDimBinJoin

CREATE PROCEDURE sp_EditHistoricalDimBinJoin
@HistoricalDimBinJoinID int,
@FacilityID int,
@OldLocationID varchar(10),
@OldLocationName varchar(30),
@NewLocationID varchar(10)

--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON
	
	Update 
	bluebin.HistoricalDimBinJoin 
	set 
	FacilityID = @FacilityID,
	OldLocationID = @OldLocationID,
	OldLocationName = @OldLocationName,
	NewLocationID = @NewLocationID, 
	[LastUpdated]= getdate()
	where HistoricalDimBinJoinID = @HistoricalDimBinJoinID
	
END

GO
grant exec on sp_EditHistoricalDimBinJoin to appusers
GO