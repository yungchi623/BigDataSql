WITH ori_data AS
(
	SELECT 
		to_char((timestamp + interval '8h'), 'YYYYMMDD') AS date_tag,
		user_id,
		cb.user_name,
		(timestamp + interval '8h') AS test_time,
		p.area, 
		ROUND(p.latencytime),
		activity
	FROM latencyrouterandserver AS p LEFT JOIN ana.cb_user AS cb ON p.serialno=cb.serialno AND p.username::TEXT = cb.user_name
	ORDER BY user_id DESC, area DESC, timestamp DESC
)

SELECT * 
FROM ori_data
WHERE user_name = 'nwarp_bxje' AND date_tag = '20200611' AND area IN ('sg-gcp')
