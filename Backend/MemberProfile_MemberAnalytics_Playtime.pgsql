DROP FUNCTION IF EXISTS ana.get_play_times(startDate TIMESTAMP, endDate TIMESTAMP , inputModelName VARCHAR, inputAccountName VARCHAR);
CREATE OR REPLACE FUNCTION ana.get_play_times(startDate TIMESTAMP, endDate TIMESTAMP ,inputModelName VARCHAR='', inputAccountName VARCHAR='')
    RETURNS TABLE (
        avgTimes NUMERIC,   --遊玩時間平均數
        minTimes NUMERIC    --遊玩時間中位數
    ) AS $$
BEGIN

    RETURN QUERY 
    WITH get_player_data AS
        (
            SELECT serialno , username,
            EXTRACT
                (
                    epoch
                    FROM
                    (SELECT (SUM(enddatetime-startdatetime))
                )/3600) AS playhour 
            FROM playdatetime
            WHERE  intraffic <>0 AND outtraffic <>0 AND tctraffic <>0 
            AND timestamp BETWEEN startDate AND endDate 
            AND (modelname = inputModelName OR inputModelName='') 
            AND (username = inputAccountName OR inputAccountName='')
            AND username <> ''
			GROUP BY serialno , username
        )

        SELECT AVG(playhour)::NUMERIC,percentile_cont(0.5) WITHIN GROUP (ORDER BY playhour)::NUMERIC FROM get_player_data;
        

END;$$

    LANGUAGE PLPGSQL;

    SELECT * FROM ana.get_play_times(TIMESTAMP 'today' - interval '30 days' , TIMESTAMP 'today');
    --總覽頁&使用行為_遊玩時間