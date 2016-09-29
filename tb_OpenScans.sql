--*********************************************************************************************
--Tableau Sproc  These load data into the datasources for Tableau
--*********************************************************************************************

IF EXISTS ( SELECT  *
            FROM    sys.objects
            WHERE   object_id = OBJECT_ID(N'tb_OpenScans')
                    AND type IN ( N'P', N'PC' ) ) 

--exec tb_OpenScans
DROP PROCEDURE  tb_OpenScans
GO

CREATE PROCEDURE tb_OpenScans

AS



select 
OrderNum as [Order Num],
ltrim(rtrim(p.PO_NUMBER)) as [PO Num],
LineNum as [Line #],
OrderDate as [Order Date],
FacilityName as [Facility Name],
LocationID as [Location ID],
LocationName as [Location Name],
ItemID as [Item ID],
ItemDescription as [Item Description],
ItemType as [Item Type],
OrderUOM as [Order UOM],
BinSequence as [Bin Sequence],
Scan as Scans,
HotScan as [Hot Scan],
StockOut as [Stock Outs],
BinCurrentStatus as [Bin Status],
OrderQty as [Order Qty]


--select top 10* 
from tableau.Kanban k
left outer join POLINESRC p on k.OrderNum = p.SOURCE_DOC_N and k.LineNum = p.SRC_LINE_NBR

where 
--Date > getdate()-10 and 
ScanHistseq > (select ConfigValue from bluebin.Config where ConfigName = 'ScanThreshold') and 
OrderCloseDate is null and 
OrderDate is not null

group by
OrderNum,
p.PO_NUMBER,
LineNum,
OrderDate,
FacilityName,
LocationID,
LocationName,
ItemID,
ItemDescription,
ItemType,
OrderUOM,
BinSequence,
Scan,
HotScan,
StockOut,
BinCurrentStatus,
OrderQty

GO

grant exec on tb_OpenScans to public
GO

