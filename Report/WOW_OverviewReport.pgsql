DROP FUNCTION IF EXISTS ana.get_report(startDate timestamp, endDate timestamp);
CREATE FUNCTION ana.get_report(startDate timestamp, endDate timestamp) --建立一個function回傳一個資料表 ana.get_report(資料表名稱)

    RETURNS TABLE (
  report_time_range text,
  report_user_name text, 
  report_user_id text,
  report_serialno text,
  report_islaunch integer, --有無開機
  report_launchtime text, --登入時間
  report_islogin integer, --有無登入
  report_isplay integer, --有無玩遊戲
  report_gamename varchar, --遊戲名稱
  report_total_play_hour double precision, --總遊玩時間
  report_lastloginedat text,
  report_real_interval_hour double precision, --從開機到現在開了幾小時
  report_username varchar,
  report_issameid text,
  report_nickname varchar,
  report_issamename text,
  report_usage double precision, --遊玩率
  report_iscorrect text --判斷資料正確性
) AS $$
BEGIN

     RETURN QUERY 
     WITH cb_user AS
(
    SELECT * FROM ana.cb_user
    WHERE activity ='WoW-C'
),

get_launch AS
(
    SELECT 
        serialno,
        CASE WHEN EXISTS (SELECT 1 FROM lancount WHERE serialno=cb.serialno AND timestamp BETWEEN startDate AND endDate) THEN 1 ELSE 0 END AS landata,
        (SELECT timestamp FROM lancount WHERE serialno=cb.serialno AND timestamp BETWEEN startDate AND endDate ORDER BY timestamp ASC LIMIT 1) AS landate,
        CASE WHEN EXISTS (SELECT 1 FROM playdatetime WHERE serialno=cb.serialno AND timestamp BETWEEN startDate AND endDate) THEN 1 ELSE 0 END AS playdata,
        (SELECT timestamp FROM playdatetime WHERE serialno=cb.serialno AND timestamp BETWEEN startDate AND endDate ORDER BY timestamp ASC LIMIT 1) AS playdate,
        CASE WHEN EXISTS (SELECT 1 FROM unknownpacket WHERE serialno=cb.serialno AND timestamp BETWEEN startDate AND endDate) THEN 1 ELSE 0 END AS unknowndata,
        (SELECT timestamp FROM unknownpacket WHERE serialno=cb.serialno AND timestamp BETWEEN startDate AND endDate ORDER BY timestamp ASC LIMIT 1) AS unknowndate
    FROM cb_user cb
),
launch_status AS
(
    SELECT 
        cb.serialno,
        CASE WHEN gl.landata = 1 OR gl.playdata=1 OR gl.unknowndata=1 THEN 1 ELSE 0 END AS islaunch,
        CASE WHEN gl.landata = 1 THEN gl.landate WHEN gl.playdata=1 THEN gl.playdate ELSE gl.unknowndate END AS firstlaunch
    FROM cb_user AS cb
    LEFT JOIN get_launch AS gl ON cb.serialno=gl.serialno
),
first_date AS
(
    SELECT 
        ROW_NUMBER() OVER (PARTITION BY serialno ORDER BY firstlaunch ASC) AS row,
        serialno,
        CASE WHEN firstlaunch >= startDate THEN firstlaunch ELSE startDate END AS first_date
    FROM launch_status
),

open_interval_hour AS
(
    SELECT 
        serialno,
        first_date,
        (SELECT COUNT(*) FROM lancount WHERE serialno = fd.serialno) AS total_open_hour,
        ROUND(extract
        (
            epoch
            FROM
            (SELECT (endDate-fd.first_date))
        )/3600) AS real_interval_hour
        
    FROM first_date AS fd
    WHERE row = 1
),
account_list AS
(
    SELECT 
        ROW_NUMBER() OVER (PARTITION BY serialno ORDER BY lastloginedat DESC) AS row, 
        *
    FROM BetaTester
    WHERE lastloginedat BETWEEN startDate AND endDate
),
login_status AS
(
        SELECT 
        serialno,
        CASE WHEN EXISTS (SELECT 1 FROM MemberSerialNo WHERE serialno=cb.serialno AND loginedat BETWEEN startDate AND endDate) THEN 1 ELSE 0 END AS islogin
    FROM cb_user cb
),
playgame_status AS
(
        SELECT 
        serialno,
        CASE WHEN EXISTS (SELECT 1 FROM playdatetime WHERE serialno=cb.serialno AND startdatetime BETWEEN startDate AND endDate) THEN 1 ELSE 0 END AS isplay
        FROM cb_user cb
),
play_sum AS
(
    SELECT 
        pd.serialno, 
        gd.gamename,
        pd.gameid,
        SUM(pd.enddatetime-pd.startdatetime),
        extract
            (
                epoch
                FROM
                (SELECT (SUM(pd.enddatetime-pd.startdatetime) )
            )/3600) AS total_play_hour
    FROM playdatetime AS pd
    LEFT JOIN gamedetail AS gd ON pd.gameid = gd.gameid
    WHERE gd.language='en_us'
    AND startdatetime BETWEEN startDate AND endDate
    GROUP BY pd.serialno,gd.gamename,pd.gameid
),
play_traffichour AS
(
    SELECT 
        ps.serialno,
        SUM(ps.total_play_hour) AS total_play_hour
    FROM play_sum AS ps
    LEFT JOIN open_interval_hour AS oin ON ps.serialno = oin.serialno
    GROUP BY ps.serialno
)

SELECT  CONCAT(to_char( startDate, 'YYYY-MM-DD'),'~',to_char( endDate, 'YYYY-MM-DD')),
        CASE WHEN cb.user_name IS NULL THEN '' ELSE cb.user_name END,
        CASE WHEN cb.user_id IS NULL THEN '' ELSE cb.user_id END,
        cb.serialno,
        laun.islaunch,
        to_char(laun.firstlaunch+ interval '8 hour', 'YYYY-MM-DDThh24:MI:SS.MSZ'),
        login.islogin,
        pg.isplay,
        CASE WHEN ps.gamename IS NULL THEN ''ELSE ps.gamename END,
        CASE WHEN ps.total_play_hour IS NULL THEN 0 ELSE ps.total_play_hour END,
        to_char(acc.lastloginedat + interval '8 hour', 'YYYY-MM-DDThh24:MI:SS.MSZ') AS lastloginedat,
        CASE WHEN laun.firstlaunch IS NULL THEN 0 ELSE oin.real_interval_hour END,
        CASE WHEN acc.username IS NULL THEN '' ELSE acc.username END,
        CASE WHEN cb.user_id=acc.username THEN '相同' ELSE '不相同' END,
        CASE WHEN acc.nickname IS NULL THEN '' ELSE acc.nickname END,
        CASE WHEN cb.user_name=acc.nickname THEN '' ELSE cb.user_name END,
        CASE WHEN laun.firstlaunch IS NOT NULL THEN pt.total_play_hour/oin.real_interval_hour ELSE 0 END,
        CASE WHEN laun.islaunch=0 AND (login.islogin=1 OR pg.isplay=1) THEN '錯誤' ELSE '' END
FROM cb_user cb
LEFT JOIN account_list AS acc ON cb.serialno = acc.serialno AND acc.row=1
LEFT JOIN launch_status AS laun ON cb.serialno = laun.serialno
LEFT JOIN login_status AS login ON cb.serialno = login.serialno
LEFT JOIN playgame_status AS pg ON cb.serialno = pg.serialno
LEFT JOIN play_sum AS ps ON cb.serialno = ps.serialno
LEFT JOIN open_interval_hour AS oin ON cb.serialno = oin.serialno
LEFT JOIN play_traffichour AS pt ON cb.serialno = pt.serialno
ORDER BY cb.seq;
END; $$
    LANGUAGE PLPGSQL;
select * from ana.get_report(timestamp '2019-11-11 00:00:00' - interval '8 hour', timestamp '2019-11-17 23:59:59' - interval '8 hour');