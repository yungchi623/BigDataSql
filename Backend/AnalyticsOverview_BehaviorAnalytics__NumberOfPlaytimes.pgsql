DROP FUNCTION IF EXISTS ana.get_play_game_times(startDate TIMESTAMP, endDate TIMESTAMP, inputModelName VARCHAR, inputUserName VARCHAR);
CREATE OR REPLACE FUNCTION ana.get_play_game_times(startDate TIMESTAMP, endDate TIMESTAMP, inputModelName VARCHAR='', inputUserName VARCHAR='')
    RETURNS TABLE (
        playGameTimes NUMERIC   --使用N-Warp玩遊戲次數(TBC)
    ) AS
$$

BEGIN
     RETURN QUERY
     WITH list_launchdata AS
     (
        SELECT * FROM
        (
            SELECT LC.serialno,LC.timestamp::date,LC.modelname,LC.username FROM LanCount AS LC
            GROUP BY LC.serialno,LC.timestamp::date,LC.modelname,LC.username
        ) AS LaunchLanCount
        UNION
        SELECT * FROM
        (
            SELECT PD.serialno,PD.startdatetime::date,PD.modelname,PD.username FROM PlayDatetime AS PD
            WHERE tctraffic <> 0 AND intraffic <> 0 AND outtraffic <> 0
            GROUP BY PD.serialno,PD.startdatetime::date,PD.modelname,PD.username
        ) AS LaunchPlayDatetime
        UNION
        SELECT * FROM
        (
            SELECT UN.serialno,UN.timestamp::date,UN.modelname,UN.username FROM UnknownPacket AS UN
            GROUP BY UN.serialno,UN.timestamp::date,UN.modelname,UN.username
        ) AS LaunchUnknownPacket
     ),
     list_launch AS
    (
        SELECT username,timestamp::date,serialno FROM list_launchdata
        WHERE timestamp BETWEEN startDate AND endDate
        AND username <> ''
        AND (modelname =  inputModelName OR inputModelName='')
        AND (username =  inputUserName OR inputUserName='')
        GROUP BY timestamp::date,username,serialno
    ),
    list_play AS
    (
        SELECT username, startdatetime::date,serialno
        FROM PlayDatetime
        WHERE tctraffic <> 0 AND intraffic <> 0 AND outtraffic <> 0
        AND username <> ''
        AND timestamp BETWEEN startDate AND endDate
        AND (modelname =  inputModelName OR inputModelName='')
        AND (username =  inputUserName OR inputUserName='')
        GROUP BY username,startdatetime::date,serialno
    )

    SELECT (SELECT COUNT(*) FROM list_play)::NUMERIC/(SELECT COUNT(*) FROM list_launch) AS TBC;
END;
$$
    LANGUAGE PLPGSQL;

        SELECT * FROM ana.get_play_game_times(TIMESTAMP 'today' - interval '30 days',TIMESTAMP 'today');
        --總覽頁&使用行為_平均遊玩次數