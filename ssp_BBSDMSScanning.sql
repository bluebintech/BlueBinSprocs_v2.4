if exists (select * from dbo.sysobjects where id = object_id(N'ssp_BBSDMSScanning') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure ssp_BBSDMSScanning
GO

--exec ssp_BBSDMSScanning 'Caldwell'

CREATE PROCEDURE ssp_BBSDMSScanning
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
	convert(date,max(ScanDateTime)) as [MaxReqDate],
	case when convert(date,max(ScanDateTime)) > getdate() -2 then ''YES'' else ''NO'' end,
	db.[MaxSnapshotDate],
	db.[DBUpToDate?]
from scan.ScanLine,
		(select 
		DB_NAME() as Client,
		convert(date,max(LastScannedDate)) as [MaxSnapshotDate],
		case when convert(date,max(LastScannedDate)) > getdate() -2 then ''YES'' else ''NO'' end as [DBUpToDate?]
		from bluebin.FactBinSnapshot
		where LastScannedDate > getdate() -7
		) db 
where ScanDateTime > getdate() -7
group by 	
	db.[MaxSnapshotDate],
	db.[DBUpToDate?]


	select * from @Status

	'

EXEC (@SQL)

END
END
GO
grant exec on ssp_BBSDMSScanning to public
GO
