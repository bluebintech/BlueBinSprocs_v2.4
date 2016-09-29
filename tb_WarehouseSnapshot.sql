if exists (select * from dbo.sysobjects where id = object_id(N'tb_WarehouseSnapshot') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure tb_WarehouseSnapshot
GO

--exec tb_WarehouseSnapshot
CREATE PROCEDURE tb_WarehouseSnapshot

--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON
SELECT 
	--count(ITEM),
	
	SnapshotDate,
	FacilityName,
	SUM(SOH * UnitCost) as DollarsOnHand,
	LocationID,
	LocationID as LocationName
FROM bluebin.FactWarehouseSnapshot a
WHERE SOH > 0
GROUP BY
	
	SnapshotDate,
	FacilityName,
	LocationID 
;


END
GO
grant exec on tb_WarehouseSnapshot to public
GO







