INSERT INTO bronze.weather (
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
FROM staging.weather;


INSERT INTO bronze.stations (
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
FROM staging.stations;
