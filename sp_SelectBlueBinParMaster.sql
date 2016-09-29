if exists (select * from dbo.sysobjects where id = object_id(N'sp_SelectBlueBinParMaster') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_SelectBlueBinParMaster
GO

--exec sp_SelectBlueBinParMaster '','','17'
CREATE PROCEDURE sp_SelectBlueBinParMaster
@FacilityName varchar(255)
,@LocationName varchar(255)
,@ItemDescription varchar(255)

--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON


select
bbpm.[ParMasterID],
bbpm.[FacilityID],
bbf.[FacilityName],
rtrim(bbpm.[LocationID]) as LocationID,
ISNULL((rtrim(bblm.[LocationName])),'') as LocationName,
rtrim(bbpm.[ItemID]) as ItemID,
ISNULL((COALESCE(bbim.ItemClinicalDescription,bbim.ItemDescription,'None')),'') as ItemDescription,
bbpm.[BinSequence],
bbpm.[BinSize],
bbpm.[BinUOM],
bbpm.[BinQuantity],
bbpm.[LeadTime],
bbpm.[ItemType],
isnull(bbim.VendorItemNumber,'') as VendorItemNumber,
bbpm.[WHSequence],
bbpm.[PatientCharge],
case when bbpm.[PatientCharge] = 1 then 'Yes' else 'No' end as PatientChargeName,
case when bbpm.[Updated] = '1' then 'Yes' else 'No' end as Updated,
bbpm.[LastUpdated]
from [bluebin].[BlueBinParMaster] bbpm
	inner join [bluebin].[DimItem] bbim on rtrim(bbpm.ItemID) = rtrim(bbim.ItemID)
		inner join [bluebin].[DimLocation] bblm on rtrim(bbpm.LocationID) = rtrim(bblm.LocationID) and bblm.BlueBinFlag = 1
			inner join bluebin.DimFacility bbf on rtrim(bbpm.FacilityID) = rtrim(bbf.FacilityID)
				
				
WHERE 
rtrim(bblm.LocationName) LIKE '%' + @LocationName + '%' 
		and bbf.FacilityName LIKE '%' + @FacilityName + '%' 
			and (rtrim(bbim.ItemID) +' - ' + rtrim(bbim.ItemDescription) like '%' + @ItemDescription + '%'
					OR
						rtrim(bbim.ItemID) +' - ' + rtrim(bbim.ItemClinicalDescription) like '%' + @ItemDescription + '%')
order by LocationID,ItemID

END
GO
grant exec on sp_SelectBlueBinParMaster to appusers
GO