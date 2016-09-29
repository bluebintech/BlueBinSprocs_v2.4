if exists (select * from dbo.sysobjects where id = object_id(N'sp_InsertQCNStatus') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_InsertQCNStatus
GO

--exec sp_InsertQCNStatus 'TEST',''

CREATE PROCEDURE sp_InsertQCNStatus
@Status varchar (255),
@Description varchar(100)


--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON
if exists(select * from qcn.QCNStatus where Status = @Status)
BEGIN
GOTO THEEND
END
insert into qcn.QCNStatus (Status,Active,LastUpdated,Description) VALUES (@Status,1,getdate(),@Description)

END
THEEND:

GO
grant exec on sp_InsertQCNStatus to appusers
GO
