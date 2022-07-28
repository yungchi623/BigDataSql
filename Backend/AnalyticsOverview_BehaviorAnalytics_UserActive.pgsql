DROP FUNCTION IF EXISTS ana.get_user_active(currentDate TIMESTAMP, inputModelName VARCHAR, inputUserName VARCHAR);
CREATE OR REPLACE FUNCTION ana.get_user_active(currentDate TIMESTAMP, inputModelName VARCHAR='', inputUserName VARCHAR='')
    RETURNS TABLE (
        computeActive NUMERIC --用戶活躍度
    ) AS
$$
BEGIN

     RETURN QUERY
     WITH list_month_player_dates AS
     (
        SELECT username
        FROM PlayDatetime
        WHERE tctraffic <> 0 AND intraffic <> 0 AND outtraffic <> 0
        AND username <> ''
        AND timestamp BETWEEN currentDate -interval '30 days' AND currentDate
        AND (modelname =  inputModelName OR inputModelName='')
        AND (username =  inputUserName OR inputUserName='')
        GROUP BY username
     ),
    list_day_player_dates AS
     (
        SELECT username
        FROM PlayDatetime
        WHERE tctraffic <> 0 AND intraffic <> 0 AND outtraffic <> 0
        AND username <> ''
        AND timestamp BETWEEN currentDate -interval '1 days' AND currentDate
        AND (modelname =  inputModelName OR inputModelName='')
        AND (username =  inputUserName OR inputUserName='')
        GROUP BY username
     )

        SELECT (SELECT COUNT(*)
        FROM list_day_player_dates)::NUMERIC * 100
        /(SELECT COUNT(*)
        FROM list_month_player_dates);

END;
$$
    LANGUAGE PLPGSQL;

    SELECT * FROM ana.get_user_active(TIMESTAMP 'today');
    --總覽頁&使用行為_用戶活躍度