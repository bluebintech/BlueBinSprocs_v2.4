--*****************************************************
--**************************SPROC**********************

if exists (select * from dbo.sysobjects where id = object_id(N'sp_SelectHistoricalDimBinJoin') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_SelectHistoricalDimBinJoin
GO

--exec sp_SelectHistoricalDimBinJoin

CREATE PROCEDURE sp_SelectHistoricalDimBinJoin


--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON
	SELECT 
	hdb.HistoricalDimBinJoinID,
	hdb.FacilityID,
	df.FacilityName,
	hdb.OldLocationID,
	hdb.OldLocationName,
	hdb.NewLocationID,
	dl.LocationName as NewLocationName,
	LastUpdated 
FROM bluebin.[HistoricalDimBinJoin] hdb
	inner join bluebin.DimFacility df on hdb.FacilityID = df.FacilityID
	inner join bluebin.DimLocation dl on hdb.FacilityID = dl.LocationFacility and rtrim(hdb.NewLocationID) = rtrim(dl.LocationID)
	--where Active like '%' + @Active + '%'
order by 
	hdb.FacilityID,
	df.FacilityName,
	hdb.OldLocationID,
	hdb.OldLocationName,
	hdb.NewLocationID,
	dl.LocationName
	
	

END
GO
grant exec on sp_SelectHistoricalDimBinJoin to appusers
GO


--*****************************************************
--**************************SPROC**********************

if exists (select * from dbo.sysobjects where id = object_id(N'sp_InsertHistoricalDimBinJoin') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_InsertHistoricalDimBinJoin
GO

--exec sp_InsertHistoricalDimBinJoin '6','BB001','NEW','Test Old'
--sp_SelectHistoricalDimBinJoin

CREATE PROCEDURE sp_InsertHistoricalDimBinJoin
@FacilityID int,
@NewLocationID varchar(10),
@OldLocationID varchar(10),
@OldLocationName varchar(30)


--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON
if not exists (select * from bluebin.HistoricalDimBinJoin where convert(varchar(2),FacilityID)+'-'+OldLocationID+'-'+NewLocationID in (select convert(varchar(2),@FacilityID)+'-'+@OldLocationID+'-'+@NewLocationID))

	BEGIN

	insert into bluebin.HistoricalDimBinJoin (FacilityID,OldLocationID,OldLocationName,NewLocationID,LastUpdated) 
	VALUES (@FacilityID,@OldLocationID,@OldLocationName,@NewLocationID,getdate())
	END
	

END

GO
grant exec on sp_InsertHistoricalDimBinJoin to appusers
GO


--*****************************************************
--**************************SPROC**********************

if exists (Select * from dbo.sysobjects where id = object_id(N'sp_DeleteHistoricalDimBinJoin') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_DeleteHistoricalDimBinJoin
GO

--exec sp_DeleteHistoricalDimBinJoin '1'

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








declare @version varchar(50) = '2.4.20171024' --Update Version Number here


if not exists (select * from bluebin.Config where ConfigName = 'Version')
BEGIN
insert into bluebin.Config (ConfigName,ConfigValue,ConfigType,Active,LastUpdated) VALUES ('Version',@version,'DMS',1,getdate())
END
ELSE
Update bluebin.Config set ConfigValue = @version where ConfigName = 'Version'

Print 'Version Updated to ' + @version
Print 'DB: ' + DB_NAME() + ' updated'
GO