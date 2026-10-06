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

-- Baseline
-- Duplicate check on the key observation columns in bronze.weather table.
-- Workers Planned: 2
-- Runtime: ~45 minutes

-- Inspect worker settings
SHOW max_parallel_workers_per_gather; -- 2
SHOW max_parallel_workers; -- 8
SHOW max_worker_processes; -- 8

-- Test 1: Increase max_parallel_workers_per_gather from 2 to 4
-- Result:
-- Workers Planned: 4
-- Runtime: ~43 minutes
-- Increasing parallel workers from 2 to 4 provided only a small performance improvement.
-- Parallelism is not the main bottleneck for this query.
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



-- Test 2: Filter the duplicate check to a single year
-- Result:
-- Filtering the dataset to a single year still takes a long time to complete.
-- PostgreSQL still uses a Parallel Seq Scan.
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



-- Test 3: Inspect memory available for sort and aggregation operations
SHOW work_mem; -- Result: 4MB

-- Test increased work_mem from 4MB to 64MB
SET work_mem = '64MB';

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
-- Result:
-- With work_mem = 4MB, PostgreSQL uses a Parallel Seq Scan.
-- With work_mem = 64MB, PostgreSQL switches to a Parallel Bitmap Heap Scan
-- and uses the observation_date index.
-- Increasing work_mem changed the estimated cost enough for the planner
-- to choose a different execution plan.









