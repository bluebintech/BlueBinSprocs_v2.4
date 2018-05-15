

--*****************************************************
--**************************SPROC**********************
if exists (select * from dbo.sysobjects where id = object_id(N'sp_EditUser') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_EditUser
GO

--exec sp_EditConfig 'TEST'

CREATE PROCEDURE sp_EditUser
@BlueBinUserID int,
@UserLogin varchar(60),
@FirstName varchar(30), 
@LastName varchar(30), 
@MiddleName varchar(30), 
@Active int,
@Email varchar(60), 
@MustChangePassword int,
@PasswordExpires int,
@Password varchar(50),
@RoleName  varchar(30),
@Title varchar(50),
@GembaTier varchar(50),
@ERPUser varchar(60),
@AssignToQCN int


--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON
declare @newpwdHash varbinary(max),@message varchar(255), @fakelogin varchar(50)
set @newpwdHash = convert(varbinary(max),rtrim(@Password))

IF (@Password = '' or @Password is null)
	BEGIN
	update bluebin.BlueBinUser set 
        FirstName = @FirstName, 
        LastName = @LastName, 
        MiddleName = @MiddleName, 
        Active = @Active,
        Email = LOWER(@UserLogin),--@Email, 
        LastUpdated = getdate(), 
        MustChangePassword = @MustChangePassword,
        PasswordExpires = @PasswordExpires,
        RoleID = (select RoleID from bluebin.BlueBinRoles where RoleName = @RoleName),
		Title = @Title,
		GembaTier = @GembaTier,
		ERPUser = @ERPUser,
		AssignToQCN = @AssignToQCN
		Where BlueBinUserID = @BlueBinUserID
	END
	ELSE
	BEGIN
		update bluebin.BlueBinUser set 
        FirstName = @FirstName, 
        LastName = @LastName, 
        MiddleName = @MiddleName, 
        Active = @Active,
        Email = @UserLogin,--@Email, 
        LastUpdated = getdate(), 
        MustChangePassword = @MustChangePassword,
        PasswordExpires = @PasswordExpires,
		[Password] = (HASHBYTES('SHA1', @newpwdHash)),
        RoleID = (select RoleID from bluebin.BlueBinRoles where RoleName = @RoleName),
		Title = @Title,
		GembaTier = @GembaTier,
		ERPUser = @ERPUser,
		AssignToQCN = @AssignToQCN
		Where BlueBinUserID = @BlueBinUserID
	END

	;
	if @Active = 0
	BEGIN
	update bluebin.BlueBinResource set Active = @Active where Active = 1 and LastName +', ' + FirstName = @LastName +', ' + @FirstName 
	END

	;
	set @message = 'User Updated - '+ @UserLogin
	select @fakelogin = 'gbutler@bluebin.com'
	exec sp_InsertMasterLog @fakelogin,'Users',@message,@BlueBinUserID



END
GO
grant exec on sp_EditUser to appusers
GO


--*****************************************************
--**************************SPROC**********************


if exists (select * from dbo.sysobjects where id = object_id(N'sp_SelectConfigType') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_SelectConfigType
GO

--exec sp_SelectConfigType

CREATE PROCEDURE sp_SelectConfigType


--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON
	
	declare @ConfigType Table (ConfigType varchar(50))

	insert into @ConfigType (ConfigType) VALUES
	('Tableau'),
	('Reports'),
	('DMS'),
	('Interface'),
	('Other'),
	('TimeStudy'),
	('ROIandMGT')

	SELECT * from @ConfigType order by 1 asc
	

END
GO
grant exec on sp_SelectConfigType to appusers
GO

if not exists(select * from bluebin.Config where ConfigName = 'AvgCSPickTime')  
BEGIN
insert into bluebin.Config (ConfigName,ConfigValue,Active,LastUpdated,ConfigType,[Description])
select 'AvgCSPickTime','60',1,getdate(),'ROIandMGT','Average CS Pick Time'
END
GO
if not exists(select * from bluebin.Config where ConfigName = 'AvgStatServiceTime')  
BEGIN
insert into bluebin.Config (ConfigName,ConfigValue,Active,LastUpdated,ConfigType,[Description])
select 'AvgStatServiceTime','60',1,getdate(),'ROIandMGT','Average Stat Service Time'
END
GO
if not exists(select * from bluebin.Config where ConfigName = 'AvgStatWaitTime')  
BEGIN
insert into bluebin.Config (ConfigName,ConfigValue,Active,LastUpdated,ConfigType,[Description])
select 'AvgStatWaitTime','60',1,getdate(),'ROIandMGT','Average Stat Wait Time'
END
GO
if not exists(select * from bluebin.Config where ConfigName = 'AvgNewNodeServiceTime')  
BEGIN
insert into bluebin.Config (ConfigName,ConfigValue,Active,LastUpdated,ConfigType,[Description])
select 'AvgNewNodeServiceTime','60',1,getdate(),'ROIandMGT','Average New Node Service Time (default)'
END
GO
if not exists(select * from bluebin.Config where ConfigName = 'AvgOldNodeServiceTime')  
BEGIN
insert into bluebin.Config (ConfigName,ConfigValue,Active,LastUpdated,ConfigType,[Description])
select 'AvgOldNodeServiceTime','60',1,getdate(),'ROIandMGT','Average Old Node Service Time (default)'
END
GO

if not exists(select * from sys.columns where name = 'OldLocationServiceTime' or name = 'NewLocationServiceTime')
BEGIN
ALTER TABLE bluebin.HistoricalDimBinJoin ADD OldLocationServiceTime int NULL
ALTER TABLE bluebin.HistoricalDimBinJoin ADD NewLocationServiceTime int NULL
END
GO

update bluebin.HistoricalDimBinJoin set OldLocationServiceTime = '60', NewLocationServiceTime = '60'

GO

--select * from bluebin.HistoricalDimBinJoin

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
	hdb.OldLocationServiceTime,
	hdb.NewLocationID,
	dl.LocationName as NewLocationName,
	hdb.NewLocationServiceTime,
	LastUpdated 
FROM bluebin.[HistoricalDimBinJoin] hdb
	inner join bluebin.DimFacility df on hdb.FacilityID = df.FacilityID
	inner join bluebin.DimLocation dl on hdb.FacilityID = dl.LocationFacility and hdb.NewLocationID = dl.LocationID
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

if exists (select * from dbo.sysobjects where id = object_id(N'sp_EditHistoricalDimBinJoin') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_EditHistoricalDimBinJoin
GO

--exec sp_EditHistoricalDimBinJoin '6','NEW','TestOld 5',61,'BB006',61
--exec sp_SelectHistoricalDimBinJoin   select * from bluebin.HistoricalDimBinJoin

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




declare @version varchar(50) = '2.4.20180220' --Update Version Number here


if not exists (select * from bluebin.Config where ConfigName = 'Version')
BEGIN
insert into bluebin.Config (ConfigName,ConfigValue,ConfigType,Active,LastUpdated) VALUES ('Version',@version,'DMS',1,getdate())
END
ELSE
Update bluebin.Config set ConfigValue = @version where ConfigName = 'Version'

Print 'Version Updated to ' + @version
Print 'DB: ' + DB_NAME() + ' updated'
GO