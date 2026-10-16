INSERT INTO silver.weather (
    station,
    observation_date,
    metric,
    value
)
SELECT
    station,
    observation_date,
    metric,
    value
FROM bronze.weather;


INSERT INTO silver.stations (
    station,
    elevation,
    station_name
)
SELECT
    station,
    elevation,
    station_name
FROM bronze.stations;
