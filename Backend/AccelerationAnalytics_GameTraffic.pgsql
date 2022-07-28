DROP FUNCTION IF EXISTS ana.get_traffic(startDate TIMESTAMP, endDate TIMESTAMP, modelname  TEXT );
CREATE FUNCTION ana.get_traffic(startDate TIMESTAMP, endDate TIMESTAMP , select_modelname TEXT)
    RETURNS TABLE (
        gamename VARCHAR,               --遊戲名稱
        servername VARCHAR,             --N-Warp加速節點
        playtimes BIGINT,               --遊玩次數
        playhours DOUBLE PRECISION,     --遊玩時數
        sumtraffic_GB DOUBLE PRECISION, --總流量(GB)=inTraffic+outTraffic
        avgtraffic_GB DOUBLE PRECISION, --平均流量(GB)
        maxtraffic_GB DOUBLE PRECISION  --總流量(GB)=MAX(inTraffic,outTraffic)
    ) AS $$
BEGIN

    RETURN QUERY 
    WITH get_gameid AS 
    (
        SELECT PD.gameid , PD.region , 
        EXTRACT
                (
                    epoch
                    FROM
                    (SELECT (SUM(PD.enddatetime-PD.startdatetime))
                )/3600) AS playhour 
        FROM PlayDateTime AS PD
        WHERE intraffic <>0 AND outtraffic <>0 AND tctraffic <>0
        AND startdatetime BETWEEN startDate AND endDate 
        AND modelname = select_modelname
        GROUP BY PD.gameid , PD.region 
        ORDER BY PD.gameid ASC
    ),


    getplaytimes AS
    (
        SELECT gameid , region AS region,COUNT(*) AS times   
        FROM PlayDateTime
        WHERE intraffic <>0 AND outtraffic <>0 AND tctraffic <>0
        AND startdatetime BETWEEN startDate AND endDate 
        AND modelname = select_modelname   
        GROUP BY gameid , region 
        ORDER BY gameid ASC
    ),

    gettraffic AS
    (
        SELECT 
            gameid , 
            region , 
            intraffic+outtraffic AS sumtraffic,
            (
                CASE 
                WHEN intraffic > outtraffic THEN intraffic 
                ELSE outtraffic END 
            ) AS maxtraffic  
        FROM PlayDateTime
        WHERE intraffic <>0 AND outtraffic <>0 AND tctraffic <>0 
        AND startdatetime BETWEEN startDate AND endDate AND modelname = select_modelname
        ORDER BY gameid ASC
    ),

    retraffic AS
    (
        SELECT gameid , region , 
        SUM(sumtraffic)/1024/1024/1024 AS sumtraffic , 
        AVG(sumtraffic)/1024/1024/1024 AS avgtraffic ,
        SUM(maxtraffic)/1024/1024/1024 AS maxtraffic
        FROM gettraffic 
        GROUP BY gameid , region 
        ORDER BY gameid ASC
    ),

    garesule AS
    (
        SELECT G.gameid , G.region ,G.playhour , GP.times 
        FROM get_gameid AS G 
        LEFT JOIN getplaytimes AS GP ON G.gameid=GP.gameid AND G.region = GP.region
    ),

    gtresule AS
    (
        SELECT GA.gameid , GA.region , GA.playhour , GA.times , GT.sumtraffic , GT.avgtraffic ,GT.maxtraffic 
        FROM garesule AS GA 
        LEFT JOIN  retraffic AS GT ON GA.gameid = GT.gameid AND GA.region = GT.region
    )

    SELECT  GM.gamename , GT.region , GT.times , GT.playhour, GT.sumtraffic ,GT.avgtraffic ,GT.maxtraffic
    FROM gtresule AS GT
    LEFT JOIN gamedetail AS GM ON GT.gameid = GM.gameid 
    WHERE GM.language ='zh_tw'
    ORDER BY GM.gamename ASC;


END;
$$
    LANGUAGE PLPGSQL;

SELECT * FROM ana.get_traffic(TIMESTAMP 'today'-interval '30 days',TIMESTAMP 'today' , 'NWSQ01T'::TEXT);
--加速成效分析_遊玩遊戲流量