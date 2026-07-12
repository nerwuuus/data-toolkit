CREATE TABLE weather_silver AS
SELECT
    station,
    date,
    metric,
    value
FROM weather_bronze
WHERE station LIKE '%PL'-- PL and PLM
    AND metric IN (
        'TAVG', 'TMIN', 'TMAX', 'PRCP'
    );
