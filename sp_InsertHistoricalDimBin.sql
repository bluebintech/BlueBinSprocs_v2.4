--*****************************************************
--**************************SPROC**********************

if exists (select * from dbo.sysobjects where id = object_id(N'sp_InsertHistoricalDimBinJoin') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_InsertHistoricalDimBinJoin
GO

--exec sp_InsertHistoricalDimBinJoin 'TEST',''

CREATE PROCEDURE sp_InsertHistoricalDimBinJoin
@FacilityID int,
@OldLocationID varchar(10),
@OldLocationName varchar(30),
@NewLocationID varchar(10)


--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON
if not exists (select * from bluebin.HistoricalDimBinJoin where convert(varchar(2),FacilityID)+'-'+OldLocationID+'-'+NewLocationID = (convert(varchar(2),@FacilityID)+'-'+@OldLocationID+'-'+@NewLocationID))
BEGIN

insert into qcn.HistoricalDimBinJoin (Status,Active,LastUpdated,Description) VALUES (@Status,1,getdate(),@Description)

END
GO

GO
grant exec on sp_InsertHistoricalDimBinJoin to appusers
GO
