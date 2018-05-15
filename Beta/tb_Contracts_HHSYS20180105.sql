/*******************************************************************************


			Contracts


*******************************************************************************/


IF EXISTS ( SELECT  *
            FROM    sys.objects
            WHERE   object_id = OBJECT_ID(N'tb_Contracts')
                    AND type IN ( N'P', N'PC' ) ) 

DROP PROCEDURE  tb_Contracts
GO

CREATE PROCEDURE tb_Contracts

AS

BEGIN TRY
    DROP TABLE tableau.Contracts
END TRY

BEGIN CATCH
END CATCH

SELECT Date,
       VEN_AGRMT_REF AS ContractID,
       AGMT_TYPE     AS ContractType,
       a.VENDOR        AS VendorNumber,
	   b.VENDOR_VNAME	AS VendorName,
       a.ITEM          AS ItemNumber,
	   c.DESCRIPTION	AS ItemDescription,
       VEN_ITEM      AS VendorItemNumber,
       CURR_NET_CST  AS CurrentCost,
       UOM,
       UOM_MULT      AS UOMMult,
       PRIORITY      AS Priority,
       HOLD_FLAG     AS HoldFlag,
       EFFECTIVE_DT  AS EffectiveDate,
       EXPIRE_DT     AS ExpireDate
INTO   tableau.Contracts
FROM   bluebin.DimDate
       LEFT JOIN POVAGRMTLN a
              ON EXPIRE_DT = Date 
		--LEFT JOIN APVENMAST b ON a.VENDOR = b.VENDOR 
		LEFT JOIN (select a.VENDOR,a.VENDOR_GROUP,a.VENDOR_VNAME from APVENMAST a
					inner join (select VENDOR,max(VENDOR_GROUP) as VENDOR_GROUP from APVENMAST  group by VENDOR) 
						b on a.VENDOR_GROUP = b.VENDOR_GROUP and a.VENDOR = b.VENDOR) b
			ON ltrim(rtrim(a.VENDOR)) = ltrim(rtrim(b.VENDOR))
		
		LEFT JOIN ITEMMAST c ON a.ITEM = c.ITEM
		--select EFFECTIVE_DT,count(*) from POVAGRMTLN group by EFFECTIVE_DT
GO

UPDATE etl.JobSteps
SET LastModifiedDate = GETDATE()
WHERE StepName = 'Contracts'



GO

grant exec on tb_Contracts to public
GO