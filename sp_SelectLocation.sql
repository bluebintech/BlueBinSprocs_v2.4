if exists (select * from dbo.sysobjects where id = object_id(N'sp_SelectLocation') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_SelectLocation
GO

--exec sp_SelectLocation 

CREATE PROCEDURE sp_SelectLocation

--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON
SELECT 
LocationID,
--LocationName,
case when LocationID = LocationName then LocationID else LocationID + ' - ' + [LocationName] end as LocationName 

FROM [bluebin].[DimLocation] where BlueBinFlag = 1
order by LocationID
END
GO
grant exec on sp_SelectLocation to appusers
GO
