--*****************************************************
--**************************SPROC**********************
if exists (select * from dbo.sysobjects where id = object_id(N'sp_SelectQCNComplexity') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_SelectQCNComplexity
GO

--exec sp_SelectQCNComplexity ''

CREATE PROCEDURE sp_SelectQCNComplexity
@Active varchar(1)
--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON
	SELECT 
	QCNCID,
	Name,
	[Name]+' - ' + Description as QCNComplexity,
	Description,
	case 
		when Active = 1 then 'Yes' 
		Else 'No' 
		end as ActiveName,
	Active,
	LastUpdated 
	
	FROM qcn.[QCNComplexity]
	where Active like '%' + @Active + '%'
END
GO
grant exec on sp_SelectQCNComplexity to appusers
GO
