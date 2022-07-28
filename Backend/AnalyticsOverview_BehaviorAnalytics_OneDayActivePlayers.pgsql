DROP FUNCTION IF EXISTS ana.get_day_active_player(currentDate TIMESTAMP, inputModelName VARCHAR, inputUserName VARCHAR);
CREATE OR REPLACE FUNCTION ana.get_day_active_player(currentDate TIMESTAMP, inputModelName VARCHAR='', inputUserName VARCHAR='')
    RETURNS TABLE (
        numbersOfPlayer NUMERIC --活躍玩家數(個數)
    ) AS
$$
BEGIN

     RETURN QUERY
     WITH list_player_dates AS
     (
        SELECT username
        FROM PlayDatetime
        WHERE tctraffic <> 0 AND intraffic <> 0 AND outtraffic <> 0
        AND username <> ''
        AND timestamp BETWEEN currentDate-interval '1 days' AND currentDate
        AND (modelname =  inputModelName OR inputModelName='')
        AND (username =  inputUserName OR inputUserName='')
        GROUP BY username
     )

    SELECT COUNT(*)::NUMERIC
    FROM list_player_dates;

END;
$$
    LANGUAGE PLPGSQL;

    SELECT * FROM ana.get_day_active_player(TIMESTAMP 'today');
    --總覽頁&使用行為_日活躍玩家數