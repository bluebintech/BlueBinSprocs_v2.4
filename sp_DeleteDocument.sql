if exists (select * from dbo.sysobjects where id = object_id(N'sp_DeleteDocument') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_DeleteDocument
GO

--select * from bluebin.Document
--exec sp_DeleteDocument 'gbutler@bluebin.com','1'
CREATE PROCEDURE sp_DeleteDocument
@UserLogin varchar(60),
@DocumentID int


--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON

set @UserLogin = LOWER(@UserLogin)
delete
from bluebin.[Document]    
where 
DocumentID = @DocumentID


END
GO
grant exec on sp_DeleteDocument to appusers
GO