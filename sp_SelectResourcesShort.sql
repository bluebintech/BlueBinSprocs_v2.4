if exists (select * from dbo.sysobjects where id = object_id(N'sp_SelectResourcesShort') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_SelectResourcesShort
GO

--exec sp_SelectResourcesShort ''

CREATE PROCEDURE sp_SelectResourcesShort
@Title varchar(20)


--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON
	SELECT 
	[BlueBinResourceID]
      ,[FirstName]
      ,[LastName]
      ,[MiddleName]
      ,LastName + ', ' + FirstName as Name
	  ,Title
  FROM [bluebin].[BlueBinResource] bbu
  where 
	Active = 1 and Title like '%' + @Title + '%'
  order by LastName,[FirstName]

END
GO
grant exec on sp_SelectResourcesShort to appusers
GO
