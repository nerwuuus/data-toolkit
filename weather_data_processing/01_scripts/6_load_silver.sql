/*
==============================================================================
Stored Procedure: Load Silver Layer (Bronze -> Silver)
==============================================================================
Script Purpose:
    This stored procedure performs the ETL process used to incrementally load
    transformed and cleansed data from the Bronze layer into the Silver layer.

Actions Performed:
    - Inserts only new records from Bronze into Silver.
    - Applies data cleaning and transformation rules.
    - Prevents duplicate records using natural keys and UNIQUE constraints.
    - Preserves existing Silver data between pipeline runs.
==============================================================================
*/

CREATE OR REPLACE PROCEDURE load_silver()
LANGUAGE plpgsql
AS $$
BEGIN
    -- 1. Load data into silver.weather table
    INSERT INTO silver.weather (
        station,
        observation_date,
        metric,
        value
    )
    SELECT
        TRIM(station) AS station,
        observation_date,
        metric,
        -- NOAA temperature observations are stored as integers representing
        -- tenths of a degree Celsius (e.g. 221 = 22.1°C).
        -- Divide by 10 to convert them to degrees Celsius.
        CASE
            WHEN metric IN ('TAVG', 'TMIN', 'TMAX') THEN value / 10.0
            ELSE value
        END AS value
    FROM bronze.weather bw
    WHERE NOT EXISTS (
        SELECT 1
        FROM silver.weather sw
        WHERE
            TRIM(bw.station) = sw.station
            AND bw.observation_date = sw.observation_date
            AND bw.metric = sw.metric
    )
    ON CONFLICT (station, observation_date, metric) DO NOTHING;

    -- 2. Load data into silver.stations table
    INSERT INTO silver.stations (
        station,
        elevation,
        station_name
    )
    SELECT
        TRIM(station) AS station,
        CASE
            WHEN elevation <= -999.9 THEN NULL
            ELSE elevation
        END AS elevation,
    -- Capitalize the first letter of each word
    TRIM(INITCAP(station_name)) AS station_name
    FROM bronze.stations bs
    WHERE NOT EXISTS (
        SELECT 1
        FROM silver.stations ss
        WHERE TRIM(bs.station) = ss.station
    )
    ON CONFLICT (station) DO NOTHING;

    -- 3. Final message
    RAISE NOTICE 'Silver tables have been successfully updated.';
END;
$$;

CALL load_silver();



-- Debug: check the actual data type and numeric precision of silver.weather.value
-- Useful when PostgreSQL reports a numeric overflow error.
-- SELECT
--     column_name,
--     data_type,
--     numeric_precision,
--     numeric_scale
-- FROM information_schema.columns
-- WHERE table_schema = 'silver'
--   AND table_name = 'weather'
--   AND column_name = 'value';
