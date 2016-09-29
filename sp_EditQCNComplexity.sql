if exists (select * from dbo.sysobjects where id = object_id(N'sp_EditQCNComplexity') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_EditQCNComplexity
GO

--exec sp_EditQCNComplexity 'TEST'

CREATE PROCEDURE sp_EditQCNComplexity
@QCNCID int
,@Name varchar (255)
,@Active int
,@Description varchar(100)


--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON
	Update qcn.QCNComplexity set Name = @Name,Active = @Active, LastUpdated = getdate(),Description = @Description where QCNCID = @QCNCID

END

GO
grant exec on sp_EditQCNComplexity to appusers
GO