DROP FUNCTION IF EXISTS ana.get_top_game(startDate TIMESTAMP, endDate TIMESTAMP, TopN INT, inputModelName VARCHAR, inputUserName VARCHAR);
CREATE OR REPLACE FUNCTION ana.get_top_game(startDate TIMESTAMP, endDate TIMESTAMP, TopN INT, inputModelName VARCHAR='', inputUserName VARCHAR='')
    RETURNS TABLE (
        numbersOfPlayer NUMERIC,    --登入玩家數
        gameName VARCHAR            --遊戲名稱
    ) AS
$$

BEGIN
    RETURN QUERY
    WITH list_login_game AS
    (
        SELECT PD.username,
        GD.gamename
        FROM PlayDatetime AS PD
        LEFT JOIN GameDetail AS GD ON PD.gameid = GD.gameid
        WHERE GD.language = 'zh_tw' AND tctraffic <> 0 AND intraffic <> 0 AND outtraffic <> 0
        AND PD.username <> ''
        AND timestamp BETWEEN startDate AND endDate
        AND (modelname =  inputModelName OR inputModelName='')
        AND (PD.username =  inputUserName OR inputUserName='')
        GROUP BY GD.gamename, PD.username
    )

    SELECT
    COUNT(*)::NUMERIC AS TOP,
    LLG.gamename
    FROM list_login_game AS LLG
    GROUP BY LLG.gamename
    ORDER BY TOP DESC LIMIT TopN;
END;
$$
    LANGUAGE PLPGSQL;

        SELECT * FROM ana.get_top_game(TIMESTAMP 'today' - interval '30 days',TIMESTAMP 'today',10);
        --總覽頁&使用行為_最多玩家登入的遊戲