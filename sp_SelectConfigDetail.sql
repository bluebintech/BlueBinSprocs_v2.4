
--*****************************************************
--**************************SPROC**********************

if exists (select * from dbo.sysobjects where id = object_id(N'sp_SelectConfigDetail') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_SelectConfigDetail
GO


--select * from bluebin.TimeStudyProcess
--exec sp_SelectConfigDetail 'TimeStudy','Double Bin StockOut'

CREATE PROCEDURE sp_SelectConfigDetail
@ConfigType varchar(30),
@ConfigName varchar(30)
--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON

select
ConfigID,
ConfigType,
ConfigName,
ConfigValue,
Description,
LastUpdated

FROM bluebin.Config

where Active = 1 and ConfigType = @ConfigType and ConfigName like '%' + @ConfigName + '%'

END
GO
grant exec on sp_SelectConfigDetail to appusers
GO



