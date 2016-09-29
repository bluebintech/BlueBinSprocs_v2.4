if exists (select * from dbo.sysobjects where id = object_id(N'ssp_BBS') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure ssp_BBS
GO

--exec ssp_BBS 'Trinity_MasonCity'

CREATE PROCEDURE ssp_BBS
@DB varchar(10)

--WITH ENCRYPTION
AS
BEGIN


IF Exists (select * from sys.databases where name = @DB)
BEGIN
DECLARE @DBTable Table (Name varchar(20),[id] int)
declare @SQL nvarchar(max)

set @SQL = 'USE ['+@DB+']

DECLARE @Status Table (Client varchar(20),QueryRunDateTime datetime,MaxReqDate datetime,[SourceUpToDate] varchar(3),MaxSnapshotDate datetime,[DBUpToDate] varchar(3))

insert into @Status
select 
	DB_NAME(),
	getdate(),
	convert(date,max(CREATION_DATE)) as [MaxReqDate],
	case when convert(date,max(CREATION_DATE)) > getdate() -2 then ''YES'' else ''NO'' end,
	db.[MaxSnapshotDate],
	db.[DBUpToDate?]
from dbo.REQLINE,
		(select 
		DB_NAME() as Client,
		convert(date,max(LastScannedDate)) as [MaxSnapshotDate],
		case when convert(date,max(LastScannedDate)) > getdate() -2 then ''YES'' else ''NO'' end as [DBUpToDate?]
		from bluebin.FactBinSnapshot
		where LastScannedDate > getdate() -7
		) db 
where CREATION_DATE > getdate() -7 and (left(REQ_LOCATION,2) in (select ConfigValue from bluebin.Config where ConfigName = ''REQ_LOCATION'') or REQ_LOCATION in (Select REQ_LOCATION from bluebin.ALT_REQ_LOCATION))
group by 	
	db.[MaxSnapshotDate],
	db.[DBUpToDate?]


	select * from @Status

	'

EXEC (@SQL)

END
END
GO
grant exec on ssp_BBS to public
GO
