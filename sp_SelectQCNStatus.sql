--*****************************************************
--**************************SPROC**********************

if exists (select * from dbo.sysobjects where id = object_id(N'sp_SelectQCNStatus') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_SelectQCNStatus
GO

--exec sp_SelectQCNStatus '1'

CREATE PROCEDURE sp_SelectQCNStatus
@Active varchar(1)

--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON
	SELECT 
	QCNStatusID,
	[Status],
	Description,
	case 
		when Active = 1 then 'Yes' 
		Else 'No' 
		end as ActiveName,
		Active,
		LastUpdated 
		
	FROM qcn.[QCNStatus]
	where Active like '%' + @Active + '%'
	order by Status

END
GO
grant exec on sp_SelectQCNStatus to appusers
GO
