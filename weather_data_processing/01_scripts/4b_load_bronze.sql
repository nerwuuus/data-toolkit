/*
============================================================================
Stored Procedure: Load Bronze Layer (Staging -> Bronze)
============================================================================
Script Purpose:
  This stored procedure performs the load process to populate the 'bronze'
  schema tables from the 'staging' schema.

Actions Performed:
  - Reads incoming raw data from Staging tables.
  - Inserts new records into Bronze tables.
  - Preserves raw source values without analytical transformations.
  - Prevents already existing records from being loaded again.
============================================================================
*/

CREATE OR REPLACE PROCEDURE load_bronze()
LANGUAGE plpgsql
AS $$
BEGIN
    -- 1. Load weather data
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
    FROM staging.weather sw
    WHERE NOT EXISTS (
        SELECT 1
        FROM bronze.weather bw
        WHERE
            sw.station = bw.station
            AND sw.observation_date = bw.observation_date
            AND sw.metric = bw.metric
    )
    ON CONFLICT (station, observation_date, metric) DO NOTHING;

    -- 2. Load stations data
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
    FROM staging.stations ss
    WHERE NOT EXISTS (
        SELECT 1
        FROM bronze.stations bs
        WHERE ss.station = bs.station
    )
    ON CONFLICT (station) DO NOTHING;

    -- 3. Verify that all staging weather rows exist in bronze.weather.
    IF EXISTS (
        SELECT 1
        FROM staging.weather sw
        WHERE NOT EXISTS (
            SELECT 1
            FROM bronze.weather bw
            WHERE
                sw.station = bw.station
                AND sw.observation_date = bw.observation_date
                AND sw.metric = bw.metric
        )
    ) THEN
        RAISE EXCEPTION 'Missing weather rows in bronze.weather.';
    END IF;

    -- 4. Verify that all staging station rows exist in bronze.stations.
    IF EXISTS (
        SELECT 1
        FROM staging.stations ss
        WHERE NOT EXISTS (
            SELECT 1
            FROM bronze.stations bs
            WHERE ss.station = bs.station
        )
    ) THEN
        RAISE EXCEPTION 'Missing station rows in bronze.stations.';
    END IF;

    -- 5. Truncate staging tables only after successful validation.
    TRUNCATE TABLE staging.weather;
    TRUNCATE TABLE staging.stations;

    -- 6. Final message
    RAISE NOTICE 'Bronze tables have been successfully updated.';
END;
$$;

CALL load_bronze();
