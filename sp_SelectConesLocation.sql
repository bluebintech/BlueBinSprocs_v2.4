if exists (select * from dbo.sysobjects where id = object_id(N'sp_SelectConesLocation') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_SelectConesLocation
GO

--exec sp_SelectQCNLocation
CREATE PROCEDURE sp_SelectConesLocation

--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON
Select distinct a.LocationID,rTrim(a.ItemID) as ItemID,COALESCE(b.ItemClinicalDescription,b.ItemDescription,'No Description'),rTrim(a.ItemID)+ ' - ' + COALESCE(b.ItemClinicalDescription,b.ItemDescription,'No Description') as ExtendedDescription 
from [bluebin].[DimBin] a 
                                inner join [bluebin].[DimItem] b on rtrim(a.ItemID) = rtrim(b.ItemID)  
								UNION 
								select distinct LocationID,'' as ItemID,'' as ItemClinicalDescription, ''  as ExtendedDescription from [bluebin].[DimBin]
                                       
								UNION 
								select distinct q.LocationID,rTrim(q.ItemID) as ItemID,COALESCE(di.ItemClinicalDescription,di.ItemDescription,'No Description'),rTrim(q.ItemID)+ ' - ' + COALESCE(di.ItemClinicalDescription,di.ItemDescription,'No Description') as ExtendedDescription  
								from qcn.QCN q
								inner join bluebin.DimItem di on q.ItemID = di.ItemID
								inner join bluebin.DimLocation dl on q.LocationID = dl.LocationID
                                       order by 4 asc

END
GO
grant exec on sp_SelectConesLocation to appusers
GO





