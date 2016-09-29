
if exists (select * from dbo.sysobjects where id = object_id(N'ssp_TableSize') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure ssp_TableSize
GO

--exec ssp_TableSize ''

CREATE PROCEDURE ssp_TableSize
@schema varchar(20)

--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON

--Table Rowcount Query
select 
ss.name as [Schema]
,st.name as [Table]
,ddps.row_count

from sys.tables st
	inner join sys.dm_db_partition_stats ddps on st.object_id = ddps.object_id
	left outer join sys.schemas ss on st.schema_id = ss.schema_id
	where ss.name like '%' + @schema + '%'
order by ss.name,st.name


END
GO
grant exec on ssp_TableSize to public
GO


