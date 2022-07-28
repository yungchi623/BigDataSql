DROP FUNCTION IF EXISTS ana.get_opennumber(startDate TIMESTAMP, endDate TIMESTAMP , inputModelName VARCHAR );
CREATE FUNCTION ana.get_opennumber(startDate TIMESTAMP, endDate TIMESTAMP ,inputModelName VARCHAR='')
    RETURNS TABLE (
        sum BIGINT  --開機數
    ) AS $$
BEGIN

    RETURN QUERY 
    WITH get_launch AS
    ( 
        SELECT serialno  FROM lancount
        WHERE timestamp BETWEEN startDate AND endDate
        AND username <> ''
        AND (modelname =  inputModelName OR inputModelName='')
        GROUP BY serialno
    ) 

SELECT count(*) FROM get_launch;

END;$$
    LANGUAGE PLPGSQL;

SELECT * FROM ana.get_opennumber( TIMESTAMP 'today' - interval '30 days',TIMESTAMP 'today' , 'NWSQ01T');
--總覽頁&使用行為_開機數
