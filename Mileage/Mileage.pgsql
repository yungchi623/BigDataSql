DROP FUNCTION IF EXISTS ana.get_membership(startDate TIMESTAMP, endDate TIMESTAMP, inputUserName VARCHAR);
CREATE OR REPLACE FUNCTION ana.get_membership(startDate TIMESTAMP, endDate TIMESTAMP, inputUserName VARCHAR='')
    RETURNS TABLE (
        totalplaydatetime NUMERIC, --本週總共遊玩時間HR
        total_save_times NUMERIC --本週N-Warp總共節省時間ms
    ) AS
$$
BEGIN

    RETURN QUERY   
    WITH playtimes AS
    (
        SELECT (avgdping-(avgvping-avgispping))*denominator*4 AS savetimes ,
        EXTRACT
            (
                epoch
                FROM
                (SELECT (enddatetime-startdatetime)
            /3600)
            ) AS total_play_hour   
        FROM playdatetime 
        WHERE timestamp BETWEEN startDate AND endDate
        AND (username =  inputUserName OR inputUserName='')
        AND  tctraffic <> 0 AND intraffic <> 0 AND outtraffic <> 0
    
    ),

    test AS 
    (
        SELECT total_play_hour,
        CASE WHEN savetimes<0  THEN 0 ELSE savetimes END AS savetimes 
        FROM playtimes
    ),

   total AS
    (
        SELECT SUM(savetimes) AS savetimes ,SUM(total_play_hour) AS total_play_hour
        FROM test  
    )

    SELECT round(total_play_hour::NUMERIC,1), round(savetimes::NUMERIC,1)  FROM total ;

END;$$
    LANGUAGE PLPGSQL;

    SELECT * FROM ana.get_membership (TIMESTAMP '2019-10-21','2019-10-28','jeff_a');