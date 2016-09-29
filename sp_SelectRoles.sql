if exists (select * from dbo.sysobjects where id = object_id(N'sp_SelectRoles') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_SelectRoles
GO

--exec sp_SelectRoles 'Blue'
CREATE PROCEDURE sp_SelectRoles
@RoleName varchar(50)


--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON
Select RoleID,RoleName from bluebin.BlueBinRoles
where RoleName like '%' + @RoleName + '%'
order by RoleName

END
GO
grant exec on sp_SelectRoles to appusers
GO