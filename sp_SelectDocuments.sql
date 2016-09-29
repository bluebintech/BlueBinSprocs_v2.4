if exists (select * from dbo.sysobjects where id = object_id(N'sp_SelectDocuments') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_SelectDocuments
GO

--exec sp_SelectDocuments 'gbutler@bluebin.com','FormsSignage'
CREATE PROCEDURE sp_SelectDocuments
@UserLogin varchar(60),
@DocumentSource varchar(20)



--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON
if exists (select * from bluebin.Document where DocumentSource = @DocumentSource)
BEGIN
	Select 
	DocumentID,
	DocumentName,
	DocumentType,
	DocumentSource,
	Document,
	Active,
	DateCreated,
	LastUpdated
	from bluebin.[Document]    
	where 
	DocumentSource = @DocumentSource
	order by DocumentName asc
END
ELSE
BEGIN
Select 
	0 as DocumentID,
	'*No Documents Available*' as DocumentName,
	'' as DocumentType,
	'' as DocumentSource,
	'' as Document,
	'' as Active,
	'' as DateCreated,
	'' as LastUpdated
END

END
GO
grant exec on sp_SelectDocuments to appusers
GO