/*
==============================================================================
Stored Procedure: Load Bronze Layer (Staging -> Bronze)
==============================================================================
Script Purpose:
    This stored procedure incrementally loads raw data from the Staging layer
    into the Bronze layer while preserving source values.

Actions Performed:
    - Reads incoming raw data from Staging tables.
    - Inserts only new records into Bronze tables.
    - Preserves raw source values without analytical transformations.
    - Prevents duplicate records using natural keys and UNIQUE constraints.
    - Verifies that all Staging records are represented in Bronze after the load.
    - Raises an exception if any expected records are missing.
    - Truncates Staging tables only after successful validation.
==============================================================================
*/

CREATE OR REPLACE PROCEDURE load_bronze()
LANGUAGE plpgsql
AS $$
BEGIN
    -- 1. Load data into bronze.weather table
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

    -- 2. Load data into bronze.stations table
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
