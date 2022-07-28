WITH ori_data AS
(
	SELECT 
		to_char((startdatetime + interval '8h'), 'YYYYMMDD') AS date_tag,
		user_id,
		cb.user_name,
		(startdatetime + interval '8h') AS game_start, (enddatetime-startdatetime) AS game_time,
		region
	FROM playdatetime AS p LEFT JOIN ana.cb_user AS cb ON p.serialno=cb.serialno AND p.username::TEXT = cb.user_name
	WHERE activity LIKE '%ES_HK' 
	AND mindping <> -1 AND minvping <> -1 AND maxdping <> 1000 AND maxvping <> 1000
	AND denominator > 50
)

SELECT 
	date_tag,
	region,
	COUNT(*),
	SUM(game_time) AS game_time
FROM ori_data
WHERE game_start >= '2020-05-18 00:00:00+00' AND game_start < '2020-05-25 00:00:00+00' 
GROUP BY date_tag, region
ORDER BY date_tag ASC, region DESC