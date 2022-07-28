DROP FUNCTION IF EXISTS ana.get_user_login(startDate TIMESTAMP, endDate TIMESTAMP , inputModelName VARCHAR);
CREATE FUNCTION ana.get_user_login(startDate TIMESTAMP, endDate TIMESTAMP ,inputModelName VARCHAR='')
    RETURNS TABLE (
        login NUMERIC    --登入率
    ) AS $$
BEGIN

    RETURN QUERY 
WITH list_login AS
(
    SELECT CASE WHEN EXISTS(SELECT * FROM lancount WHERE serialno=MSH.serialno AND username=MSH.username AND username <> '') THEN TRUE ELSE FALSE END AS launch
    FROM MemberSessionHistory AS MSH
    WHERE firstsessionat BETWEEN startDate AND endDate
    GROUP BY serialno,username
),
union_launch AS
(
    SELECT serialno FROM lancount
    WHERE timestamp BETWEEN startDate AND endDate
    AND username <> ''
    AND (modelname =  inputModelName OR inputModelName='')
    GROUP BY serialno
)

SELECT CASE WHEN (SELECT COUNT(*)::NUMERIC FROM union_launch) <> 0
THEN
    (SELECT COUNT(*)::NUMERIC FROM list_login WHERE launch=TRUE) * 100/(SELECT COUNT(*)::NUMERIC FROM union_launch)
ELSE
    0
END
AS percentage;

END;$$
    LANGUAGE PLPGSQL;

SELECT * FROM ana.get_user_login(TIMESTAMP 'today' - interval '7 days' , TIMESTAMP 'today');
--總覽頁&使用行為_登入率

