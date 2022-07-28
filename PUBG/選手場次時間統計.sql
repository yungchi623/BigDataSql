SELECT region, COUNT(*),SUM(enddatetime-startdatetime) AS game_time
FROM playdatetime AS p LEFT JOIN ana.cb_user AS cb ON p.serialno=cb.serialno AND p.username::TEXT = cb.user_name
WHERE activity LIKE '%ES_TW' AND timestamp > '2020-05-03 16:00:00+00' AND timestamp < '2020-05-06 16:00:00+00'-- GROUP BY cb.user_name,user_id
AND minvping not in (5, 6, 7, 8, 9, 10) group by region