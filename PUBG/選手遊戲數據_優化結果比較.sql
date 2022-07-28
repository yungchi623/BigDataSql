WITH teams_ori AS
(
	SELECT 
		cb.activity
	FROM ana.cb_user AS cb
	WHERE cb.activity LIKE '%PUBG_ES_TW%'
	GROUP BY cb.activity
),

teams_order AS
(
	SELECT 
		CASE activity
			WHEN 'PUBG_ES_TW'
			THEN '01'
			WHEN 'PUBG_ES_TW_TTS'
			THEN '02'
			WHEN 'PUBG_ES_TW_STR'
			THEN '03'
			ELSE '99'
			
		END AS ord,
		activity
	FROM teams_ori
),

ori_data AS
(
	SELECT 
		to_char((startdatetime + interval '8h'), 'YYYYMMDD') AS date_tag,
		user_id,
		cb.user_name,
		(startdatetime + interval '8h') AS game_start, 
		(enddatetime + interval '8h') AS game_end, 
		(enddatetime-startdatetime) AS game_time,
		--traceip,
		region,
		maxdping+7 AS maxdping,
		avgdping+7 AS avgdping,
		mindping+7 AS mindping,
		maxvping,
		avgvping,
		minvping,
		maxispping,
		avgispping,
		CASE
			WHEN EXTRACT(hour from (startdatetime + interval '8h')) < 12 THEN 'm'
			ELSE  'a'
        END AS timerange,
		activity
	FROM playdatetime AS p LEFT JOIN ana.cb_user AS cb ON p.serialno=cb.serialno AND p.username::TEXT = cb.user_name
	WHERE --activity LIKE '%PUBG_ES_TW%'
	mindping <> -1 AND minvping <> -1  AND minvping > 10 AND mindping > 10 --AND maxvping < 100
	AND denominator > 50 AND region IN ('sg', 'kr')
)

--SELECT * FROM ori_data WHERE date_tag = '20200611' AND region ='hk'

SELECT 
	user_id,
	user_name,
	region,
	game_start,
	game_end,
	--game_end,
	--region,
	ROUND(maxdping) AS maxdping,
	ROUND(mindping) AS mindping,
	'',
	ROUND(maxvping) AS maxvping,
	ROUND(minvping) AS minvping
	--*
	FROM ori_data 
WHERE user_name='nwarp_bwuv' --date_tag = '20200612' --AND timerange='a'-- AND user_id LIKE '%PH111%'
AND user_id LIKE '%STR%'
ORDER BY game_start ASC, region DESC


/*
SELECT 
	t_o.ord,
	date_tag,
	o.activity,
	region,
	--timerange,
	CONCAT(to_char(MIN(game_start), 'HH24:MI'), '~', to_char(MAX(game_end), 'HH24:MI'), '') AS play_range,
	COUNT(*) AS play_count,
	SUM(game_time) AS total_play_time,
	ROUND(AVG(maxdping)) AS maxdping,
	ROUND(AVG(mindping)) AS mindping,
	'',
	ROUND(AVG(maxvping)) AS maxvping,
	ROUND(AVG(minvping)) AS minvping,
	''
FROM teams_order AS t_o LEFT JOIN ori_data AS o ON o.activity = t_o.activity
WHERE game_start >= '2020-06-12 00:00:00+00' AND game_start < '2020-06-14 23:59:00+00' 
GROUP BY date_tag, region, timerange, o.activity, t_o.ord
ORDER BY date_tag ASC, t_o.ord ASC, region DESC, timerange DESC
*/