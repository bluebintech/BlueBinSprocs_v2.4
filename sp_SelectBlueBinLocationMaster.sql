if exists (select * from dbo.sysobjects where id = object_id(N'sp_SelectBlueBinLocationMaster') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_SelectBlueBinLocationMaster
GO

--exec sp_SelectBlueBinLocationMaster '',''
CREATE PROCEDURE sp_SelectBlueBinLocationMaster
@LocationName varchar(255),
@AcctUnit varchar(40)


--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON

IF exists (select * from sys.tables where name = 'RQLOC')
BEGIN
select
LocationKey,
LocationID,
LocationName,
isnull(gl.ACCT_UNIT,'') as AcctUnit,
isnull(gl.DESCRIPTION,'') as AcctUnitDesc,
case
	when rl.REQ_LOCATION is null then 'No' else 'Yes'
	end as Updated
FROM 
[bluebin].[DimLocation] dl
left join dbo.RQLOC rl on dl.LocationID = rl.REQ_LOCATION
left join dbo.GLNAMES gl on rl.ISS_ACCT_UNIT = gl.ACCT_UNIT and rl.COMPANY = gl.COMPANY
WHERE 
LocationName LIKE '%' + @LocationName + '%' and BlueBinFlag = 1 and isnull(gl.ACCT_UNIT,'') LIKE '%' + @AcctUnit + '%' 
order by LocationID
END
ELSE 
select
LocationKey,
LocationID,
LocationName,
'N/A' as AcctUnit,
'N/A' as AcctUnitDesc,
'Yes' as Updated
FROM 
[bluebin].[DimLocation] dl

WHERE 
LocationName LIKE '%' + @LocationName + '%' and BlueBinFlag = 1  
order by LocationID


END
GO
grant exec on sp_SelectBlueBinLocationMaster to appusers
GO
