DROP FUNCTION IF EXISTS ana.get_playrage(startDate TIMESTAMP, endDate TIMESTAMP , inputModelName VARCHAR);
CREATE FUNCTION ana.get_playrage(startDate TIMESTAMP, endDate TIMESTAMP ,inputModelName VARCHAR='')
    RETURNS TABLE (
        rage NUMERIC    --遊玩率
    ) AS $$
BEGIN

    RETURN QUERY 
        WITH get_username AS
        (
            SELECT username , serialno
            FROM MemberSessionHistory
            WHERE firstsessionat BETWEEN startDate AND endDate
            GROUP BY username , serialno
        ),
        get_number AS
        (
            SELECT MSH.serialno,MSH.username,
                    CASE WHEN EXISTS (SELECT PL.serialno FROM PlayDateTime AS PL
                    WHERE PL.serialno=MSH.serialno
                    AND (intraffic <>0 AND outtraffic <>0 AND tctraffic <>0)
                    AND PL.timestamp BETWEEN startDate AND endDate 
                    AND (PL.modelname = inputModelName OR inputModelName=''))
                    THEN 1 ELSE 0 END AS getnumber   
                    FROM MemberSessionHistory AS MSH
                    WHERE firstsessionat BETWEEN startDate AND endDate
                    GROUP by MSH.serialno,MSH.username
        ),
      
        get_times AS 
        (
            SELECT username , serialno FROM get_number
            WHERE getnumber = 1
            GROUP BY username , serialno
        ),

        get_user_member AS 
        (
            SELECT COUNT(*) AS countuser FROM get_username
        )

        SELECT (((SELECT COUNT(*) FROM get_times) * 100)::NUMERIC / (SELECT countuser FROM get_user_member)::NUMERIC) AS percentage;

END;$$
    LANGUAGE PLPGSQL;

SELECT * FROM ana.get_playrage (TIMESTAMP 'today' - interval '30 days' , TIMESTAMP 'today');
--總覽頁&使用行為_遊玩率


