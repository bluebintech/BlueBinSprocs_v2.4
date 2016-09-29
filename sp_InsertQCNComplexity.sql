if exists (select * from dbo.sysobjects where id = object_id(N'sp_InsertQCNComplexity') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_InsertQCNComplexity
GO

--exec sp_InsertQCNComplexity 'TEST'

CREATE PROCEDURE sp_InsertQCNComplexity
@Name varchar (255),
@Description varchar(100)



--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON
if exists(select * from qcn.QCNComplexity where Name = @Name)
BEGIN
GOTO THEEND
END
insert into qcn.QCNComplexity (Name,Active,LastUpdated,Description) VALUES (@Name,1,getdate(),@Description)

END
THEEND:

GO
grant exec on sp_InsertQCNComplexity to appusers
GO
