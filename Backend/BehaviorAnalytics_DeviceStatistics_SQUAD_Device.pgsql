
DROP FUNCTION IF EXISTS ana.get_squad_device_groupby_device(startDate TIMESTAMP, endDate TIMESTAMP, inputModelName VARCHAR, inputDeviceCount INT);
CREATE FUNCTION ana.get_squad_device_groupby_device(startDate TIMESTAMP, endDate TIMESTAMP, inputModelName VARCHAR='',inputDeviceCount INT=-1)
    RETURNS TABLE (                                                                                                     --裝置lan孔使用數
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
    AND (modelname =  inputModelName OR inputModelName='')
    GROUP BY DTL.serialno,DTL.username,devicetype,devicecount
    ORDER BY DTL.username
)

SELECT COUNT(*)::NUMERIC,devicetype
FROM list_lan_type
WHERE (devicecount=inputDeviceCount OR inputDeviceCount=-1)
GROUP BY devicetype;

END; $$
    LANGUAGE PLPGSQL;

    SELECT * FROM ana.get_squad_device_groupby_device(timestamp '2019-07-31',timestamp '2019-10-31','NWSQ01T',-1);
    --使用者行為_使用設備統計_SQUAD_裝置
