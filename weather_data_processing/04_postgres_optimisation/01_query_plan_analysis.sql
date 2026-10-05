/*
==============================================================================
Query Plan Analysis
==============================================================================

Purpose:
    This script contains PostgreSQL EXPLAIN or EXPLAIN ANALYZE queries used to 
    inspect how expensive SQL operations are executed.

    The goal is to identify costly parts of query plans, such as:
        - Sequential scans
        - Sorting
        - Aggregation
        - Parallel processing
        - Joins.

    Each query should include short notes describing the most important parts
    of the execution plan and, when available, the observed execution time.

    These results provide a baseline for later optimisation tests.

==============================================================================
*/

-- Duplicate check on the full bronze.weather table
-- Query plan:
-- - PostgreSQL reads the full bronze.weather table using a Parallel Seq Scan.
-- - The data is sorted by station, observation_date, and metric.
-- - 2 workers process parts of the aggregation in parallel.
-- - PostgreSQL applies HAVING COUNT(*) > 1.
-- - The query is very expensive because it scans, sorts, and groups the full raw dataset.
-- - This query takes around 45 minutes to complete.
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











