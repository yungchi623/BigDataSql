DROP FUNCTION IF EXISTS ana.get_play_number(startDate TIMESTAMP, endDate TIMESTAMP , inputModelName VARCHAR, inputAccountName VARCHAR);
CREATE OR REPLACE FUNCTION ana.get_play_number(startDate TIMESTAMP, endDate TIMESTAMP ,inputModelName VARCHAR='', inputAccountName VARCHAR='')
    RETURNS TABLE (
        number bigint   --遊玩數
    ) AS $$
BEGIN

    RETURN QUERY 
    WITH get_number AS
        (
            SELECT serialno,username FROM PlayDateTime
            WHERE  intraffic <>0 AND outtraffic <>0 AND tctraffic <>0 
            AND startdatetime BETWEEN startDate AND endDate 
            AND (modelname = inputModelName OR inputModelName='') 
            AND (username = inputAccountName OR inputAccountName='')
            GROUP BY serialno , username
        )

        SELECT COUNT(*) FROM get_number;
        

END;$$

    LANGUAGE PLPGSQL;

    SELECT * FROM ana.get_play_number(TIMESTAMP 'today' -interval '30 days', TIMESTAMP 'today');
    --總覽頁&使用行為_遊玩數