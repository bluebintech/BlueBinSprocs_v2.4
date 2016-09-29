if exists (select * from dbo.sysobjects where id = object_id(N'sp_SelectDocumentSingle') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_SelectDocumentSingle
GO

--exec sp_SelectDocumentSingle 10
CREATE PROCEDURE sp_SelectDocumentSingle
@DocumentID int



--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON
select DocumentName, Document, DocumentType from bluebin.Document where DocumentID=@DocumentID


END
GO
grant exec on sp_SelectDocumentSingle to appusers
GO

