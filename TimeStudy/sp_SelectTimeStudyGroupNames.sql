
--*****************************************************
--**************************SPROC**********************

if exists (select * from dbo.sysobjects where id = object_id(N'sp_SelectTimeStudyGroupNames') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_SelectTimeStudyGroupNames
GO

--select * from bluebin.TimeStudyGroup
--exec sp_SelectTimeStudyGroupNames

CREATE PROCEDURE sp_SelectTimeStudyGroupNames


--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON

select
distinct
t.GroupName

FROM bluebin.TimeStudyGroup t


END
GO
grant exec on sp_SelectTimeStudyGroupNames to appusers
GO




