
if exists (select * from dbo.sysobjects where id = object_id(N'ssp_DBInfo') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure ssp_DBInfo
GO

--exec ssp_DBInfo 'dbo'

CREATE PROCEDURE ssp_DBInfo
@schema varchar(20)

--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON

select 
ss.name as [Schema]
,st.name as [Table]
,ddps.row_count

from sys.tables st
	inner join sys.dm_db_partition_stats ddps on st.object_id = ddps.object_id
	left outer join sys.schemas ss on st.schema_id = ss.schema_id
where ss.name like '%' + @schema + '%'
order by ss.name,st.name

--Schema, Table, Column query
select 
ss.name as [Schema]
,st.name as [Table]
,sc.name as [Column]
,stt.name as [Type]
,case
	when sc.is_identity = 1 then 'PK'
	else ''
	end as 'PK'
,sc.max_length
,case
	when sc.is_nullable = 1 then ''
	when sc.is_nullable = 0 then 'NOT NULL'
end as [Null]

from sys.tables st
	left outer join sys.schemas ss on st.schema_id = ss.schema_id
	inner join sys.columns sc on st.object_id = sc.object_id
	inner join sys.types stt on sc.system_type_id = stt.system_type_id

where ss.name like '%' + @schema + '%' --and (sc.Name like '%DATE%' or sc.Name like '%DT%')

order by ss.name,st.name,sc.column_id


END
GO
grant exec on ssp_DBInfo to public
GO


