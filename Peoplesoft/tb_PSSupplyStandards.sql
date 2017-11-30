--*********************************************************************************************
--Tableau Sproc  These load data into the datasources for Tableau
--*********************************************************************************************

if exists (select * from dbo.sysobjects where id = object_id(N'tb_SupplyStandards') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure tb_SupplyStandards
GO

--exec tb_SupplyStandards


CREATE PROCEDURE tb_SupplyStandards

--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON

;



select 
'' as FacilityID,
'' as FacilityName,
'' as PONumber,
'' as AcctUnit,
'' as AcctUnitName,
'' as ItemID,
'' as ItemClinicalDescription,
'' as Category,
'' as POAmt,
'' as POs



END
GO
grant exec on tb_SupplyStandards to public
GO

