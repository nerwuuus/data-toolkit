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

-- Duplicate check on the full bronze.weather table.
-- Expected result:
-- No duplicate observations found for station, observation_date, and metric.
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

-- Row count checks
SELECT COUNT(*)
FROM bronze.weather
WHERE station IS NULL;

-- NULL checks
-- Check for NULL station identifiers
-- Expected result: 0
SELECT COUNT(*)
FROM bronze.weather
WHERE station IS NULL;




-- Date range checks


-- Metric value range checks


-- Join coverage checks




















