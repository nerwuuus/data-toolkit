/*
============================================================================
Stored Procedure: Load Silver Layer (Bronze -> Silver)
============================================================================
Script Purpose:
  This stored procedure performs the ETL (Extract, Transform, Load) process to
  populate the 'silver' schema tables from the 'bronze' schema.
Actions Performed:
  - Truncates Silver tables.
  - Inserts transformed and cleansed data from Bronze into Silver tables.
============================================================================
*/

CALL truncate_and_load_silver();

CREATE OR REPLACE PROCEDURE truncate_and_load_silver()
LANGUAGE plpgsql
AS $$
BEGIN
    -- Step 1: Truncate and load data into silver.weather table
    TRUNCATE TABLE silver.weather;
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
        -- tenths of degrees Celsius (e.g. 221 = 22.1°C).
        -- Divide by 10.0 to convert them to standard Celsius values.
        CASE
            WHEN metric IN ('TAVG', 'TMIN', 'TMAX', 'TOBS') THEN value / 10.0
            ELSE value
        END AS value
    FROM bronze.weather
    WHERE station LIKE 'PL%';

    -- Step 2: Truncate and load data into silver.stations table
    TRUNCATE TABLE silver.stations;
    INSERT INTO silver.stations (
        station,
        elevation,
        station_name
    )
    SELECT
        TRIM(station) AS station,
        elevation,
        TRIM(INITCAP(station_name)) AS station_name -- Capitalize the first letter of each word
    FROM bronze.stations
    WHERE station LIKE 'PL%';

    -- Final message
    RAISE NOTICE 'Silver tables have been successfully updated.';
END;
$$;
