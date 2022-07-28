DROP FUNCTION IF EXISTS ana.get_open_rage(startDate TIMESTAMP, endDate TIMESTAMP , inputModelName VARCHAR );
CREATE FUNCTION ana.get_open_rage(startDate TIMESTAMP, endDate TIMESTAMP ,inputModelName VARCHAR='')
    RETURNS TABLE (
        rage NUMERIC    --開機率
    ) AS $$
BEGIN

    RETURN QUERY 
        WITH union_launch AS
        (
            SELECT CASE WHEN EXISTS(SELECT * FROM MemberRegistration WHERE username=LC.username) THEN TRUE ELSE FALSE END AS launch
            FROM lancount AS LC
            WHERE timestamp BETWEEN startDate AND endDate
            AND username <> ''
            AND (modelname =  inputModelName OR inputModelName='')
            GROUP BY username
        ),

        list_regist AS
        (
            SELECT * FROM MemberRegistration 
            WHERE createdat BETWEEN startDate AND endDate
        )

        
    SELECT CASE WHEN (SELECT COUNT(*)::NUMERIC FROM list_regist) <> 0
    THEN
        (SELECT COUNT(*)::NUMERIC FROM union_launch WHERE launch=TRUE) * 100/(SELECT COUNT(*)::NUMERIC FROM list_regist)
    ELSE
        0
    END
    AS percentage;

END;$$
    LANGUAGE PLPGSQL;

SELECT * FROM ana.get_open_rage( TIMESTAMP 'today' - interval '30 days', TIMESTAMP 'today' , 'NWSQ01T');
--總覽頁&使用行為_開機率