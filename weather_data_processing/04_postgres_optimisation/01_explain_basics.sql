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
