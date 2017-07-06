USE [Stanford]
GO

/****** Object:  StoredProcedure [dbo].[tb_SourcingWithLocationID]    Script Date: 6/22/2017 9:57:58 AM ******/
DROP PROCEDURE [dbo].[tb_SourcingWithLocationID]
GO

/****** Object:  StoredProcedure [dbo].[tb_SourcingWithLocationID]    Script Date: 6/22/2017 9:57:58 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


/*

20170622 - jbb  -  The Supply Spend Manager Dashboard at SHC currently shows the LocationID as the Purchase Location.  
                   This is an update to show the LocationID and the LocationName.  Example:   1001-S SCGR

*/

CREATE PROCEDURE [dbo].[tb_SourcingWithLocationID]

AS

BEGIN
SET NOCOUNT ON



SELECT DISTINCT 
   s.*, 
   LTRIM(RTRIM(LocationID)) + '-' + LTRIM(RTRIM(LocationName)) AS 'LocationID' 
FROM 
   tableau.Sourcing s
      LEFT JOIN bluebin.DimLocation d ON
	     s.PurchaseLocation = d.LocationID


END



GO


