--*****************************************************
--**************************SPROC**********************
--Updated 20180122 GB

if exists (select * from dbo.sysobjects where id = object_id(N'sp_SelectConesDeployed') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_SelectConesDeployed
GO

--exec sp_SelectConesDeployed '','',''

CREATE PROCEDURE sp_SelectConesDeployed
@Facility varchar(10),
@Location varchar(10),
@Item varchar(32)

--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON
	SELECT 
	cd.ConesDeployedID,
	cd.Deployed,
	cd.ExpectedDelivery,
	df.FacilityID,
	df.FacilityName,
	dl.LocationID,
	dl.LocationName,
	di.ItemID,
	di.ItemDescription,
	cd.SubProduct,
	db.BinSequence,
	case when so.ItemID is not null then 'Yes' else 'No' end as DashboardStockout,
	cd.Details as DetailsText,
	case when Details is null or Details = '' then 'No' else 'Yes' end as Details
	
	FROM bluebin.[ConesDeployed] cd
	inner join bluebin.DimFacility df on cd.FacilityID = df.FacilityID
	inner join bluebin.DimLocation dl on cd.LocationID = dl.LocationID
	inner join bluebin.DimItem di on cd.ItemID = di.ItemID
	inner join bluebin.DimBin db on df.FacilityID = db.BinFacility and dl.LocationID = db.LocationID and di.ItemID = db.ItemID
	left outer join (select distinct FacilityID,LocationID,ItemID from tableau.Kanban where StockOut = 1 and [Date] = (select max([Date]) from tableau.Kanban)) so 
		on cd.FacilityID = so.FacilityID and cd.LocationID = so.LocationID and cd.ItemID = so.ItemID
	where cd.Deleted = 0 and cd.ConeReturned = 0
	and
		(df.FacilityName like '%' + @Facility + '%' or df.FacilityID like '%' + @Facility + '%')
	and
		(dl.LocationName like '%' + @Location + '%' or dl.LocationID like '%' + @Location + '%')
	and 
		(di.ItemID like '%' + @Item + '%' or di.ItemDescription like '%' + @Item + '%')
	order by cd.Deployed desc
	
END
GO
grant exec on sp_SelectConesDeployed to appusers
GO


--*****************************************************
--**************************SPROC**********************
--Updated 20180122 GB

if exists (select * from dbo.sysobjects where id = object_id(N'sp_SelectConesItem') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_SelectConesItem
GO

--exec sp_SelectConesItem
CREATE PROCEDURE sp_SelectConesItem

--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON
Select distinct a.LocationID,rTrim(a.ItemID) as ItemID,COALESCE(b.ItemClinicalDescription,b.ItemDescription,'No Description'),rTrim(a.ItemID)+ ' - ' + COALESCE(b.ItemClinicalDescription,b.ItemDescription,'No Description') as ExtendedDescription 
from [bluebin].[DimBin] a 
                                inner join [bluebin].[DimItem] b on rtrim(a.ItemID) = rtrim(b.ItemID)  
								UNION 
								select distinct LocationID,'' as ItemID,'' as ItemClinicalDescription, '--Select--'  as ExtendedDescription from [bluebin].[DimBin]
                                       
								--UNION 
								--select distinct q.LocationID,rTrim(q.ItemID) as ItemID,COALESCE(di.ItemClinicalDescription,di.ItemDescription,'No Description'),rTrim(q.ItemID)+ ' - ' + COALESCE(di.ItemClinicalDescription,di.ItemDescription,'No Description') as ExtendedDescription  
								--from qcn.QCN q
								--inner join bluebin.DimItem di on q.ItemID = di.ItemID
								--inner join bluebin.DimLocation dl on q.LocationID = dl.LocationID
                                       order by 4 asc

END
GO
grant exec on sp_SelectConesItem to appusers
GO

--*****************************************************
--**************************SPROC**********************
--Updated 20180122 GB

if exists (select * from dbo.sysobjects where id = object_id(N'sp_SelectConesLocation') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_SelectConesLocation
GO

--exec sp_SelectConesLocation
CREATE PROCEDURE sp_SelectConesLocation

--WITH ENCRYPTION
AS
BEGIN

SET NOCOUNT ON

select 
	distinct 
	q.[LocationID],
    rtrim(dl.[LocationName]) + ' - ' + dl.LocationID as LocationName
	from bluebin.ConesDeployed q
	left join [bluebin].[DimLocation] dl on q.LocationID = dl.LocationID and dl.BlueBinFlag = 1
	where q.Deleted = 0 and q.ConeReturned = 0
	order by LocationID
END
GO
grant exec on sp_SelectConesLocation to appusers
GO


--*****************************************************
--**************************SPROC**********************
--Updated 20180122 GB

if exists (select * from dbo.sysobjects where id = object_id(N'sp_SelectConesFacility') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_SelectConesFacility
GO

--exec sp_SelectConesFacility
CREATE PROCEDURE sp_SelectConesFacility

--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON

select 
	distinct 
	cd.[FacilityID],
    df.FacilityName as FacilityName
	from bluebin.ConesDeployed cd
	inner join [bluebin].[DimFacility] df on cd.FacilityID = df.FacilityID 
	order by df.FacilityName
END
GO
grant exec on sp_SelectConesFacility to appusers
GO


--***********************************************************************************************************************
IF exists (select * from sys.columns where name = 'PS_StockOuts')
BEGIN 
exec sp_rename 'gemba.GembaAuditNode.PS_StockOuts','PS_ExpiredItems','COLUMN'
END
GO
update gemba.GembaAuditNode set PS_ExpiredItems = '5' 
GO
--*****************************************************
--**************************SPROC**********************
if exists (select * from dbo.sysobjects where id = object_id(N'sp_UpdateGembaScores') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_UpdateGembaScores
GO
--Edited 20180205 GB
--exec sp_UpdateGembaScores

CREATE PROCEDURE sp_UpdateGembaScores


--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON
Update gemba.GembaAuditNode set PS_TotalScore = (PS_EmptyBins+PS_BackBins+PS_ExpiredItems+PS_ReturnVolume+PS_NonBBT)
Update gemba.GembaAuditNode set RS_TotalScore = (RS_BinsFilled+RS_BinServices+RS_NodeSwept+RS_NodeCorrections+RS_EmptiesCollected)
Update gemba.GembaAuditNode set SS_TotalScore = ISNULL((SS_Supplied+SS_KanbansPP+SS_StockoutsPT+SS_StockoutsMatch+SS_HuddleBoardMatch),0)
Update gemba.GembaAuditNode set NIS_TotalScore = (NIS_Labels+NIS_CardHolders+NIS_BinsRacks+NIS_GeneralAppearance+NIS_Signage)
Update gemba.GembaAuditNode set TotalScore = (NIS_TotalScore+PS_TotalScore+RS_TotalScore+SS_TotalScore)
				

END
GO
grant exec on sp_UpdateGembaScores to appusers
GO

exec sp_UpdateGembaScores
GO




--*****************************************************
--**************************SPROC**********************
--Edited 20180205 GB
if exists (select * from dbo.sysobjects where id = object_id(N'sp_SelectGembaAuditNodeEdit') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_SelectGembaAuditNodeEdit
GO

--exec sp_SelectGembaAuditNodeEdit '507'

CREATE PROCEDURE sp_SelectGembaAuditNodeEdit
@GembaAuditNodeID int

--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON
select
		a.[GembaAuditNodeID]
		,convert(varchar,a.[Date],101) as [Date]
		,[FacilityID] as FacilityID
		,rtrim(LocationID) as LocationID
		,b1.UserLogin as Auditer
		,a.[AdditionalComments]
		,a.[PS_EmptyBins]
		,a.[PS_BackBins]
		,a.[PS_ExpiredItems]--,a.[PS_StockOuts]
		,a.[PS_ReturnVolume]
		,a.[PS_NonBBT]
		,a.[PS_OrangeCones]
		,a.[PS_Comments]
		,a.[RS_BinsFilled]
		,a.[RS_EmptiesCollected]
		,a.[RS_BinServices]
		,a.[RS_NodeSwept]
		,a.[RS_NodeCorrections]
		,b2.LastName + ', ' + b2.FirstName  as RS_ShadowedUser
		,a.[RS_Comments]

		,a.[SS_Supplied]
		,a.[SS_KanbansPP]
		,a.[SS_StockoutsPT]
		,a.[SS_StockoutsMatch]
		,a.[SS_HuddleBoardMatch]
		,a.[SS_Comments]

		,a.[NIS_Labels]
		,a.[NIS_CardHolders]
		,a.[NIS_BinsRacks]
		,a.[NIS_GeneralAppearance]
		,a.[NIS_Signage]
		,a.[NIS_Comments]
		,a.[PS_TotalScore]
		,a.[RS_TotalScore]
		,a.[SS_TotalScore]
		,a.[NIS_TotalScore]
		,a.[TotalScore]
		,convert(varchar,a.[LastUpdated],101) as [LastUpdated]
		from gemba.GembaAuditNode a 
				inner join bluebin.BlueBinUser b1 on a.[AuditerUserID] = b1.BlueBinUserID
				left join bluebin.BlueBinResource b2 on a.[RS_ShadowedUserID] = b2.BlueBinResourceID where a.GembaAuditNodeID = @GembaAuditNodeID
END
GO
grant exec on sp_SelectGembaAuditNodeEdit to appusers
GO


--*****************************************************
--**************************SPROC**********************
if exists (select * from dbo.sysobjects where id = object_id(N'sp_UpdateGembaScores') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_UpdateGembaScores
GO
--Edited 20180205 GB
--exec sp_UpdateGembaScores

CREATE PROCEDURE sp_UpdateGembaScores


--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON
Update gemba.GembaAuditNode set PS_TotalScore = (PS_EmptyBins+PS_BackBins+PS_ExpiredItems+PS_ReturnVolume+PS_NonBBT)
Update gemba.GembaAuditNode set RS_TotalScore = (RS_BinsFilled+RS_BinServices+RS_NodeSwept+RS_NodeCorrections+RS_EmptiesCollected)
Update gemba.GembaAuditNode set SS_TotalScore = ISNULL((SS_Supplied+SS_KanbansPP+SS_StockoutsPT+SS_StockoutsMatch+SS_HuddleBoardMatch),0)
Update gemba.GembaAuditNode set NIS_TotalScore = (NIS_Labels+NIS_CardHolders+NIS_BinsRacks+NIS_GeneralAppearance+NIS_Signage)
Update gemba.GembaAuditNode set TotalScore = (NIS_TotalScore+PS_TotalScore+RS_TotalScore+SS_TotalScore)
				

END
GO
grant exec on sp_UpdateGembaScores to appusers
GO


--*****************************************************
--**************************SPROC**********************

if exists (select * from dbo.sysobjects where id = object_id(N'sp_EditGembaAuditNode') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_EditGembaAuditNode
GO
--Edited 20180205 GB
--exec sp_EditGembaAuditNode 'TEST'

CREATE PROCEDURE sp_EditGembaAuditNode
@GembaAuditNodeID int,
@Facility int,
@Location varchar(10),
@AdditionalComments varchar(max),
@PS_EmptyBins int,
@PS_BackBins int,
@PS_ExpiredItems int,--@PS_StockOuts int,
@PS_ReturnVolume int,
@PS_NonBBT int,
@PS_OrangeCones int,
@PS_Comments varchar(max),
@RS_BinsFilled int,
@RS_EmptiesCollected int,
@RS_BinServices int,
@RS_NodeSwept int,
@RS_NodeCorrections int,
@RS_ShadowedUser varchar(255),
@RS_Comments varchar(max),
@SS_Supplied int,
@SS_KanbansPP int,
@SS_StockoutsPT int,
@SS_StockoutsMatch int,
@SS_HuddleBoardMatch int,
@SS_Comments varchar(max),
@NIS_Labels int,
@NIS_CardHolders int,
@NIS_BinsRacks int,
@NIS_GeneralAppearance int,
@NIS_Signage int,
@NIS_Comments varchar(max),
@PS_TotalScore int,
@RS_TotalScore int,
@SS_TotalScore int,
@NIS_TotalScore int,
@TotalScore int
			,@Auditer varchar(255),@ImageSourceIDPH int


--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON
Update [gemba].[GembaAuditNode] SET

           [FacilityID] = @Facility
		   ,[LocationID] = @Location
           ,[AdditionalComments] = @AdditionalComments
           ,[PS_EmptyBins] = @PS_EmptyBins
           ,[PS_BackBins] = @PS_BackBins
           ,[PS_ExpiredItems] = @PS_ExpiredItems--,[PS_StockOuts] = @PS_StockOuts
           ,[PS_ReturnVolume] = @PS_ReturnVolume
           ,[PS_NonBBT] = @PS_NonBBT
		   ,[PS_OrangeCones] = @PS_OrangeCones
           ,[PS_Comments] = @PS_Comments
           ,[RS_BinsFilled] = @RS_BinsFilled
		   ,[RS_EmptiesCollected] = @RS_EmptiesCollected
           ,[RS_BinServices] = @RS_BinServices
           ,[RS_NodeSwept] = @RS_NodeSwept
           ,[RS_NodeCorrections] = @RS_NodeCorrections
           ,[RS_ShadowedUserID] = (select BlueBinResourceID from bluebin.BlueBinResource where LastName + ', ' + FirstName  = @RS_ShadowedUser)
           ,[RS_Comments] = @RS_Comments
           ,[SS_Supplied] = @SS_Supplied
		   ,[SS_KanbansPP] = @SS_KanbansPP
		   ,[SS_StockoutsPT] = @SS_StockoutsPT
		   ,[SS_StockoutsMatch] = @SS_StockoutsMatch
		   ,[SS_HuddleBoardMatch] = @SS_HuddleBoardMatch
		   ,[SS_Comments] = @SS_Comments
		   ,[NIS_Labels] = @NIS_Labels
           ,[NIS_CardHolders] = @NIS_CardHolders
           ,[NIS_BinsRacks] = @NIS_BinsRacks
           ,[NIS_GeneralAppearance] = @NIS_GeneralAppearance
           ,[NIS_Signage] = @NIS_Signage
           ,[NIS_Comments] = @NIS_Comments
           ,[PS_TotalScore] = @PS_TotalScore
           ,[RS_TotalScore] = @RS_TotalScore
		   ,[SS_TotalScore] = @SS_TotalScore
           ,[NIS_TotalScore] = @NIS_TotalScore
           ,[TotalScore] = @TotalScore
           ,[LastUpdated] = getdate()
WHERE [GembaAuditNodeID] = @GembaAuditNodeID
;--Insert New entry for Gemba into MasterLog
exec sp_InsertMasterLog @Auditer,'Gemba','Update Gemba Node Audit',@GembaAuditNodeID
;--Update the Images uploaded from the PlaceHolderID to the real entryID
exec sp_UpdateImages @GembaAuditNodeID,@Auditer,@ImageSourceIDPH
;--Update the master Log for images from the PlaceHolderID to the real entryID
update bluebin.MasterLog 
set ActionID = @GembaAuditNodeID 
where ActionType = 'Gemba' and 
		BlueBinUserID = (select BlueBinUserID from bluebin.BlueBinUser where LOWER(UserLogin) = LOWER(@Auditer)) and 
			ActionID = (select convert(int,(convert(varchar,(select BlueBinUserID from bluebin.BlueBinUser where LOWER(UserLogin) = LOWER(@Auditer)))+convert(varchar,@ImageSourceIDPH))))
--if exists(select * from bluebin.[Image] where ImageSourceID = (select convert(int,(convert(varchar,(select BlueBinUserID from bluebin.BlueBinUser where LOWER(UserLogin) = @UserLogin))+convert(varchar,@ImageSourceIDPH))))
--	BEGIN
--	update [bluebin].[Image] set ImageSourceID = @GembaAuditNodeID where ImageSourceID = (select convert(int,(convert(varchar,(select BlueBinUserID from bluebin.BlueBinUser where LOWER(UserLogin) = @UserLogin))+convert(varchar,@ImageSourceIDPH))))
--	END
END
GO
grant exec on sp_EditGembaAuditNode to appusers
GO


--*****************************************************
--**************************SPROC**********************

if exists (select * from dbo.sysobjects where id = object_id(N'sp_InsertGembaAuditNode') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_InsertGembaAuditNode
GO
--Edited 20180205 GB
--exec sp_InsertGembaAuditNode 'TEST'

CREATE PROCEDURE sp_InsertGembaAuditNode
@Facility int,
@Location varchar(10),
@Auditer varchar(255),
@AdditionalComments varchar(max),
@PS_EmptyBins int,
@PS_BackBins int,
@PS_ExpiredItems int,--@PS_StockOuts int,
@PS_ReturnVolume int,
@PS_NonBBT int,
@PS_OrangeCones int,
@PS_Comments varchar(max),
@RS_BinsFilled int,
@RS_EmptiesCollected int,
@RS_BinServices int,
@RS_NodeSwept int,
@RS_NodeCorrections int,
@RS_ShadowedUser varchar(255),
@RS_Comments varchar(max),
@SS_Supplied int,
@SS_KanbansPP int,
@SS_StockoutsPT int,
@SS_StockoutsMatch int,
@SS_HuddleBoardMatch int,
@SS_Comments varchar(max),
@NIS_Labels int,
@NIS_CardHolders int,
@NIS_BinsRacks int,
@NIS_GeneralAppearance int,
@NIS_Signage int,
@NIS_Comments varchar(max),
@PS_TotalScore int,
@RS_TotalScore int,
@SS_TotalScore int,
@NIS_TotalScore int,
@TotalScore int
			,@ImageSourceIDPH int



--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON
declare @GembaAuditNodeID int

Insert into [gemba].[GembaAuditNode]
(
	Date,
	FacilityID,
	LocationID,
	AuditerUserID,
	AdditionalComments,
	PS_EmptyBins,
	PS_BackBins,
	PS_ExpiredItems,--PS_StockOuts,
	PS_ReturnVolume,
	PS_NonBBT,
	PS_OrangeCones,
	PS_Comments,
	RS_BinsFilled,
	RS_EmptiesCollected,
	RS_BinServices,
	RS_NodeSwept,
	RS_NodeCorrections,
	RS_ShadowedUserID,
	RS_Comments,
	SS_Supplied,
	SS_KanbansPP,
	SS_StockoutsPT,
	SS_StockoutsMatch,
	SS_HuddleBoardMatch,
	SS_Comments,
	NIS_Labels,
	NIS_CardHolders,
	NIS_BinsRacks,
	NIS_GeneralAppearance,
	NIS_Signage,
	NIS_Comments,
	PS_TotalScore,
	RS_TotalScore,
	SS_TotalScore,
	NIS_TotalScore,
	TotalScore,
	Active,
	LastUpdated)
VALUES 
(
getdate(),  --Date
@Facility,
@Location,
(select BlueBinUserID from bluebin.BlueBinUser where LOWER(UserLogin) = LOWER(@Auditer)),
@AdditionalComments,
@PS_EmptyBins,
@PS_BackBins,
@PS_ExpiredItems,--@PS_StockOuts,
@PS_ReturnVolume,
@PS_NonBBT,
@PS_OrangeCones,
@PS_Comments,
@RS_BinsFilled,
@RS_EmptiesCollected,
@RS_BinServices,
@RS_NodeSwept,
@RS_NodeCorrections,
(select BlueBinResourceID from bluebin.BlueBinResource where LastName + ', ' + FirstName  = @RS_ShadowedUser ),
@RS_Comments,
@SS_Supplied,
@SS_KanbansPP,
@SS_StockoutsPT,
@SS_StockoutsMatch,
@SS_HuddleBoardMatch,
@SS_Comments,
@NIS_Labels,
@NIS_CardHolders,
@NIS_BinsRacks,
@NIS_GeneralAppearance,
@NIS_Signage,
@NIS_Comments,
@PS_TotalScore,
@RS_TotalScore,
@SS_TotalScore,
@NIS_TotalScore,
@TotalScore,
1, --Active
getdate() --Last Updated
)
;--Insert New entry for Gemba into MasterLog with  Scope Identity of the newly created ID
	SET @GembaAuditNodeID = SCOPE_IDENTITY()
	exec sp_InsertMasterLog @Auditer,'Gemba','New Gemba Node Audit',@GembaAuditNodeID
;--Update the Images uploaded from the PlaceHolderID to the real entryID
exec sp_UpdateImages @GembaAuditNodeID,@Auditer,@ImageSourceIDPH
;--Update the master Log for images from the PlaceHolderID to the real entryID
update bluebin.MasterLog 
set ActionID = @GembaAuditNodeID 
where ActionType = 'Gemba' and 
		BlueBinUserID = (select BlueBinUserID from bluebin.BlueBinUser where LOWER(UserLogin) = LOWER(@Auditer)) and 
			ActionID = (select convert(int,(convert(varchar,(select BlueBinUserID from bluebin.BlueBinUser where LOWER(UserLogin) = LOWER(@Auditer)))+convert(varchar,@ImageSourceIDPH))))
--if exists(select * from bluebin.[Image] where ImageSourceID = (select convert(int,(convert(varchar,(select BlueBinUserID from bluebin.BlueBinUser where LOWER(UserLogin) = @UserLogin))+convert(varchar,@ImageSourceIDPH))))
--	BEGIN
--	update [bluebin].[Image] set ImageSourceID = @GembaAuditNodeID where ImageSourceID = (select convert(int,(convert(varchar,(select BlueBinUserID from bluebin.BlueBinUser where LOWER(UserLogin) = @UserLogin))+convert(varchar,@ImageSourceIDPH))))
--	END

END
GO
grant exec on sp_InsertGembaAuditNode to appusers
GO









declare @version varchar(50) = '2.4.20180205' --Update Version Number here


if not exists (select * from bluebin.Config where ConfigName = 'Version')
BEGIN
insert into bluebin.Config (ConfigName,ConfigValue,ConfigType,Active,LastUpdated) VALUES ('Version',@version,'DMS',1,getdate())
END
ELSE
Update bluebin.Config set ConfigValue = @version where ConfigName = 'Version'

Print 'Version Updated to ' + @version
Print 'DB: ' + DB_NAME() + ' updated'
GO








