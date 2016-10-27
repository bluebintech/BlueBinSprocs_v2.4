if exists (select * from dbo.sysobjects where id = object_id(N'tb_WHOrderPickDetail') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure tb_WHOrderPickDetail
GO
--exec tb_WHOrderPickDetail
CREATE PROCEDURE tb_WHOrderPickDetail
AS
BEGIN
SET NOCOUNT ON


select
dd.Date,
cost.LocationID,
cost.ItemID,
cost.Cost,
ISNULL(fi.PickCount,0) as PickCount,
ISNULL(fi.PickCount,0) * cost.Cost as PickCost,
ISNULL(PO.OrderCount,0) as OrderCount,
ISNULL(PO.OrderCount,0) * cost.Cost as OrderCost

from
bluebin.DimDate dd
left join
	(select 
	fi.LocationID,
	di.ItemID,
	convert(Date,fi.IssueDate) as PickDate,
	SUM(fi.IssueQty) as PickCount
	from 
	bluebin.FactIssue fi
		inner join bluebin.DimItem di on fi.ItemKey = di.ItemKey
	where fi.IssueDate > getdate() -90
	group by 
	fi.LocationID,
	di.ItemID,
	convert(Date,fi.IssueDate)) as fi on dd.Date = fi.PickDate
left join
	(		SELECT
                PO_LN_DST.LOCATION                        AS LocationID,
				PO_LN.INV_ITEM_ID                         AS ItemID,
                convert(Date,PO_HDR.PO_DT) as OrderDate,
				convert(int,SUM(QTY_PO))  AS OrderCount
         FROM   dbo.PO_LINE_DISTRIB PO_LN_DST
                INNER JOIN dbo.PO_LINE PO_LN
                        ON PO_LN_DST.PO_ID = PO_LN.PO_ID
                           AND PO_LN_DST.LINE_NBR = PO_LN.LINE_NBR
                INNER JOIN dbo.PO_HDR
                        ON PO_LN.PO_ID = PO_HDR.PO_ID
                LEFT JOIN dbo.RECV_LN_SHIP SHIP
                       ON PO_LN.PO_ID = SHIP.PO_ID
                          AND PO_LN.LINE_NBR = SHIP.LINE_NBR

         WHERE  (PO_LN_DST.LOCATION COLLATE DATABASE_DEFAULT IN (Select ConfigValue from bluebin.Config where ConfigName = 'PS_BUSINESSUNIT'))
                AND PO_LN.CANCEL_STATUS NOT IN ( 'X', 'D' )
				and PO_HDR.PO_DT > getdate() -90
		Group by
		PO_LN_DST.LOCATION,
		PO_LN.INV_ITEM_ID,
        convert(Date,PO_HDR.PO_DT)) as PO  on fi.LocationID = PO.LocationID and fi.ItemID = PO.ItemID and dd.Date = PO.OrderDate
left join
	(select 
		BUSINESS_UNIT as LocationID,
		INV_ITEM_ID as ItemID,
		CURRENT_COST as Cost 
		from BU_ITEMS_INV) as cost on fi.LocationID = cost.LocationID and fi.ItemID = cost.ItemID

where dd.Date < getdate() + 1 and cost.LocationID is not null
order by dd.Date,cost.LocationID,cost.ItemID
END

GO
grant exec on tb_WHOrderPickDetail to public
GO