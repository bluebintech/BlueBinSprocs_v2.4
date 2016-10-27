--*********************************************************************************************
--Tableau Sproc  These load data into the datasources for Tableau
--*********************************************************************************************

IF EXISTS ( SELECT  *
            FROM    sys.objects
            WHERE   object_id = OBJECT_ID(N'tb_TimeStudyPlanner')
                    AND type IN ( N'P', N'PC' ) ) 

--exec tb_TimeStudyActivityTimes
DROP PROCEDURE  tb_TimeStudyPlanner
GO

CREATE PROCEDURE tb_TimeStudyPlanner

AS


GO

grant exec on TimeStudyPlanner to public
GO