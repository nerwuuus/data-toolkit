/*
==============================================================================
Data Quality Script: Validate Weather Data Pipeline
==============================================================================

Script Purpose:
    This script contains data quality checks for the weather data pipeline.

    The checks are intended to validate data across the Bronze, Silver, and Gold
    layers and confirm that the pipeline not only runs successfully, but also
    produces complete, consistent, and reasonable analytical data.

    The script should be used to check:
        - Row counts in key tables and views
        - Missing values in important columns
        - Duplicate weather observations
        - Expected date ranges
        - Realistic ranges for weather metric values
        - Station metadata coverage after joining observations with stations.

Pipeline Layers:
    Bronze:
        Raw loaded data from source files.

    Silver:
        Cleaned and standardised weather and station data.

    Gold:
        Analysis-ready weather observations joined with station metadata.

Usage:
    Run this script after the Bronze, Silver, and Gold layers have been created.

==============================================================================
*/

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



-- Check for missing values in key observation columns
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






















