DROP FUNCTION IF EXISTS ana.get_playdatetimes_ping_jitter(startDate TIMESTAMP, endDate TIMESTAMP, inputModelName VARCHAR);
CREATE OR REPLACE FUNCTION ana.get_playdatetimes_ping_jitter(startDate TIMESTAMP, endDate TIMESTAMP, inputModelName VARCHAR='')
    RETURNS TABLE (
        beforePing NUMERIC,     --加速前Ping值
        afterPing NUMERIC,      --加速後Ping值
        beforeJitter NUMERIC,   --加速前Jitter值
        afterJitter NUMERIC,    --加速後Jitter值
        region VARCHAR,         --遊戲伺服器
        area TEXT,              --地區
        timeRegion TEXT         --時間區間
    ) AS
$$

BEGIN

    RETURN QUERY WITH list_tw_area AS
(
    SELECT serialno,
        CASE manualcity WHEN '基隆市' THEN '北'
            WHEN '台北市' THEN '北'
            WHEN '新北市' THEN '北'
            WHEN '桃園市' THEN '北'
            WHEN '新竹市' THEN '北'
            WHEN '新竹縣' THEN '北'
            WHEN '宜蘭縣' THEN '北'
            WHEN '苗栗縣' THEN '中'
            WHEN '台中市' THEN '中'
            WHEN '南投縣' THEN '中'
            WHEN '彰化縣' THEN '中'
            WHEN '雲林縣' THEN '中'
            WHEN '嘉義市' THEN '南'
            WHEN '嘉義縣' THEN '南'
            WHEN '台南市' THEN '南'
            WHEN '高雄市' THEN '南'
            WHEN '屏東縣' THEN '南'
            WHEN '澎湖縣' THEN '南'
            WHEN '花蓮縣' THEN '東'
            WHEN '台東縣' THEN '東'
            WHEN '金門縣' THEN '福建'
            WHEN '連江縣' THEN '福建'
            ELSE '其他'
        END AS arearegion,
        username,
        timestamp
    FROM routerArea
    WHERE manualcountry = '台灣'
    AND timestamp BETWEEN startDate AND endDate
)
    SELECT  SUM(avgDping*denominator)::NUMERIC AS beforePing,
            SUM((avgVping-avgispping)*denominator)::NUMERIC AS afterPing,
            SUM(totalVjitter)::NUMERIC AS beforeJitter,
            SUM(totalDjitter)::NUMERIC AS afterJitter,
            PD.region,
            CASE WHEN EXISTS
            (
                SELECT arearegion
                FROM list_tw_area
                WHERE serialno=PD.serialno AND username=PD.username
            )
            THEN 
            (
                SELECT arearegion
                FROM list_tw_area
                WHERE serialno=PD.serialno AND username=PD.username
                ORDER BY timestamp DESC LIMIT 1
            ) 
            ELSE '其他'END AS area,
            CASE
                WHEN EXTRACT(hour from startdatetime) < 8 THEN '早'
                WHEN EXTRACT(hour from startdatetime) >= 8 AND EXTRACT(hour from startdatetime) < 16 THEN '中'
                WHEN EXTRACT(hour from startdatetime) >= 16 THEN '晚'
            END AS timerange
    FROM playdatetime AS PD
    WHERE tctraffic <> 0 AND intraffic <> 0 AND outtraffic <> 0 AND avgVping <> 0 AND avgDping <> 0 AND totalDjitter <> 0 AND totalVjitter <> 0
    AND timestamp BETWEEN startDate AND endDate
    AND (modelname =  inputModelName OR inputModelName='')
    GROUP BY area,timerange,PD.region;

END;
$$
    LANGUAGE PLPGSQL;

        SELECT * FROM ana.get_playdatetimes_ping_jitter(TIMESTAMP 'today' - interval '30 days',TIMESTAMP 'today','NWSQ01T');
        --加速成效分析_加速前後的數據比較(SUM)