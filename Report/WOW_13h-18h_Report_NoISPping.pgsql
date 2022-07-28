DROP FUNCTION IF EXISTS ana.wow_time3(startDate TIMESTAMP, endDate TIMESTAMP , inputusername VARCHAR , inputserserialno VARCHAR );
CREATE FUNCTION ana.wow_time3(startDate TIMESTAMP, endDate TIMESTAMP ,inputusername VARCHAR='',  inputserserialno VARCHAR  ='')
RETURNS TABLE 
    (
        username VARCHAR,
        serialno VARCHAR,
        dping double precision ,
        vping double precision ,
        dvping double precision ,
        perping double precision,
        dmax double precision ,
        vmin double precision ,
        dmin double precision ,
        vmax double precision 
    ) AS
$$
BEGIN

    RETURN QUERY
    WITH cb_user AS
    (
        SELECT * FROM ana.cb_user
        WHERE activity =  'WoW-C'
    ),
    game AS 
    (
        SELECT 
        pl.username ,
        startdatetime , 
        pl.serialno,
        avgvping , avgdping ,denominator ,peravg , maxdping , minvping,avgispping,mindping,maxvping
        FROM playdatetime AS pl
        LEFT JOIN cb_user AS cb ON pl.username = cb.user_id and pl.serialno= cb.serialno
        WHERE activity =  'WoW-C'
        AND gameid = '28'
        AND timestamp BETWEEN startDate - interval '8 hour' AND endDate - interval '8 hour' --以台灣時間回推搜尋數據在資料庫裡的時間
    ),
    count AS 
    (
        SELECT ga.username , ga.serialno , startdatetime , avgvping , avgdping , denominator ,peravg , maxdping , minvping ,avgispping,mindping,maxvping,
        CASE WHEN minvping-avgispping<115 THEN minvping ELSE minvping-avgispping END AS vmin
        FROM game AS ga
        WHERE startdatetime::time BETWEEN ('13:00'- interval '8 hour')::time  AND ('18:00'- interval '8 hour')::time --台灣時間減八小時為資料庫伺服器時間
    ),
    result AS
    (
        SELECT co.username , co.serialno , SUM(avgdping*denominator) AS dping , SUM((avgvping-avgispping)*denominator) AS vping ,SUM(denominator) AS denominator ,avg(peravg) AS perping , 
        avg(maxdping) AS dmax, AVG(minvping-avgispping) AS vmin, AVG(mindping) AS dmin , AVG(maxvping-avgispping) AS vmax
        FROM count AS co
        GROUP BY co.username, co.serialno
    ),
    report AS
    (
        SELECT re.username , re.serialno , (re.dping/re.denominator) AS dping , (re.vping/re.denominator) AS vvping , re.perping, re.dmax, re.vmin , re.dmin ,re.vmax FROM result AS re
    )
    

    SELECT re.username , re.serialno ,re.dping, vvping , (re.dping-re.vvping) AS dvping, re.perping, re.dmax, re.vmin , re.dmin ,re.vmax FROM report  AS re;
    

END; $$
    LANGUAGE PLPGSQL;

select * from ana.wow_time3 (timestamp '2019-11-18','2019-11-24');
    