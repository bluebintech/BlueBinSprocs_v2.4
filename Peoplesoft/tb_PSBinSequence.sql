--*********************************************************************************************
--Tableau Sproc  These load data into the datasources for Tableau
--*********************************************************************************************

IF EXISTS ( SELECT  *
            FROM    sys.objects
            WHERE   object_id = OBJECT_ID(N'tb_BinSequence')
                    AND type IN ( N'P', N'PC' ) ) 

--exec tb_BinSequence
DROP PROCEDURE  tb_BinSequence
GO

CREATE PROCEDURE tb_BinSequence

AS

BEGIN
SET NOCOUNT ON
;
/****** Placeholder until PS version is built ******/
select 
'' as RecID,
'' as Scanseq,
'' as FacilityID,
'' as FacilityName,
'' as LocationID,
'' as LocationName,
'' as ItemID,
'' as ItemDescription,
'' as BinSequence,
'' as BinKey,
'' as OrderDate,
'' as OrderNum,
'' as OrderLineNum,
'' as OrderQty,
'' as OrderSequence,
'' as InSequence,
'' as OutOfSequenceValue,
0 as OutofSequenceCount,
'' as BinOrCard,
'' as OutofSequenceRecentDate 
/*--Lawson Query to recreate
WITH A as
(
select 
Row_number()
         OVER(
           Partition BY db.BinKey
           ORDER BY p.REC_ACT_DATE ASC,p.PO_NUMBER,p.LINE_NBR) AS Scanseq,
p.COMPANY as FacilityID,
df.FacilityName,
p.REQ_LOCATION as LocationID,
dl.LocationName,
p.ITEM as ItemID,
di.ItemDescription,
db.BinSequence,
db.BinKey,
p.REC_ACT_DATE as OrderDate,
p.PO_NUMBER as OrderNum,
p.LINE_NBR as OrderLineNum,
p.QUANTITY as OrderQty,
p.PO_USER_FLD_4 as OrderSequence

from 
(select p.COMPANY, p.ITEM,p.REC_ACT_DATE,p.PO_NUMBER,p.LINE_NBR,p.QUANTITY,p.PO_USER_FLD_4,posrc.REQ_LOCATION 
		from POLINE p 
			inner join POLINESRC posrc on p.PO_NUMBER = posrc.PO_NUMBER and p.LINE_NBR = posrc.LINE_NBR 
			where p.PO_USER_FLD_4 in ('A','B')) p
inner join bluebin.DimBin db on p.COMPANY = db.BinFacility and p.REQ_LOCATION = db.LocationID and p.ITEM = db.ItemID
inner join bluebin.DimFacility df on db.BinFacility = df.FacilityID 
inner join bluebin.DimLocation dl on db.LocationID = dl.LocationID
inner join bluebin.DimItem di on db.ItemID = di.ItemID

where PO_USER_FLD_4 in ('A','B') --and QUANTITY <> CXL_QTY
and p.REC_ACT_DATE > getdate() -90
)
select 
IDENTITY (INT, 1, 1) AS RecID, 
A.*,
case when A.Scanseq = '1' then 'N/A' else
	case when A.OrderSequence = b.OrderSequence then 'No' else 'Yes' end end as InSequence,

case 
   when A.Scanseq = '1' then 0  -- 'N/A' 
else
	case 
	   when A.OrderSequence = b.OrderSequence then 1  -- 'No' 
	else 0  -- 'Yes' 
	end 
end as OutOfSequenceValue,
0 as OutofSequenceCount

into #temp01

from A
left join A b on A.BinKey = b.BinKey and A.Scanseq = b.Scanseq+1
-- order by 
-- A.BinKey,A.Scanseq

UPDATE
   t1
SET
   OutofSequenceCount = t2.OutofSequenceCount
FROM
   #temp01 t1
      INNER JOIN 
         (SELECT ItemID, OrderDate, SUM(OutofSequenceValue) AS 'OutofSequenceCount' 
		  FROM #temp01 
		  GROUP BY ItemID, OrderDate
		 ) as t2
ON 
   t1.ItemID = t2.ItemID AND
   t1.OrderDate = t2.OrderDate 
WHERE
   t1.RecID IN 
(SELECT
   c.RecID
 FROM
    (SELECT ItemID, OrderDate, MAX(RecID) AS 'RecID' 
	 FROM #temp01 
	 WHERE OutOfSequenceValue = 1
	 GROUP BY ItemID, OrderDate
    ) as c
)
   

select * from #temp01 
-- where itemid = 1640 and OrderDate = '5/23/17'
-- order by itemid, OrderDate
order by BinKey, Scanseq

drop table #temp01
*/
END

GO

grant exec on tb_BinSequence to public
GO


