WITH ori_data AS
(
	SELECT 
		to_char((startdatetime + interval '8h'), 'YYYYMMDD') AS date_tag,
		user_id,
		cb.user_name,
		(startdatetime + interval '8h') AS game_start, 
		(enddatetime + interval '8h') AS game_end, 
		(enddatetime-startdatetime) AS game_time,
		region,
		maxdping,
		mindping,
		maxvping,
		minvping,
		CASE
			WHEN EXTRACT(hour from (startdatetime + interval '8h')) < 12 THEN 'm'
			ELSE  'a'
        END AS timerange
	FROM playdatetime AS p LEFT JOIN ana.cb_user AS cb ON p.serialno=cb.serialno AND p.username::TEXT = cb.user_name
	WHERE activity LIKE '%ES_TW' 
	AND mindping <> -1 AND minvping <> -1 AND maxdping <> 1000 AND maxvping <> 1000
	AND denominator > 50
)
/*
SELECT * FROM ori_data 
WHERE date_tag = '20200522'
ORDER BY game_start DESC, region DESC
*/

SELECT 
	date_tag,region,
	timerange,
	
	ROUND(AVG(maxdping))+7 AS maxdping,
	ROUND(AVG(mindping))+7 AS mindping,
	'',
	ROUND(AVG(maxvping)) AS maxvping,
	ROUND(AVG(minvping)) AS minvping,
	''
FROM ori_data
WHERE game_start >= '2020-05-18 00:00:00+00' AND game_start < '2020-05-25 00:00:00+00' 
GROUP BY date_tag, region, timerange
ORDER BY date_tag ASC, region DESC, timerange DESC
