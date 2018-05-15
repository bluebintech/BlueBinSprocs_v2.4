--*****************************************************
--**************************SPROC**********************
--Updated GB 201820 Added ServiceTimes

if exists (select * from dbo.sysobjects where id = object_id(N'sp_InsertHistoricalDimBinJoin') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_InsertHistoricalDimBinJoin
GO

--exec sp_InsertHistoricalDimBinJoin '6','New','TestOld2','BB002'

CREATE PROCEDURE sp_InsertHistoricalDimBinJoin
@FacilityID int,
@OldLocationID varchar(10),
@OldLocationName varchar(30),
@OldLocationServiceTime int,
@NewLocationID varchar(10),
@NewLocationServiceTime int


--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON

if not exists (select * from bluebin.HistoricalDimBinJoin where NewLocationID = @NewLocationID)
BEGIN

--select * from bluebin.HistoricalDimBinJoin
insert into bluebin.HistoricalDimBinJoin (FacilityID,OldLocationID,OldLocationName,OldLocationServiceTime,NewLocationID,NewLocationServiceTime,LastUpdated) 
VALUES (
@FacilityID,
@OldLocationID,
@OldLocationName,
@OldLocationServiceTime,
@NewLocationID,
@NewLocationServiceTime
,getdate()
)

END

END
GO
grant exec on sp_InsertHistoricalDimBinJoin to appusers
GO
