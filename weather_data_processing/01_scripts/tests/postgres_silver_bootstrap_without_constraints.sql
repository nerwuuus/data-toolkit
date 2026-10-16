INSERT INTO silver.weather (
    station,
    observation_date,
    metric,
    value,
    measurement_flag,
    quality_flag,
    source_flag,
    observation_time
)
SELECT
    station,
    observation_date,
    metric,
    value,
    measurement_flag,
    quality_flag,
    source_flag,
    observation_time
FROM bronze.weather;


INSERT INTO silver.stations (
    station,
    latitude,
    longitude,
    elevation,
    state,
    station_name,
    gsn_flag,
    hcn_flag,
    wmo_id
)
SELECT
    station,
    latitude,
    longitude,
    elevation,
    state,
    station_name,
    gsn_flag,
    hcn_flag,
    wmo_id
FROM bronze.stations;
