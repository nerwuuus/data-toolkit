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





-- Duplicate check on the key observation columns in bronze.weather table.
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



-- Check for missing values in key observation columns in bronze.weather table.
-- Expected result: 0
SELECT COUNT(*) AS null_count
FROM bronze.weather
WHERE
    station IS NULL
    OR observation_date IS NULL
    OR metric IS NULL;



-- Date range checks
-- Expected result:
-- Minimum date: no earlier than 2015-01-01
-- Maximum date: no later than 2026-07-16
-- The maximum expected date will change with future NOAA updates.
SELECT
    MIN(observation_date) AS min_observation_date,
    MAX(observation_date) AS max_observation_date
FROM bronze.weather;



-- Metric distribution and value range check
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
