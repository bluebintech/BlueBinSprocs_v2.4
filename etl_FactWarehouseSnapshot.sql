IF EXISTS ( SELECT  *
            FROM    sys.objects
            WHERE   object_id = OBJECT_ID(N'etl_FactWarehouseSnapshot')
                    AND type IN ( N'P', N'PC' ) ) 

DROP PROCEDURE  etl_FactWarehouseSnapshot
GO

CREATE PROCEDURE etl_FactWarehouseSnapshot
AS
--exec etl_FactWarehouseSnapshot  

/*********************		DROP FactWarehouseSnapshot		***************************/

  BEGIN TRY
      drop table bluebin.FactWarehouseSnapshot 
  END TRY

  BEGIN CATCH
  END CATCH

/******************		QUERY				****************************/
;

	
select 
	LOCATION,
	ITEM,
       SOH_QTY       AS SOHQty,
	   LAST_ISS_COST	AS UnitCost,
	   convert(DATE,getdate()) as MonthEnd
into TempA# 
from ITEMLOC 
where 
	LOCATION in (Select ConfigValue from bluebin.Config where ConfigName = 'LOCATION')
	and SOH_QTY > 0 
	OR 
	LOCATION in (Select ConfigValue from bluebin.Config where ConfigName = 'LOCATION') and 
	ITEM in (select distinct ITEM from ICTRANS where LOCATION in (Select ConfigValue from bluebin.Config where ConfigName = 'LOCATION'))
	--AND ITEM in ('0000013','0000018')


    SELECT 
		Row_number()
             OVER(
               PARTITION BY a.ITEM
               ORDER BY a.MonthEnd DESC) as [Sequence],
		a.MonthEnd,
		a.ITEM,
		case when a.MonthEnd = convert(DATE,getdate()) then TempA#.SOHQty else (ISNULL(b.QUANTITY,0)*-1) end as QUANTITY,
		(ISNULL(c.QUANTITY,0)*-1) as QUANTITYIN

    into TempB#
	FROM   
	(SELECT DISTINCT 
		case when left(Date,11) = left(getdate(),11) then Date else Eomonth(Date) end AS MonthEnd,
		ITEM
		FROM   bluebin.DimDate,TempA#) a
		LEFT JOIN
		(select 
			ITEM,
			EOMONTH(DATEADD(MONTH, -1, TRANS_DATE)) as MonthEnd,
			SUM((QUANTITY)) as QUANTITY 
			FROM   ICTRANS 
			where 
				LOCATION in (Select ConfigValue from bluebin.Config where ConfigName = 'LOCATION')
			group by ITEM,
			EOMONTH(DATEADD(MONTH, -1, TRANS_DATE))) b on a.MonthEnd = b.MonthEnd and a.ITEM = b.ITEM 
		LEFT JOIN
		(select 
			ITEM,
			EOMONTH(DATEADD(MONTH, -1, REC_ACT_DATE)) as MonthEnd,
			SUM((REC_QTY*EBUY_UOM_MULT)) as QUANTITY 
			FROM   POLINE 
			where 
				LOCATION in (Select ConfigValue from bluebin.Config where ConfigName = 'LOCATION')
				and CXL_QTY = 0 and REC_QTY > 0 and ITEM_TYPE = 'I'
			group by ITEM,
			EOMONTH(DATEADD(MONTH, -1, REC_ACT_DATE))) c on a.MonthEnd = c.MonthEnd and a.ITEM = c.ITEM 
		left join TempA# on a.MonthEnd = TempA#.MonthEnd and a.ITEM = TempA#.ITEM
    WHERE  a.MonthEnd <= Getdate() 



select 
ic.COMPANY AS FacilityKey,
df.FacilityName,
ic.LOCATION as LocationID,
TempB#.MonthEnd as SnapshotDate,
TempB#.ITEM,
SUM(TempB#.QUANTITY+TempB#.QUANTITYIN) OVER (PARTITION BY TempB#.ITEM ORDER BY TempB#.[Sequence]) as SOH,
ic.LAST_ISS_COST  AS UnitCost  
--,SUM(TempB#.QUANTITY+TempB#.QUANTITYIN) OVER (PARTITION BY TempB#.ITEM ORDER BY TempB#.[Sequence])*ic.LAST_ISS_COST as B
into bluebin.FactWarehouseSnapshot
from TempB# 
inner join ITEMLOC ic on TempB#.ITEM = ic.ITEM
inner join bluebin.DimFacility df on ic.COMPANY = df.FacilityID
where ic.LOCATION in (Select ConfigValue from bluebin.Config where ConfigName = 'LOCATION')

drop table TempA#
drop table TempB#

/*********************	END		******************************/

GO

UPDATE etl.JobSteps
SET LastModifiedDate = GETDATE()
WHERE StepName = 'FactWarehouseSnapshot'

GO
