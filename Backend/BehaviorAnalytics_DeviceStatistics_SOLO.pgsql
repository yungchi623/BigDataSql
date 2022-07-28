
DROP FUNCTION IF EXISTS ana.get_solo_device_count(startDate TIMESTAMP, endDate TIMESTAMP, inputModelName VARCHAR);
CREATE FUNCTION ana.get_solo_device_count(startDate TIMESTAMP, endDate TIMESTAMP, inputModelName VARCHAR='')
    RETURNS TABLE (
 deviceNumber NUMERIC,  --裝置數量
 deviceTypes VARCHAR    --裝置型態
) AS $$

BEGIN

    RETURN QUERY
    WITH list_lan_type AS
    (
        SELECT DTL.serialno,DTL.username,devicetype,
            (SELECT MAX(LC.lancount)
                    FROM LanCount AS LC
                    WHERE LC.serialno=DTL.serialno AND LC.username=DTL.username
                    AND LC.timestamp BETWEEN startDate AND endDate
                    AND (modelname =  inputModelName OR inputModelName='')
            ) AS devicecount
        FROM DeviceTypeofLan AS DTL
        WHERE DTL.timestamp BETWEEN startDate AND endDate
        AND (modelname = inputModelName OR inputModelName='')
        GROUP BY DTL.serialno,DTL.username,devicetype,devicecount
        ORDER BY DTL.username
    )

    SELECT COUNT(*)::NUMERIC,devicetype
    FROM list_lan_type
    GROUP BY devicetype;

END; $$
    LANGUAGE PLPGSQL;

    SELECT * FROM ana.get_solo_device_count(timestamp 'today' - interval '7 days',timestamp 'today','SOLO');
    --使用者行為_使用設備統計_SOLO
