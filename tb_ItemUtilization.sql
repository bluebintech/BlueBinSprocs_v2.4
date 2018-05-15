--*********************************************************************************************
--Tableau Sproc  These load data into the datasources for Tableau
--*********************************************************************************************
--Created GB 20180410

if exists (select * from dbo.sysobjects where id = object_id(N'tb_ItemUtilization') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure tb_ItemUtilization
GO

--select BinStatus,* from tableau.Kanban where BinKey > 7142 order by BinKey,Date
--exec tb_ItemUtilization 
CREATE PROCEDURE tb_ItemUtilization

--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON

select 
dd.Date,
convert(int,((getdate()-1)-dd.Date)) as [Days],
ISNULL(slow.SlowCt,0) as SlowCt,
ISNULL(stale.StaleCt,0) as StaleCt,
ISNULL(slow.SlowCt,0) + ISNULL(stale.StaleCt,0) as SlowStaleCt,
ISNULL(ct.TotalCt,0) - (ISNULL(slow.SlowCt,0) + ISNULL(stale.StaleCt,0)) as NonSlowStaleCt,
ISNULL(ct.TotalCt,0) as TotalCt,
(ISNULL((ISNULL(ct.TotalCt,0) - (ISNULL(slow.SlowCt,0) + ISNULL(stale.StaleCt,0)))*100,0)/ISNULL(ct.TotalCt,1)) as DailyUtilization
from bluebin.DimDate dd

left join (select Date,count(*) as SlowCt from tableau.Kanban where BinStatus = 'Slow' group by Date) slow on dd.Date = slow.Date
left join (select Date,count(*) as StaleCt from tableau.Kanban where BinStatus = 'Stale' group by Date) stale on dd.Date = stale.Date
left join (select Date,count(*) as TotalCt from tableau.Kanban group by Date) ct on dd.Date = ct.Date
where dd.Date > getdate() -91 and dd.Date < getdate() and ct.TotalCt > 0

order by dd.Date desc


END
GO
grant exec on tb_ItemUtilization to public
GO