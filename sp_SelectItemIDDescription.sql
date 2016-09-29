if exists (select * from dbo.sysobjects where id = object_id(N'sp_SelectItemIDDescription') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_SelectItemIDDescription
GO

--exec sp_SelectItemIDDescription
CREATE PROCEDURE sp_SelectItemIDDescription



--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON
SELECT 
DISTINCT rtrim([ItemID]) as ItemID,
[ItemDescription],rTrim(ItemID)
	+ ' - ' + 
		COALESCE(ItemDescription,ItemClinicalDescription,'No Description') as ExtendedDescription 
FROM bluebin.[DimItem]
order by ItemID
END
GO
grant exec on sp_SelectItemIDDescription to appusers
GO