if exists (select * from dbo.sysobjects where id = object_id(N'sp_InsertUser') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_InsertUser
GO

--exec sp_InsertUser 'gbutler2@bluebin.com','G','But','','BlueBelt','','Tier2'  


CREATE PROCEDURE sp_InsertUser
@UserLogin varchar(60),
@FirstName varchar(30), 
@LastName varchar(30), 
@MiddleName varchar(30), 
@RoleName  varchar(30),
@Email varchar(60),
@Title varchar(50),
@GembaTier varchar(50),
@ERPUser varchar(60),
@AssignToQCN int
	
--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON
declare @newpwdHash varbinary(max), @RoleID int, @NewBlueBinUserID int, @message varchar(255), @fakelogin varchar(50),@RandomPassword varchar(20),@DefaultExpiration int
select @RoleID = RoleID from bluebin.BlueBinRoles where RoleName = @RoleName
select @DefaultExpiration = ConfigValue from bluebin.Config where ConfigName = 'PasswordExpires' and Active = 1


declare @table table (p varchar(50))
insert @table exec sp_GeneratePassword 8 
set @RandomPassword = (Select p from @table)
set @newpwdHash = convert(varbinary(max),rtrim(@RandomPassword))

if not exists (select BlueBinUserID from bluebin.BlueBinUser where LOWER(UserLogin) = LOWER(@UserLogin))
	BEGIN
	insert into bluebin.BlueBinUser (UserLogin,FirstName,LastName,MiddleName,RoleID,MustChangePassword,PasswordExpires,[Password],Email,Active,LastUpdated,LastLoginDate,Title,GembaTier,ERPUser,AssignToQCN)
	VALUES
	(LOWER(@UserLogin),@FirstName,@LastName,@MiddleName,@RoleID,1,@DefaultExpiration,(HASHBYTES('SHA1', @newpwdHash)),LOWER(@UserLogin),1,getdate(),getdate(),@Title,@GembaTier,@ERPUser,@AssignToQCN)
	;
	SET @NewBlueBinUserID = SCOPE_IDENTITY()
	set @message = 'New User Created - '+ LOWER(@UserLogin)
	select @fakelogin = 'gbutler@bluebin.com'
		exec sp_InsertMasterLog @UserLogin,'Users',@message,@NewBlueBinUserID      
	;
	Select p from @table
	END
	ELSE
	BEGIN
	Select 'exists'
	END
	
	if not exists (select BlueBinResourceID from bluebin.BlueBinResource where FirstName = @FirstName and LastName = @LastName)--select * from bluebin.BlueBinResource
	BEGIN
	exec sp_InsertBlueBinResource @LastName,@FirstName,@MiddleName,@UserLogin,@UserLogin,'','',@Title
	END
END
GO
grant exec on sp_InsertUser to appusers
GO
