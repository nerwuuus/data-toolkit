/*
==============================================================================
Staging-to-Bronze Incremental Load Tests
==============================================================================
Script Purpose:
    This script is used to test different approaches for incremental loading
    between the Staging and Bronze layers.

    The test tables are intentionally small and isolated from the main pipeline
    so that loading logic can be developed and verified safely.

    This script may contain experiments with:
        - NOT EXISTS
        - LEFT JOIN ... IS NULL
        - UNIQUE constraints
        - ON CONFLICT DO NOTHING
        - Watermark-based loading
        - Duplicate prevention
        - Re-running the same load safely

Usage:
    Use this script as a sandbox for testing incremental loading logic before
    applying it to the main weather pipeline.
==============================================================================
*/

/*
==============================================================================
1. Test Tables Setup
==============================================================================
*/
DROP TABLE IF EXISTS staging.stations_test;
CREATE TABLE staging.stations_test (
    station VARCHAR(11),
    latitude NUMERIC(8,4),
    longitude NUMERIC(9,4),
    elevation NUMERIC(6,1),
    state VARCHAR(50),
    station_name VARCHAR(100),
    gsn_flag VARCHAR(3),
    hcn_flag VARCHAR(3),
    wmo_id NUMERIC(6,1),
    insert_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

DROP TABLE IF EXISTS bronze.weather_test;
CREATE TABLE bronze.weather_test (
    station VARCHAR(11),
    observation_date DATE,
    metric VARCHAR(4),
    value INTEGER,
    measurement_flag CHAR(1),
    quality_flag CHAR(1),
    source_flag CHAR(1),
    observation_time VARCHAR(10),
    insert_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT uq_weather_station_date_metric
    UNIQUE (
        station,
        observation_date,
        metric
    )
);

DROP TABLE IF EXISTS bronze.stations_test;
CREATE TABLE bronze.stations_test (
    station VARCHAR(11),
    latitude NUMERIC(8,4),
    longitude NUMERIC(9,4),
    elevation NUMERIC(6,1),
    state VARCHAR(50),
    station_name VARCHAR(100),
    gsn_flag VARCHAR(3),
    hcn_flag VARCHAR(3),
    wmo_id NUMERIC(6,1),
    insert_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT uq_weather_station
    UNIQUE (station)
);

DROP TABLE IF EXISTS staging.weather_test;
CREATE TABLE staging.weather_test (
    station VARCHAR(11),
    observation_date DATE,
    metric VARCHAR(4),
    value INTEGER,
    measurement_flag CHAR(1),
    quality_flag CHAR(1),
    source_flag CHAR(1),
    observation_time VARCHAR(10),
    insert_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

/*
==============================================================================
2. Metadata and Table Inspection
==============================================================================
*/
SELECT * 
FROM information_schema.tables 
WHERE table_schema = 'staging';

/*
==============================================================================
3. Load Sample Data
==============================================================================
*/
-- Load sample weather data into staging.weather_test
INSERT INTO staging.weather_test (
    station,
    observation_date,
    metric,
    value,
    measurement_flag,
    quality_flag,
    source_flag,
    observation_time
)
VALUES
    ('PL000000001', '2026-10-01', 'TAVG', 125, NULL, NULL, 'A', '1200'),
    ('PL000000001', '2026-10-01', 'TMAX', 178, NULL, NULL, 'A', '1200'),
    ('PL000000001', '2026-10-01', 'TMIN', 72,  NULL, NULL, 'A', '1200'),
    ('PL000000002', '2026-10-01', 'PRCP', 15,  NULL, NULL, 'A', '1200'),
    ('PL000000002', '2026-10-02', 'TAVG', 110, NULL, NULL, 'A', '1200'),
    ('PL000000003', '2026-10-02', 'SNWD', 0,   NULL, NULL, 'A', '1200');

-- Load sample stations data into staging.stations_test
INSERT INTO staging.stations_test (
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
VALUES
    ('PL000000001', 52.4210, 16.8260, 86.0, 'WP', 'POZNAN TEST', NULL, NULL, 12345),
    ('PL000000002', 52.2297, 21.0122, 112.0, 'MZ', 'WARSAW TEST', NULL, NULL, 23456),
    ('PL000000003', 50.0647, 19.9450, 219.0, 'MA', 'KRAKOW TEST', NULL, NULL, 34567);

/*
==============================================================================
4. Incremental Load Tests
==============================================================================
*/
-- weather
INSERT INTO bronze.weather_test (
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
FROM staging.weather_test sw
WHERE NOT EXISTS (
    SELECT *
    FROM bronze.weather_test bw
    WHERE
        sw.station = bw.station 
        AND sw.observation_date = bw.observation_date 
        AND sw.metric = bw.metric
)
ON CONFLICT (station, observation_date, metric) DO NOTHING;

-- stations
INSERT INTO bronze.stations_test (
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
FROM staging.stations_test ss
WHERE NOT EXISTS (
    SELECT *
    FROM bronze.stations_test bs
    WHERE ss.station = bs.station 
)
ON CONFLICT (station) DO NOTHING;  

-- Check
SELECT *
FROM bronze.weather_test;

SELECT *
FROM bronze.stations_test;
