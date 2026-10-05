/*
==============================================================================
Query Optimisation Tests
==============================================================================

Purpose:

    This script contains experiments aimed at improving the performance of
    expensive PostgreSQL queries identified during query plan analysis.

    Each test should change one thing at a time and compare:
        - The query plan
        - Estimated cost
        - Execution time
        - The amount of data processed.

    The current baseline is the duplicate check on bronze.weather,
    which takes around 45 minutes on the full raw dataset.

    Index experiments are kept in a separate script.

==============================================================================
*/

-- Duplicate check on the full bronze.weather table
-- Baseline: 2 workers planned
-- Runtime: ~45 minutes

-- Inspect worker settings
SHOW max_parallel_workers_per_gather; -- 2
SHOW max_parallel_workers; -- 8
SHOW max_worker_processes; -- 8

-- Test increased workers from 2 to 4
SET max_parallel_workers_per_gather = 4;

EXPLAIN
SELECT
    station,
    observation_date,
    metric,
    COUNT(*) AS duplicate_count
FROM bronze.weather
GROUP BY
    station,
    observation_date,
    metric
HAVING COUNT(*) > 1;
-- Result:
-- Workers Planned: 4
-- Runtime: ~43 minutes
-- Increasing parallel workers from 2 to 4 provided only a small performance improvement.
-- Parallelism is not the main bottleneck for this query.

-- Filtering the dataset to a single year still takes a long time to complete.
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
HAVING COUNT(*) > 1
ORDER BY duplicates DESC;















