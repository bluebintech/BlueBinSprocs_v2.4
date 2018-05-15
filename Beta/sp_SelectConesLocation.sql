--*****************************************************
--**************************SPROC**********************

if exists (select * from dbo.sysobjects where id = object_id(N'sp_SelectConesLocation') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_SelectConesLocation
GO

--exec sp_SelectConesLocation
CREATE PROCEDURE sp_SelectConesLocation

--WITH ENCRYPTION
AS
BEGIN

SET NOCOUNT ON

select 
	distinct 
	q.[LocationID],
    rtrim(dl.[LocationName]) + ' - ' + dl.LocationID as LocationName
	from bluebin.ConesDeployed q
	left join [bluebin].[DimLocation] dl on q.LocationID = dl.LocationID and dl.BlueBinFlag = 1
	order by LocationID
END
GO
grant exec on sp_SelectConesLocation to appusers
GO




