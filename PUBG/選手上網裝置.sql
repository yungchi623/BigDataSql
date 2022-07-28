WITH ori_data AS
(
	SELECT 
		user_id,cb.user_name, 
		(timestamp + interval '8h') AS query_date,
		l.lancount,l.portnumber, 
		l.serialno,
		l.modelfw,
		activity
	FROM lancount AS l LEFT JOIN ana.cb_user AS cb ON l.serialno=cb.serialno AND l.username::TEXT = cb.user_name
	 ORDER BY username, timestamp DESC
)

SELECT 
	*
FROM ori_data
WHERE activity LIKE '%ES_TW'
AND query_date >= '2020-05-22 00:00:00+00' 