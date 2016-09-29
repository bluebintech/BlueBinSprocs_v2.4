if exists (select * from dbo.sysobjects where id = object_id(N'ssp_Versions') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure ssp_Versions
GO

--exec ssp_Versions

CREATE PROCEDURE ssp_Versions
--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON
DECLARE @DBTable TABLE (iid int identity (1,1) PRIMARY KEY,dbname varchar(50));
DECLARE @DBUpdate TABLE (iid int identity (1,1) PRIMARY KEY,dbname varchar(50));
Create table #Versions (dbname varchar(100),[Version] varchar(100))

declare @iid int, @dbname varchar(50), @sql varchar(max), @sql2 varchar(max)


insert @DBTable (dbname) select name from sys.databases 


set @iid = 1
While @iid <= (select MAX(iid) from @DBTable)
BEGIN
select @dbname = dbname from @DBTable where iid = @iid
set @sql = 'Use ' + @DBName + 

' 
	if exists (select * from sys.tables where name = ''Config'')
	BEGIN
	insert into #versions (dbname,[Version])
	select 
		''' + @dbname + ''',
		ConfigValue as Version
	 from bluebin.Config where ConfigName = ''Version''
	END
'
exec (@sql) 

delete from #Versions where [Version] = ''
set @iid = @iid +1
END


select * from #Versions order by 2 desc
drop table #Versions

END 
GO
grant exec on ssp_Versions to public
GO



