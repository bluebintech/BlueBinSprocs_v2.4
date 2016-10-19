--*****************************************************
--**************************SPROC**********************

if exists (select * from dbo.sysobjects where id = object_id(N'sp_SelectLocationCascade') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_SelectLocationCascade
GO

--exec sp_SelectLocationCascade 'No'

CREATE PROCEDURE sp_SelectLocationCascade
@Multiple varchar(3)

--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON
declare @MultipleID varchar(10), @MultipleName varchar(10)
select @MultipleID = case when @Multiple = 'Yes' then 'Multiple' else '' end
select @MultipleName = case when @Multiple = 'Yes' then 'Multiple' else '--Select--' end


Select distinct 
FacilityID,
LocationID,
LocationName
from (
SELECT 
LocationFacility as FacilityID,
LocationID,
--LocationName,
case when LocationID = LocationName then LocationID else LocationID + ' - ' + [LocationName] end as LocationName 

FROM [bluebin].[DimLocation] where BlueBinFlag = 1
UNION ALL 
select distinct LocationFacility as FacilityID,'','--Select--' FROM [bluebin].[DimLocation] where BlueBinFlag = 1
UNION ALL 
select distinct LocationFacility as FacilityID,@MultipleID,@MultipleName FROM [bluebin].[DimLocation] where BlueBinFlag = 1) as a
order by LocationID
END
GO
grant exec on sp_SelectLocationCascade to appusers
GO
