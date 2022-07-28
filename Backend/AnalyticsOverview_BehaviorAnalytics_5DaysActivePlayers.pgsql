DROP FUNCTION IF EXISTS ana.get_5days_active_player(startDate TIMESTAMP, endDate TIMESTAMP, inputModelName VARCHAR, inputUserName VARCHAR);
CREATE OR REPLACE FUNCTION ana.get_5days_active_player(startDate TIMESTAMP, endDate TIMESTAMP, inputModelName VARCHAR='', inputUserName VARCHAR='')
    RETURNS TABLE (
        numbersOfPlayer NUMERIC --活躍玩家數(個數)
    ) AS
$$
BEGIN

     RETURN QUERY
     WITH list_player_dates AS
     (
        SELECT username,
        startdatetime::date
        FROM PlayDatetime
        WHERE tctraffic <> 0 AND intraffic <> 0 AND outtraffic <> 0
        AND username <> ''
        AND timestamp BETWEEN startDate AND endDate
        AND (modelname =  inputModelName OR inputModelName='')
        AND (username =  inputUserName OR inputUserName='')
        GROUP BY username,startdatetime::date
     ),
     is_player_active AS
     (
        SELECT COUNT(*)::NUMERIC=(select (endDate::timestamp)::date-(startDate::timestamp)::date) AS active
        FROM list_player_dates
        GROUP BY username
     )

    SELECT COUNT(*)::NUMERIC
    FROM is_player_active
    WHERE active=TRUE;

END;
$$
    LANGUAGE PLPGSQL;

    SELECT * FROM ana.get_active_player(TIMESTAMP 'today'-interval '5 days',TIMESTAMP 'today');
    --總覽頁&使用行為_5日活躍玩家數