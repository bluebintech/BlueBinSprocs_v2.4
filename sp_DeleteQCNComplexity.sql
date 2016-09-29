if exists (select * from dbo.sysobjects where id = object_id(N'sp_DeleteQCNComplexity') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_DeleteQCNComplexity
GO

--exec sp_DeleteQCNComplexity

CREATE PROCEDURE sp_DeleteQCNComplexity
@original_QCNCID int,
@original_Name varchar(255)

--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON
	
	Update qcn.[QCNComplexity] set Active = 0
	WHERE 
	[QCNCID] = @original_QCNCID 
		AND [Name] = @original_Name
END
GO
grant exec on sp_DeleteQCNComplexity to appusers
GO
