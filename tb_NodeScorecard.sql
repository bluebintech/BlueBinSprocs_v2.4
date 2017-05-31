--*********************************************************************************************
--Tableau Sproc  These load data into the datasources for Tableau
--*********************************************************************************************

IF EXISTS ( SELECT  *
            FROM    sys.objects
            WHERE   object_id = OBJECT_ID(N'tb_NodeScorecard')
                    AND type IN ( N'P', N'PC' ) ) 

--exec tb_NodeScorecard
DROP PROCEDURE  tb_NodeScorecard
GO

CREATE PROCEDURE tb_NodeScorecard

AS

select 
k.FacilityID,
k.FacilityName,
k.LocationID,
k.LocationName,
(count(distinct k.BinKey)) as TotalBins,
isnull(Sum(k.Scan),0) as Scans,
isnull(Sum(k.StockOut),0) as StockOuts,
db.Critical,
db.Hot,
db.Healthy,
db.Slow,
db.Stale,
isnull(q.Ct,0) as QCNCount,
isnull(q.AvgDaysOpen,0) as QCNDaysOpen,
isnull(g.LastScore,0) as LastGembaScore,
g.LastAudit as LastGembaDays,
99 as TotalScore

from tableau.Kanban k
inner join (
			select BinFacility,LocationID,[Critical],[Hot],[Healthy],[Never Scanned],[Slow],[Stale] 
			from 
				(select BinFacility,LocationID,BinCurrentStatus from bluebin.DimBin) b
			PIVOT 
				(
				COUNT (BinCurrentStatus) FOR BinCurrentStatus in ([Critical],[Hot],[Healthy],[Never Scanned],[Slow],[Stale])) as pvt
			) db on k.FacilityID = db.BinFacility and k.LocationID = db.LocationID
left outer join (
					select FacilityID,LocationID,count(*) as Ct,AVG(DaysOpen) as AvgDaysOpen from(
						select 
						q.FacilityID,
						q.LocationID,
						case when qs.Status in ('Completed','Rejected') then convert(int,(q.[DateCompleted] - q.[DateEntered]))
						else convert(int,(getdate() - q.[DateEntered])) end as DaysOpen
						from qcn.QCN q
						inner join [qcn].[QCNStatus] qs on q.QCNStatusID = qs.QCNStatusID
						where q.Active = 1) as q1
						group by FacilityID,LocationID
				) q on k.FacilityID = q.FacilityID and k.LocationID = q.LocationID
left outer join (
					select
					dl.LocationFacility as FacilityID,
					dl.LocationID,
					case 
						when g.[Date] is null then 365
						else convert(int,(getdate() - g.[Date])) end as LastAudit,
					g.TotalScore as LastScore
					from bluebin.DimLocation dl
					left join (
								select 
								g1.FacilityID,
								g1.LocationID,
								g1.Date,
								g1.TotalScore
								from [gemba].[GembaAuditNode] g1
								inner join (select Max([Date]) as MaxDate,FacilityID,LocationID 
											from [gemba].[GembaAuditNode] group by FacilityID,LocationID
											) g2 on g1.FacilityID = g2.FacilityID and g1.LocationID = g2.LocationID and g1.[Date] = g2.MaxDate
								) g on dl.LocationFacility = g.FacilityID and dl.LocationID = g.LocationID
					where dl.BlueBinFlag = 1
				) g on k.FacilityID = g.FacilityID and k.LocationID = g.LocationID

where k.[Date] > getdate() -30
group by 
k.FacilityID,
k.FacilityName,
k.LocationID,
k.LocationName,
db.Critical,
db.Hot,
db.Healthy,
db.Slow,
db.Stale,
isnull(q.Ct,0),
isnull(q.AvgDaysOpen,0),
isnull(g.LastScore,0),
g.LastAudit

order by 
k.FacilityName,
k.LocationName


GO

grant exec on tb_NodeScorecard to public
GO


					