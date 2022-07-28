DROP FUNCTION IF EXISTS ana.get_user_avgplaytimes(startDate TIMESTAMP, endDate TIMESTAMP, inputUserName VARCHAR, inputModelName VARCHAR);
CREATE OR REPLACE FUNCTION ana.get_user_avgplaytimes(startDate TIMESTAMP, endDate TIMESTAMP, inputUserName VARCHAR, inputModelName VARCHAR='')
    RETURNS TABLE (
        outUserName VARCHAR,        --玩家名稱
        playTimes DOUBLE PRECISION  --平均每日使用時數
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
    hours/(select (endDate::timestamp)::date-(startDate::timestamp)::date)
    FROM total_hours
    WHERE username = inputUserName;
END;
$$
    LANGUAGE PLPGSQL;

    SELECT * FROM ana.get_user_avgplaytimes(TIMESTAMP 'today'-interval '7 days',TIMESTAMP 'today','jeff_a');
    --玩家輪廓_玩家分析_平均每日使用時數