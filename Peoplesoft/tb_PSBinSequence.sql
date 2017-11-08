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

;

/*
select * from REQ_LINE_SHIP where REQ_ID = '0000089501' order by LINE_NBR
select * from PO_LINE_DISTRIB where REQ_ID like '%89501%' order by LINE_NBR
select * from REQ_LN_DISTRIB where REQ_ID like '%89501%' order by LINE_NBR
*/
SET NOCOUNT ON


;

declare @Facility int
   select @Facility = ConfigValue from bluebin.Config where ConfigName = 'PS_DefaultFacility'
;
WITH A as
(
select 
Row_number()
         OVER(
           Partition BY db.BinKey
           ORDER BY p.CREATION_DATE ASC,p.REQ_NUMBER,p.LINE_NBR) AS Scanseq,
		   --ORDER BY p.REC_ACT_DATE ASC,p.PO_NUMBER,p.LINE_NBR) AS Scanseq,
p.COMPANY as FacilityID,
df.FacilityName,
p.REQ_LOCATION as LocationID,
dl.LocationName,
p.ITEM as ItemID,
di.ItemDescription,
db.BinSequence,
db.BinKey,
p.CREATION_DATE as OrderDate,
p.REQ_NUMBER as OrderNum,
--p.REC_ACT_DATE as OrderDate,
--p.PO_NUMBER as OrderNum,
p.LINE_NBR as OrderLineNum,
p.QUANTITY as OrderQty,
p.CUSTOM_C1_C as OrderSequence

from 
(select @Facility as COMPANY, 
		rs.INV_ITEM_ID as ITEM,
		rs.REQ_DT AS CREATION_DATE,
		rs.REQ_ID as REQ_NUMBER,
		rs.LINE_NBR,
		'' as QUANTITY,
		rs.CUSTOM_C1_C,
		po.LOCATION as REQ_LOCATION 
		from REQ_LINE_SHIP rs
		inner join REQ_LN_DISTRIB po on right(('0000000000' + po.REQ_ID),10) = rs.REQ_ID and po.LINE_NBR = rs.LINE_NBR  
			where CUSTOM_C1_C in ('A','B')) p
			
--(select p.COMPANY, p.ITEM,p.REC_ACT_DATE,p.PO_NUMBER,p.LINE_NBR,p.QUANTITY,p.PO_USER_FLD_4,posrc.REQ_LOCATION 
--		from POLINE p 
--			inner join POLINESRC posrc on p.PO_NUMBER = posrc.PO_NUMBER and p.LINE_NBR = posrc.LINE_NBR 
--			where p.PO_USER_FLD_4 in ('A','B')) p
inner join bluebin.DimBin db on p.COMPANY = db.BinFacility and p.REQ_LOCATION = db.LocationID and p.ITEM = db.ItemID
inner join bluebin.DimFacility df on db.BinFacility = df.FacilityID 
inner join bluebin.DimLocation dl on db.LocationID = dl.LocationID
inner join bluebin.DimItem di on db.ItemID = di.ItemID

where CUSTOM_C1_C in ('A','B') --and QUANTITY <> CXL_QTY
and p.CREATION_DATE > getdate() -90
--and p.REC_ACT_DATE > getdate() -90
group by
p.COMPANY,
df.FacilityName,
p.REQ_LOCATION ,
dl.LocationName,
p.ITEM,
di.ItemDescription,
db.BinSequence,
db.BinKey,
p.CREATION_DATE,
p.REQ_NUMBER,

p.LINE_NBR,
p.QUANTITY,
p.CUSTOM_C1_C
)

select 
IDENTITY (INT, 1, 1) AS RecID, 
A.*,
CASE WHEN A.Scanseq = '1' THEN 'N/A' ELSE
	CASE WHEN A.OrderSequence = b.OrderSequence THEN 'No' ELSE 'Yes' END END AS InSequence,

CASE 
   WHEN A.Scanseq = '1' THEN 0  -- 'N/A' 
ELSE
	CASE 
	   WHEN A.OrderSequence = b.OrderSequence THEN 1  -- 'No' 
	ELSE 0  -- 'Yes' 
	END 
END AS OutOfSequenceValue,
0 AS OutofSequenceCount,

CASE
   WHEN A.BinSequence LIKE '%CD' THEN 'Card'
   ELSE 'Bin'
END AS BinOrCard 

into #temp01

from A
left join A b on A.BinKey = b.BinKey and A.Scanseq = b.Scanseq+1
-- order by 
-- A.BinKey,A.Scanseq

ALTER TABLE #temp01
ADD OutofSequenceRecentDate DATETIME

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
		 ) AS t2
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
    ) AS c
)

UPDATE
   t1
SET
   OutofSequenceRecentDate = t2.OrderDate
FROM
   #temp01 t1
      INNER JOIN (SELECT ItemID, LocationID, MAX(OrderDate) AS 'OrderDate' 
	              FROM #temp01 
				  WHERE OutOfSequenceValue = 1
				  GROUP BY ItemID, LocationID
				 ) AS t2
         ON
            t1.ItemID = t2.ItemID AND
            t1.LocationID = t2.LocationID 
WHERE
   t1.RecID IN 
(SELECT
   c.RecID
 FROM
    (SELECT ItemID, LocationID, MAX(RecID) AS 'RecID' 
	 FROM #temp01 
	 WHERE OutOfSequenceValue = 1
	 GROUP BY ItemID, LocationID
    ) AS c
)

   

SELECT *  FROM #temp01 
-- where itemid = 1640 and OrderDate = '5/23/17'
-- order by itemid, OrderDate

--where itemid = '5014552' 
-- order by itemid, LocationID
ORDER BY BinKey, Scanseq

DROP TABLE #temp01

END

GO

grant exec on tb_BinSequence to public
GO


