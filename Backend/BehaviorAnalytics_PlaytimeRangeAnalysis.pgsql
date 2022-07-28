DROP FUNCTION IF EXISTS ana.get_game_timerange(startDate TIMESTAMP, endDate TIMESTAMP, TopN INT, inputModelName VARCHAR);
CREATE OR REPLACE FUNCTION ana.get_game_timerange(startDate TIMESTAMP, endDate TIMESTAMP, TopN INT, inputModelName VARCHAR='')
    RETURNS TABLE (
        playTimes NUMERIC,  --玩家遊玩次數
        timeRange TEXT,     --時間區間:早中晚
        week TEXT           --時間區間:星期
    ) AS
$$

BEGIN
    RETURN QUERY
WITH list_playtimes AS(
    SELECT  PD.username,
            PD.startdatetime::date,
            CASE
                WHEN EXTRACT(hour from startdatetime) < 8 THEN '早'
                WHEN EXTRACT(hour from startdatetime) >= 8 AND EXTRACT(hour from startdatetime) < 16 THEN '中'
                WHEN EXTRACT(hour from startdatetime) >= 16 THEN '晚'
            END AS timerange,
            date_part('dow', startdatetime) AS week
    FROM playdatetime AS PD
    WHERE tctraffic <> 0 AND intraffic <> 0 AND outtraffic <> 0
    AND PD.username <> ''
    AND timestamp BETWEEN startDate AND endDate
    AND (modelname =  inputModelName OR inputModelName='')
    GROUP BY timerange,PD.username,PD.startdatetime::date,week
)

SELECT COUNT(*)::NUMERIC,
LPT.timerange,
CASE LPT.week
    WHEN 0 THEN 'SUN'
    WHEN 1 THEN 'MON'
    WHEN 2 THEN 'TUE'
    WHEN 3 THEN 'WED'
    WHEN 4 THEN 'THU'
    WHEN 5 THEN 'FRI'
    WHEN 6 THEN 'SAT'
END
FROM list_playtimes AS LPT
GROUP BY LPT.timerange,LPT.week
ORDER BY LPT.week,LPT.timerange;
END;
$$
    LANGUAGE PLPGSQL;

        SELECT * FROM ana.get_game_timerange(TIMESTAMP '2019-07-31',TIMESTAMP '2019-10-21',10);
        --使用者行為_遊玩時段分析