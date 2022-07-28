DROP FUNCTION IF EXISTS ana.get_user_top_playtime_a2(startDate TIMESTAMP, endDate TIMESTAMP, TopN INT, inputModelName VARCHAR);
CREATE OR REPLACE FUNCTION ana.get_user_top_playtime_a2(startDate TIMESTAMP, endDate TIMESTAMP, TopN INT, inputModelName VARCHAR='')
    RETURNS TABLE (
        timeRange TEXT, --使用時數
        count NUMERIC   --玩家數量
    ) AS
$$

BEGIN

     RETURN QUERY
WITH
serial_hours AS(
    SELECT * FROM generate_series('2019-01-01 00:00:00'::timestamp,'2019-01-01 23:59:59'::timestamp, '1 hours')
),
get_hours AS
(
    SELECT username,
    EXTRACT
            (
                epoch
                FROM
                (SELECT (SUM(pd.enddatetime-pd.startdatetime))
            )/3600) AS hours
    FROM playdatetime AS PD
    WHERE tctraffic <> 0 AND intraffic <> 0 AND outtraffic <> 0
    AND username<>''
    AND timestamp BETWEEN startDate AND endDate
    AND (modelname =  inputModelName OR inputModelName='')
    GROUP BY username
),
vote_hour AS
(
    SELECT FLOOR(hours/(select (endDate::timestamp)::date-(startDate::timestamp)::date)) AS vote,
    hours/(select (endDate::timestamp)::date-(startDate::timestamp)::date) 
    FROM get_hours
)

SELECT CASE WHEN SH.generate_series::time='23:00:00' THEN to_char( SH.generate_series::time, '>= hh24 時') ELSE CONCAT(to_char( SH.generate_series::time, 'hh24 時'),' ~ ',to_char( SH.generate_series::time + interval '1 hour', 'hh24 時')) END AS timerange,
COUNT(VH.vote)::NUMERIC
FROM serial_hours AS SH
LEFT JOIN vote_hour AS VH ON extract(hour FROM SH.generate_series)=VH.vote
GROUP BY timerange
ORDER BY timerange;

END;
$$
    LANGUAGE PLPGSQL;

    SELECT * FROM ana.get_user_top_playtime_a2(TIMESTAMP '2019-03-01',TIMESTAMP '2019-10-19',15,'');
    --使用者行為_每日使用時長分布