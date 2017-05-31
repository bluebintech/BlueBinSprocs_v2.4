


if not exists(select * from sys.columns where name = 'GoLiveDate' and object_id = (select object_id from sys.tables where name = 'ALT_REQ_LOCATION'))
BEGIN
ALTER TABLE bluebin.ALT_REQ_LOCATION ADD [GoLiveDate] datetime;

END
GO

update bluebin.ALT_REQ_LOCATION set GoLiveDate = a.GoLiveDate2 from (select LocationID as L,Min(BinGoLiveDate) as GoLiveDate2 from bluebin.DimBin group by LocationID) a
where REQ_LOCATION = a.L and GoLiveDate is null 
GO

select * from bluebin.ALT_REQ_LOCATION
