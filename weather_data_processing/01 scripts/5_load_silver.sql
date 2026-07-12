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

-- Step 1: Truncate and load data into weather_silver table
TRUNCATE TABLE weather_silver;
INSERT INTO weather_silver (
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
FROM weather_bronze
WHERE station LIKE 'PL%';

-- Step 2: Truncate and load data into stations_silver table
TRUNCATE TABLE stations_silver;
INSERT INTO stations_silver (
    station,
    elevation,
    station_name
)
SELECT
    TRIM(station) AS station,
    elevation,
    TRIM(INITCAP(station_name)) AS station_name
FROM stations_bronze
WHERE station LIKE 'PL%';
