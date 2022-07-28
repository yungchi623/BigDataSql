DROP FUNCTION IF EXISTS ana.get_player_profile_login(startDate TIMESTAMP, endDate TIMESTAMP, inputUserName VARCHAR);
CREATE FUNCTION ana.get_player_profile_login(startDate TIMESTAMP, endDate TIMESTAMP, inputUserName VARCHAR='')
    RETURNS TABLE (
        login NUMERIC,      --登入率
        loginTimes NUMERIC  --登入時數=開機時數
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
list_login_hours AS
(
    SELECT COUNT(*) AS loginHours FROM lancount WHERE timestamp BETWEEN startDate AND endDate
    AND (username =  inputUserName OR inputUserName='')
)

SELECT COUNT(*)::NUMERIC *100/(select (endDate::timestamp)::date-(startDate::timestamp)::date),
(SELECT loginHours::NUMERIC FROM list_login_hours) FROM list_login;

END;$$
    LANGUAGE PLPGSQL;

SELECT * FROM ana.get_player_profile_login(TIMESTAMP 'today'-interval '30 days',TIMESTAMP 'today','jeff_a');
--玩家輪廓_玩家分析_登入時數&登入率

