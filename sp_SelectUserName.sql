
if exists (select * from dbo.sysobjects where id = object_id(N'sp_SelectUserName') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_SelectUserName
GO

--exec sp_SelectUserName'gbutler@bluebin.com'
CREATE PROCEDURE sp_SelectUserName
@UserLogin varchar(100)

--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON
select 
FirstName
from  [bluebin].[BlueBinUser] 

WHERE LOWER(UserLogin) = LOWER(@UserLogin)

END
GO
grant exec on sp_SelectUserName to appusers
GO