DROP FUNCTION IF EXISTS ana.get_player_profile_traffic(startDate TIMESTAMP, endDate TIMESTAMP, inputUserName VARCHAR);
CREATE FUNCTION ana.get_player_profile_traffic(startDate TIMESTAMP, endDate TIMESTAMP, inputUserName VARCHAR='')
    RETURNS TABLE (
        trafficGB NUMERIC  --連線流量
    ) AS $$
BEGIN

    RETURN QUERY 
    SELECT SUM(intraffic+outtraffic)::NUMERIC/1024/1024/1024
    FROM playdatetime
    WHERE intraffic <>0 AND outtraffic <>0 AND tctraffic <>0 
    AND startdatetime BETWEEN startDate AND endDate
    AND (username =  inputUserName OR inputUserName='');

END;$$
    LANGUAGE PLPGSQL;

SELECT * FROM ana.get_player_profile_traffic(TIMESTAMP 'today'-interval '30 days',TIMESTAMP 'today','jeff_a');
--玩家輪廓_玩家分析_連線流量
