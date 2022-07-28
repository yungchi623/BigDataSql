DROP FUNCTION IF EXISTS ana.get_top_game_rank(startDate TIMESTAMP, endDate TIMESTAMP,TopN INT, inputUserName VARCHAR);
CREATE OR REPLACE FUNCTION ana.get_top_game_rank(startDate TIMESTAMP, endDate TIMESTAMP,TopN INT, inputUserName VARCHAR='')
    RETURNS TABLE (     
        outputgameName VARCHAR, --遊戲名稱
        platform VARCHAR , --遊戲平台
        percentage NUMERIC, --玩家登入遊戲所佔百分比
        gameWeeklyPlayHours NUMERIC, --各遊戲本週遊玩時間HR
        gameWeeklySavedMs NUMERIC   --各遊戲本週節省時間ms
    ) AS
$$
BEGIN
    RETURN QUERY 
    WITH  list AS
    (
        SELECT gameid , gamedevicetype ,username ,(avgdping-(avgvping-avgispping))*denominator*4 AS savetimes,
        EXTRACT
            (
                epoch
                FROM
                (SELECT (enddatetime-startdatetime)
            /3600)
            ) AS total_play_hour
        FROM PlayDatetime
        WHERE tctraffic <> 0 AND intraffic <> 0 AND outtraffic <> 0
        AND username <> ''
        AND (username =  inputUserName OR inputUserName='')
        AND timestamp BETWEEN startDate AND endDate
    ),

    test AS 
    (
        SELECT total_play_hour, gameid, gamedevicetype ,username,
        CASE WHEN savetimes <0  THEN 0 ELSE savetimes END AS savetimes 
        FROM list 
    ),

    total AS
    (
        SELECT  COUNT(*)::NUMERIC AS TOP,
        SUM(savetimes) AS savetimes ,SUM(total_play_hour) AS total_play_hour ,GD.gamename, md.displaytype ,username
        FROM test AS PD 
        LEFT JOIN GameDetail AS GD ON PD.gameid = GD.gameid 
        LEFT JOIN ana.mappingdevicetype AS md ON  PD.gamedevicetype = md.devicetype
        WHERE GD.language = 'zh_tw' 
        GROUP BY  GD.gamename, md.displaytype ,username
    )

    SELECT gamename ,displaytype ,(top*100/(SELECT SUM(top) FROM total WHERE (username =  inputUserName OR inputUserName='')))::NUMERIC(10,1),
    round(total_play_hour::NUMERIC,1) , round(savetimes::NUMERIC,1)
    FROM total
    ORDER BY TOP DESC LIMIT TopN;

END;
$$
    LANGUAGE PLPGSQL;

    SELECT * FROM ana.get_top_game_rank(TIMESTAMP '2019-10-23','2019-10-30',5,'jeff_a');