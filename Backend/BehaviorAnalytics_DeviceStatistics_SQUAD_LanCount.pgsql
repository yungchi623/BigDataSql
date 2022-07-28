
DROP FUNCTION IF EXISTS ana.get_squad_device_groupby_count(startDate TIMESTAMP, endDate TIMESTAMP, inputModelName VARCHAR);
CREATE FUNCTION ana.get_squad_device_groupby_count(startDate TIMESTAMP, endDate TIMESTAMP, inputModelName VARCHAR='')
    RETURNS TABLE (
 totalNumber NUMERIC,   --裝置數量
 deviceNumber INT       --裝置lan孔使用數
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
    AND (modelname =  inputModelName OR inputModelName='')
    GROUP BY DTL.serialno,DTL.username,devicetype,devicecount
)

SELECT COUNT(*)::NUMERIC,devicecount
FROM list_lan_type
WHERE devicecount IN (1,2,3,4)
GROUP BY devicecount
ORDER BY devicecount;

END; $$
    LANGUAGE PLPGSQL;

    SELECT * FROM ana.get_squad_device_groupby_count(timestamp '2019-07-01',timestamp '2019-09-30','NWSQ01T');
    --使用者行為_使用設備統計_SQUAD_lan數量
