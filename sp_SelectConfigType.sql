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
	('Other')

	SELECT * from @ConfigType order by 1 asc
	

END
GO
grant exec on sp_SelectConfigType to appusers
GO
