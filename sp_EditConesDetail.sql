--*****************************************************
--**************************SPROC**********************

if exists (select * from dbo.sysobjects where id = object_id(N'sp_EditConesDetail') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_EditConesDetail
GO

--exec sp_EditConesDetail '12','Test','2016-08-05','No'


CREATE PROCEDURE sp_EditConesDetail
@ConesDeployedID int,
@DetailsText varchar(255),
@ExpectedDate Date,
@SubProduct varchar(3)

--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON
	
	Update bluebin.[ConesDeployed]
	set 
	Details = @DetailsText, 
	ExpectedDelivery = @ExpectedDate,
	SubProduct = @SubProduct
	where ConesDeployedID = @ConesDeployedID
	
END
GO
grant exec on sp_EditConesDetail to appusers
GO
