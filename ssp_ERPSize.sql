
--*****************************************************
--**************************SPROC**********************

if exists (select * from dbo.sysobjects where id = object_id(N'ssp_ERPSize') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure ssp_ERPSize
GO

--exec ssp_ERPSize 'OSUMC','RECV_LN_SHIP'
--exec ssp_ERPSize '',''

CREATE PROCEDURE ssp_ERPSize
@DB varchar(20),
@table varchar(20)

--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON

--Table Rowcount Query
select 
DB,
[Schema],
[Table],
row_count,
[Date]
from BlueBinDMSAdmin.etl.ETLERPTables
where DB like '%' + @DB + '%' and [Table] like '%' + @table + '%'
order by DB,[Table],[Date] desc
END
GO
grant exec on ssp_ERPSize to public
GO


