DROP FUNCTION IF EXISTS ana.get_user_top_playtimes_a1(startDate TIMESTAMP, endDate TIMESTAMP, TopN INT, inputModelName VARCHAR);
CREATE OR REPLACE FUNCTION ana.get_user_top_playtimes_a1(startDate TIMESTAMP, endDate TIMESTAMP, TopN INT, inputModelName VARCHAR='')
    RETURNS TABLE (
        outUserName VARCHAR,        --玩家名稱
        playTimes DOUBLE PRECISION  --每日平均使用時數
    ) AS
$$
BEGIN
    RETURN QUERY
    WITH total_hours AS
    (
        SELECT username,
            EXTRACT
                    (
                        epoch
                        FROM
                        (SELECT (SUM(PD.enddatetime-PD.startdatetime))
                    )/3600) AS hours
        FROM playdatetime AS PD
        WHERE tctraffic <> 0 AND intraffic <> 0 AND outtraffic <> 0
        AND username <> ''
        AND timestamp BETWEEN startDate AND endDate
        AND (modelname =  inputModelName OR inputModelName='')
        GROUP BY username
    )

    SELECT username,
        hours/(select (endDate::timestamp)::date-(startDate::timestamp)::date) AS TOP
    FROM total_hours
    ORDER BY TOP DESC LIMIT TopN;
END;
$$
    LANGUAGE PLPGSQL;

    SELECT * FROM ana.get_user_top_playtimes_a1(TIMESTAMP '2019-07-01',TIMESTAMP '2019-10-14',15,'');
    --使用者行為_平均遊玩時數最多的玩家排名