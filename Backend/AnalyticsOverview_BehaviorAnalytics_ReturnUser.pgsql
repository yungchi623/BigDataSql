DROP FUNCTION IF EXISTS ana.get_return_player(currentDate TIMESTAMP, inputModelName VARCHAR, inputUserName VARCHAR);
CREATE OR REPLACE FUNCTION ana.get_return_player(currentDate TIMESTAMP, inputModelName VARCHAR='', inputUserName VARCHAR='')
    RETURNS TABLE (
        numbersOfPlayer NUMERIC --活躍玩家數(個數)
    ) AS
$$
BEGIN

     RETURN QUERY
     WITH list_player_data AS
     (
        SELECT username
        FROM PlayDatetime
        WHERE tctraffic <> 0 AND intraffic <> 0 AND outtraffic <> 0
        AND username <> ''
        AND timestamp BETWEEN currentDate-interval '30 days' AND currentDate
        AND (modelname =  inputModelName OR inputModelName='')
        AND (username =  inputUserName OR inputUserName='')
        GROUP BY username
     ),
     list_today_play_data AS
     (
        SELECT CASE WHEN NOT EXISTS(SELECT * FROM list_player_data AS LPD WHERE LPD.username=username) THEN TRUE ELSE FALSE END AS isReturn
        FROM PlayDatetime
        WHERE tctraffic <> 0 AND intraffic <> 0 AND outtraffic <> 0
        AND username <> ''
        AND timestamp BETWEEN currentDate AND NOW()
        AND (modelname =  inputModelName OR inputModelName='')
        AND (username =  inputUserName OR inputUserName='')
        GROUP BY username
     )

    SELECT COUNT(*)::NUMERIC
    FROM list_today_play_data
    WHERE isReturn=TRUE;

END;
$$
    LANGUAGE PLPGSQL;

    SELECT * FROM ana.get_return_player(TIMESTAMP 'today');
    --總覽頁&使用行為_回流人口