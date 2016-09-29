if exists (select * from dbo.sysobjects where id = object_id(N'sp_SelectQCNFacility') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_SelectQCNFacility
GO

--exec sp_SelectQCNFacility
CREATE PROCEDURE sp_SelectQCNFacility

--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON

select 
	distinct 
	q.[FacilityID],
    df.FacilityName as FacilityName
	from qcn.QCN q
	left join [bluebin].[DimFacility] df on q.FacilityID = df.FacilityID 
	order by df.FacilityName
END
GO
grant exec on sp_SelectQCNFacility to appusers
GO





