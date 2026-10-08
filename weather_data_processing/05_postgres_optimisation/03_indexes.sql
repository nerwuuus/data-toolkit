/*
==============================================================================
Index Tests
==============================================================================

Purpose:
    This script contains tests of PostgreSQL indexes used to improve query
    performance on the weather dataset.

    The goal is to compare query plans and execution times before and after
    creating indexes.

    Index tests may include:
        - Single-column indexes
        - Multi-column indexes
        - Different column orders
        - Index usage for filtering
        - Index usage for joins
        - Index usage for duplicate checks

    Each test should include:
        - The original query
        - The index definition
        - EXPLAIN or EXPLAIN ANALYZE output
        - Execution time before and after the index
        - Short notes describing whether the index improved performance

==============================================================================
*/

-- Baseline
-- Filtering one year uses a Parallel Seq Scan and takes a long time.

-- Create an index on observation_date.
-- Index creation time: ~7 minutes.
CREATE INDEX IF NOT EXISTS idx_weather_observation_date
ON bronze.weather (observation_date);

-- Test 1: One-year filter
-- Result:
-- PostgreSQL still uses a Parallel Seq Scan.
-- The index is not selected because the date range is too broad.
EXPLAIN
SELECT
    station,
    observation_date,
    metric,
    COUNT(*) AS duplicates
FROM bronze.weather
WHERE
    observation_date >= '2015-01-01'
    AND observation_date < '2016-01-01'
GROUP BY
    station,
    observation_date,
    metric
HAVING COUNT(*) > 1;

-- Test 2: One-month filter
-- Result:
-- PostgreSQL uses the observation_date index.
-- The index becomes useful when the filter is selective enough.
EXPLAIN
SELECT
    station,
    observation_date,
    metric,
    COUNT(*) AS duplicates
FROM bronze.weather
WHERE
    observation_date >= '2015-01-01'
    AND observation_date < '2015-02-01'
GROUP BY
    station,
    observation_date,
    metric
HAVING COUNT(*) > 1;



-- Create an index on station to test filtering by station prefix.
CREATE INDEX IF NOT EXISTS idx_weather_observation_station
ON silver.weather (station);

-- Check whether PostgreSQL uses the index for the Gold view query.
EXPLAIN
SELECT *
FROM gold.weather_observations;
-- Result:
-- PostgreSQL still uses a Parallel Seq Scan on silver.weather.
-- The station index is not selected for the LIKE 'PL%' filter.
-- The planner estimates that scanning the table is cheaper than using
-- the index for this relatively broad prefix filter.
