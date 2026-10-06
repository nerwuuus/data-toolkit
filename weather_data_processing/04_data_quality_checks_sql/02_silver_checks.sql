/*
==============================================================================
Data Quality Checks: Silver Layer
==============================================================================
Script Purpose:
    This script contains data quality checks for the Silver layer of the
    weather data pipeline.
    The checks are intended to validate cleaned and standardised weather and
    station data and confirm that the transformation process produced
    consistent and usable datasets.

    The script should be used to check:
        - Row counts in Silver tables
        - Missing values in important columns
        - Duplicate weather observations
        - Expected observation date ranges
        - Valid weather metrics and value ranges
        - Consistency of cleaned station metadata
        - Data completeness after Bronze-to-Silver transformations

Silver Layer:
    Cleaned and standardised weather observations and station metadata prepared
    for further joins and analytical processing.

Usage:
    Run this script after the Silver layer has been created and populated.
==============================================================================
*/

-- Check row counts in Silver tables
-- Expected result: counts should match the corresponding Bronze tables after transformation.
SELECT COUNT(*)
FROM silver.weather;

SELECT COUNT(*)
FROM silver.stations;



-- Missing values in key Silver layer columns.
-- Verify that Bronze-to-Silver transformations did not introduce unexpected NULL values.
-- Expected result: 0 NULL values in key columns.
SELECT
    COUNT(*) FILTER (WHERE station IS NULL) AS station_nulls,
    COUNT(*) FILTER (WHERE observation_date IS NULL) AS observation_date_nulls,
    COUNT(*) FILTER (WHERE metric IS NULL) AS metric_nulls,
    COUNT(*) FILTER (WHERE value IS NULL) AS value_nulls
FROM silver.weather;

SELECT
    COUNT(*) FILTER (WHERE station IS NULL) AS station_nulls,
    COUNT(*) FILTER (WHERE station_name IS NULL) AS station_name_nulls,
    COUNT(*) FILTER (WHERE elevation IS NULL) AS elevation_nulls
FROM silver.stations;



-- Duplicate checks in the Silver layer.
-- Verify that Bronze-to-Silver transformations did not introduce duplicate records.
-- Expected result: No duplicates found.
SELECT
    station,
    observation_date,
    metric
FROM silver.weather
GROUP BY
    station,
    observation_date,
    metric
HAVING COUNT(*) > 1;

-- Duplicate checks on station identifiers and station names.
-- Expected result: No duplicates found.
SELECT station
FROM silver.stations
GROUP BY station
HAVING COUNT(*) > 1;

SELECT station_name
FROM silver.stations
GROUP BY station_name
HAVING COUNT(*) > 1;



-- Date range check
-- Verify that the Bronze-to-Silver transformation preserved the expected date range.
-- Expected result:
-- Minimum date: no earlier than 2015-01-01
-- Maximum date: no later than 2026-07-16
-- The maximum expected date will change with future NOAA updates.
SELECT
    MIN(observation_date) AS min_observation_date,
    MAX(observation_date) AS max_observation_date
FROM silver.weather;



-- Metric distribution and value range check
-- Verify that the Bronze-to-Silver transformation preserved expected metrics
-- and did not introduce unexpected value changes.
SELECT
    metric,
    COUNT(*) AS metric_count,
    MIN(value) AS min_metric_value,
    MAX(value) AS max_metric_value,
    (MAX(value) - MIN(value)) AS metric_delta
FROM silver.weather
GROUP BY metric
ORDER BY 
    metric_count DESC,
    metric;



-- - Consistency of cleaned station metadata
        -- Czyli możesz sprawdzić, czy:
        -- - station nie ma pustych stringów,
        -- - station_name nie ma pustych stringów,
        -- - nazwy nie mają dziwnych spacji na początku/końcu,
        -- - elevation nie ma absurdalnych wartości albo nieoczekiwanych NULL-i.

-- Data completeness after Bronze-to-Silver transformations
    -- → sprawdzasz, czy podczas transformacji nie zgubiłeś danych.
        -- Najprościej:
        -- - row count Bronze vs Silver,
        -- - zakres dat Bronze vs Silver,
        -- - liczba stacji Bronze vs Silver,
        -- - lista metryk Bronze vs Silver.
