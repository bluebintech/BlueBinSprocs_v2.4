--*****************************************************
--**************************SPROC**********************

if exists (select * from dbo.sysobjects where id = object_id(N'sp_SelectConesFacility') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_SelectConesFacility
GO

--exec sp_SelectConesFacility
CREATE PROCEDURE sp_SelectConesFacility

--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON

select 
	distinct 
	cd.[FacilityID],
    df.FacilityName as FacilityName
	from bluebin.ConesDeployed cd
	inner join [bluebin].[DimFacility] df on cd.FacilityID = df.FacilityID 
	order by df.FacilityName
END
GO
grant exec on sp_SelectConesFacility to appusers
GO







