if exists (select * from dbo.sysobjects where id = object_id(N'sp_SelectUsersShort') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_SelectUsersShort
GO

--exec sp_SelectUsersShort

CREATE PROCEDURE sp_SelectUsersShort



--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON
	SELECT 
	[BlueBinUserID]
      ,[UserLogin]
      ,[FirstName]
      ,[LastName]
      ,[MiddleName]
      ,LastName + ', ' + FirstName as Name
  FROM [bluebin].[BlueBinUser] bbu
  where UserLogin <> ''
  and Active = 1
  order by LastName,[FirstName]

END
GO
grant exec on sp_SelectUsersShort to appusers
GO
