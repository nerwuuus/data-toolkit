/*
==============================================================================
Data Quality Checks: Gold Layer
==============================================================================
Script Purpose:
    This script contains data quality checks for the Gold layer of the
    weather data pipeline.
    The checks are intended to validate analysis-ready weather data enriched
    with station metadata and confirm that joins and final transformations
    produced complete and consistent results.
    
The script should be used to check:
    - Missing values in important Gold layer columns
    - Duplicate analytical records
    - Expected observation date ranges
    - Station metadata completeness after the Silver-to-Gold join
    - Data completeness after Silver-to-Gold transformations

Gold Layer:
    Analysis-ready weather observations enriched with station metadata and
    prepared for reporting and further analysis.

Usage:
    Run this script after the Gold layer has been created and populated.
==============================================================================
*/

-- Duplicate checks in the Gold view.
-- Verify that Silver-to-Gold transformations did not introduce duplicate records.
-- Expected result: No duplicates found.
SELECT
    station,
    observation_date,
    metric
FROM gold.weather_observations
GROUP BY
    station,
    observation_date,
    metric
HAVING COUNT(*) > 1;



-- Missing values check in the Gold view.
-- NULL values in station, station_name, observation_date, metric, and value
-- should be investigated.
-- NULL values in elevation may be expected because NOAA missing elevation
-- values (-999.9) are converted to NULL while loading the Silver layer.
SELECT
    COUNT(*) FILTER (WHERE station IS NULL) AS station_nulls,
    COUNT(*) FILTER (WHERE station_name IS NULL) AS station_name_nulls,
    COUNT(*) FILTER (WHERE elevation IS NULL) AS elevation_nulls,
    COUNT(*) FILTER (WHERE observation_date IS NULL) AS observation_date_nulls,
    COUNT(*) FILTER (WHERE metric IS NULL) AS metric_nulls,
    COUNT(*) FILTER (WHERE value IS NULL) AS value_nulls
FROM gold.weather_observations;



-- Date range check.
-- Verify that the Silver-to-Gold transformation preserved the expected date range.
-- Expected result:
-- Minimum date: no earlier than 2015-01-01
-- Maximum date: no later than 2026-07-16
-- The maximum expected date will change with future NOAA updates.
SELECT
    (SELECT MIN(observation_date) FROM silver.weather) AS silver_min_observation_date,
    (SELECT MAX(observation_date) FROM silver.weather) AS silver_max_observation_date,
    (SELECT MIN(observation_date) FROM gold.weather_observations) AS gold_min_observation_date,
    (SELECT MAX(observation_date) FROM gold.weather_observations) AS gold_max_observation_date;
