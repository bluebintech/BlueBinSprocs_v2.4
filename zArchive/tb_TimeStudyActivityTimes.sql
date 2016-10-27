--*********************************************************************************************
--Tableau Sproc  These load data into the datasources for Tableau
--*********************************************************************************************

IF EXISTS ( SELECT  *
            FROM    sys.objects
            WHERE   object_id = OBJECT_ID(N'tb_TimeStudyActivityTimes')
                    AND type IN ( N'P', N'PC' ) ) 

--exec tb_TimeStudyActivityTimes
DROP PROCEDURE  tb_TimeStudyActivityTimes
GO

CREATE PROCEDURE tb_TimeStudyActivityTimes

AS
select 
Activity,
AvgS,
AvgM,
AvgH,
LastUpdated
select * from bluebin.FactActivityTimes
order by 1

GO

grant exec on tb_TimeStudyActivityTimes to public
GO