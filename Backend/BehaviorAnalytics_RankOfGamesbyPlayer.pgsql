DROP FUNCTION IF EXISTS ana.get_user_top_playnumber_b(startDate TIMESTAMP, endDate TIMESTAMP, TopN INT, inputModelName VARCHAR);
CREATE OR REPLACE FUNCTION ana.get_user_top_playnumber_b(startDate TIMESTAMP, endDate TIMESTAMP, TopN INT, inputModelName VARCHAR='')
    RETURNS TABLE (
        UserName VARCHAR,   --玩家名稱
        GameNumber Bigint   --遊戲數量
    ) AS
$$

BEGIN

    RETURN QUERY 
WITH gat_gameid AS
(
    SELECT PD.username, PD.gameid
    FROM PlayDatetime AS PD
    WHERE tctraffic <> 0 AND intraffic <> 0 AND outtraffic <> 0
    AND PD.username<>''
    AND timestamp BETWEEN startDate AND endDate
    AND (modelname =  inputModelName OR inputModelName='')
    GROUP BY  PD.username, PD.gameid
)


SELECT GA.username, COUNT(GA.gameid) AS TOP
FROM gat_gameid AS GA 
GROUP BY GA.username 
ORDER BY TOP DESC LIMIT TopN;

END;
$$
    LANGUAGE PLPGSQL;

    SELECT * FROM ana.get_user_top_playnumber_b(TIMESTAMP '2019-07-31',TIMESTAMP '2019-09-29',10,'');
    --使用者行為_玩最多款遊戲的玩家排名