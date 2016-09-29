if exists (select * from dbo.sysobjects where id = object_id(N'sp_SelectQCNLocation') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_SelectQCNLocation
GO

--exec sp_SelectQCNLocation
CREATE PROCEDURE sp_SelectQCNLocation

--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON

select 
	distinct 
	q.[LocationID],
    case
		when q.[LocationID] = 'Multiple' then q.LocationID
		else case	when dl.LocationID = dl.LocationName then dl.LocationID
					else dl.LocationID + ' - ' + dl.[LocationName] end end as LocationName
	from qcn.QCN q
	left join [bluebin].[DimLocation] dl on q.LocationID = dl.LocationID and dl.BlueBinFlag = 1
	order by LocationID
END
GO
grant exec on sp_SelectQCNLocation to appusers
GO





