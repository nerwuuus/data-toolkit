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

-- Baseline:
-- Filtering one year still uses a Parallel Seq Scan and takes a long time.

-- Test an index on observation_date to improve date filtering.
CREATE INDEX idx_weather_observation_date
ON bronze.weather (observation_date);

-- Check whether PostgreSQL uses the new index.
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









