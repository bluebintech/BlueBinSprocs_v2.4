IF EXISTS ( SELECT  *
            FROM    sys.objects
            WHERE   object_id = OBJECT_ID(N'ssp_ReqLookup')
                    AND type IN ( N'P', N'PC' ) ) 

DROP PROCEDURE  ssp_ReqLookup
GO

--exec ssp_ReqLookup '180'

CREATE PROCEDURE ssp_ReqLookup
@ReqNumber varchar(30)
AS

select 'REQLINE',* from REQLINE where REQ_NUMBER = @ReqNumber
select 'ICTRANS',* from ICTRANS where DOCUMENT like '%' + @ReqNumber + '%'
select 'POLINESRC',* from POLINESRC where SOURCE_DOC_N like '%' + @ReqNumber + '%'
select 'POLINE',* from POLINE where PO_NUMBER in (select PO_NUMBER from POLINESRC where SOURCE_DOC_N like '%' + @ReqNumber + '%')
select 'PORECLINE',* from PORECLINE where PO_NUMBER in (select PO_NUMBER from POLINESRC where SOURCE_DOC_N like '%' + @ReqNumber + '%')

select 'FactScan',* from bluebin.FactScan where OrderNum like '%' + @ReqNumber + '%'


GO

grant exec on ssp_ReqLookup to public
GO