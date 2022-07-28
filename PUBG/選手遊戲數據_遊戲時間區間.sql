WITH ori_data AS
(
	SELECT 
		to_char((startdatetime + interval '8h'), 'YYYYMMDD') AS date_tag,
		user_id,
		cb.user_name,
		(startdatetime + interval '8h') AS game_start, 
		(enddatetime + interval '8h') AS game_end,
		region
	FROM playdatetime AS p LEFT JOIN ana.cb_user AS cb ON p.serialno=cb.serialno AND p.username::TEXT = cb.user_name
	WHERE activity LIKE '%ES_HK' 
	AND mindping <> -1 AND minvping <> -1 AND maxdping <> 1000 AND maxvping <> 1000
	AND denominator > 50
),

time_data AS
(
	SELECT 
		date_tag, region, 
		to_char(game_start, 'HH24:MI:SS') AS game_start,
		to_char(game_end, 'HH24:MI:SS') AS game_end,
		CASE
                WHEN EXTRACT(hour from game_start) < 12 THEN 'm'
               	ELSE  'a'
            END AS timerange

	FROM ori_data 
	WHERE 
	game_start >= '2020-05-18 00:00:00+00' AND game_start < '2020-05-25 00:00:00+00'
	ORDER BY date_tag,  region DESC, game_start ASC
),

timerange_data AS(
	SELECT 
		date_tag, region, 
		CONCAT(MIN(game_start), '~', MAX(game_end), '') AS res
		
	FROM time_data
	GROUP BY date_tag,  region, timerange
	ORDER BY date_tag,  region DESC, timerange DESC
)
SELECT 
	date_tag,  region, string_agg(res, ',')
FROM timerange_data
GROUP BY date_tag,  region
ORDER BY date_tag,  region DESC