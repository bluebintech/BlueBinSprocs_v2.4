if exists (select * from dbo.sysobjects where id = object_id(N'sp_InsertConesDeployed') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure sp_InsertConesDeployed
GO

--exec sp_InsertConesDeployed '6','BB006','0044100'


CREATE PROCEDURE sp_InsertConesDeployed
@FacilityID int
,@LocationID varchar (10)
,@ItemID varchar (32)
,@ExpectedDelivery datetime
,@SubProduct varchar(3)
,@Details varchar(255)


--WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON
select @ExpectedDelivery = case
							when @ExpectedDelivery < getdate() then NULL else @ExpectedDelivery end 

insert into bluebin.ConesDeployed (FacilityID,LocationID,ItemID,ConeDeployed,Deployed,ConeReturned,Deleted,LastUpdated,ExpectedDelivery,SubProduct,Details) VALUES
(@FacilityID,@LocationID,@ItemID,1,getdate(),0,0,getdate(),@ExpectedDelivery,@SubProduct,@Details) 

END


GO
grant exec on sp_InsertConesDeployed to appusers
GO