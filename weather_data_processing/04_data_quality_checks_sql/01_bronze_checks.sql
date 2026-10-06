/*
==============================================================================
Data Quality Checks: Bronze Layer
==============================================================================
Script Purpose:
    This script contains data quality checks for the Bronze layer of the
    weather data pipeline.
    The checks are intended to validate the raw loaded data and confirm that
    the source data is complete, consistent, and suitable for further
    processing.

    The script should be used to check:
        - Row counts in Bronze tables
        - Missing values in key Bronze layer columns
        - Duplicate weather observations
        - Expected observation date ranges
        - Available weather metrics and their value ranges

Bronze Layer:
    Raw weather and station data loaded from source files without analytical
    transformations.

Usage:
    Run this script after the Bronze layer has been created and populated.
==============================================================================
*/

-- Check row counts in Bronze tables
-- Expected result: counts should match the number of records loaded from the source files.
SELECT COUNT(*)
FROM bronze.weather;

SELECT COUNT(*)
FROM bronze.stations;



-- Missing values in key Bronze layer columns.
-- Count only the records where, e.g., station is NULL.
-- Expected result: 0 NULL values in key columns.
SELECT
    COUNT(*) FILTER (WHERE station IS NULL) AS station_nulls,
    COUNT(*) FILTER (WHERE observation_date IS NULL) AS observation_date_nulls,
    COUNT(*) FILTER (WHERE metric IS NULL) AS metric_nulls,
    COUNT(*) FILTER (WHERE value IS NULL) AS value_nulls
FROM bronze.weather;

SELECT
    COUNT(*) FILTER (WHERE station IS NULL) AS station_nulls,
    COUNT(*) FILTER (WHERE station_name IS NULL) AS station_name_nulls,
    COUNT(*) FILTER (WHERE elevation IS NULL) AS elevation_nulls
FROM bronze.stations;
    


-- Duplicate check on the key observation columns.
-- Expected result: No duplicates found.
SELECT
    station,
    observation_date,
    metric
FROM bronze.weather
GROUP BY
    station,
    observation_date,
    metric
HAVING COUNT(*) > 1;

-- Duplicate checks on station identifiers and station names.
-- Expected result: No duplicates found.
SELECT station
FROM bronze.stations
GROUP BY station
HAVING COUNT(*) > 1;

SELECT station_name
FROM bronze.stations
GROUP BY station_name
HAVING COUNT(*) > 1;


-- Date range checks
-- Expected result:
-- Minimum date: no earlier than 2015-01-01
-- Maximum date: no later than 2026-07-16
-- The maximum expected date will change with future NOAA updates.
SELECT
    MIN(observation_date) AS min_observation_date,
    MAX(observation_date) AS max_observation_date
FROM bronze.weather;



-- Metric distribution and value range check in bronze.weather table.
-- Review minimum, maximum, and value range for each weather metric.
SELECT
    metric,
    COUNT(*) AS metric_count,
    MIN(value) AS min_metric_value,
    MAX(value) AS max_metric_value,
    (MAX(value) - MIN(value)) AS metric_delta
FROM bronze.weather
GROUP BY metric
ORDER BY 
    metric_count DESC,
    metric;
