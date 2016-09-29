if exists (select * from dbo.sysobjects where id = object_id(N'sp_InsertDocument') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_InsertDocument
GO

--exec sp_InsertDocument 'TestDocument','application/pdf','SOPs','gbutler@bluebin.com','C:\BlueBinDocuments\DemoV22\SOPs\3000 - Replenishing BlueBin Technology Nodes.pdf'
CREATE PROCEDURE sp_InsertDocument
@DocumentName varchar(100),
@DocumentType varchar(30),
@DocumentSource varchar(100),
@UserLogin varchar(60),
@Document varchar(max)

--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON
if not exists (select * from bluebin.Document where DocumentName = @DocumentName and DocumentSource = @DocumentSource)
BEGIN
set @UserLogin = LOWER(@UserLogin)

insert into bluebin.[Document] 
(DocumentName,DocumentType,DocumentSource,[Document],[Active],[DateCreated],[LastUpdated])        
VALUES 
(@DocumentName,@DocumentType,@DocumentSource,@Document,1,getdate(),getdate())
END
ELSE
	BEGIN
	update bluebin.[Document] set Document = @Document, LastUpdated = getdate() where DocumentName = @DocumentName and DocumentSource = @DocumentSource
	END

Declare @DocumentID int  = SCOPE_IDENTITY()
declare @Text varchar(60) = 'Insert Document - '+left(@DocumentName,30)
exec sp_InsertMasterLog @UserLogin,'Documents',@Text,@DocumentID

END
GO
grant exec on sp_InsertDocument to appusers
GO

