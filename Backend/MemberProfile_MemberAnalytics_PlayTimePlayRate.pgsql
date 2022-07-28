DROP FUNCTION IF EXISTS ana.get_player_profile_playtime(startDate TIMESTAMP, endDate TIMESTAMP, inputUserName VARCHAR);
CREATE FUNCTION ana.get_player_profile_playtime(startDate TIMESTAMP, endDate TIMESTAMP, inputUserName VARCHAR='')
    RETURNS TABLE (
        playrate NUMERIC,  --遊玩率
        playTimes NUMERIC  --遊玩時數
    ) AS $$
BEGIN

    RETURN QUERY 
WITH list_login AS
(
    SELECT username , timestamp::date
    FROM lancount
    WHERE timestamp BETWEEN startDate AND endDate
    AND (username =  inputUserName OR inputUserName='')
    GROUP BY username , timestamp::date
),
list_play AS
(
    SELECT username , startdatetime::date
    FROM playdatetime
    WHERE startdatetime BETWEEN startDate AND endDate
    AND (username =  inputUserName OR inputUserName='')
    GROUP BY username , startdatetime::date
),
play_hours AS
(
    SELECT 
        username,
        extract
            (
                epoch
                FROM
                (SELECT (SUM(enddatetime-startdatetime) )
            )/3600) AS total_play_hour
    FROM playdatetime
    WHERE startdatetime BETWEEN startDate AND endDate
    AND (username =  inputUserName OR inputUserName='')
    GROUP BY username
)

SELECT (SELECT COUNT(*) from list_play)::NUMERIC *100/(SELECT COUNT(*) from list_login),(SELECT total_play_hour FROM play_hours)::numeric;

END;$$
    LANGUAGE PLPGSQL;

SELECT * FROM ana.get_player_profile_playtime(TIMESTAMP 'today'-interval '30 days',TIMESTAMP 'today','jeff_a');
--玩家輪廓_玩家分析_遊玩時數&遊玩率

