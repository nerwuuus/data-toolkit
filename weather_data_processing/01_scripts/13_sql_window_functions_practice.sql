/*
==============================================================================
SQL Practice Script: Window Functions
==============================================================================
Script Purpose:
    This script is intended for practicing SQL window functions on the weather
    dataset, like:
        - ROW_NUMBER(),
        - RANK() and DENSE_RANK(),
        - LAG() and LEAD(),
        - AVG() OVER(),
        - COUNT() OVER(),
        - running and rolling calculations,
        - partitioning by station, year, metric, or other dimensions.

Example Use Cases:
    - rank the warmest days by station,
    - compare daily temperature with the previous observation,
    - calculate average temperature per station without losing row-level detail,
    - calculate monthly or yearly rankings,
    - identify stations with the highest or lowest average temperatures.

Data Source:
    The exercises should use analysis-ready data from the Gold layer, especially:

        gold.poland_weather_observations

    or another validated analytical table/view created from the Silver layer.
==============================================================================
*/

SELECT
    station,
    observation_date,
    SUM(value) OVER (PARTITION BY station ORDER BY observation_date) total_prcp
FROM gold.poland_weather_observations
WHERE metric = 'PRCP'
ORDER BY total_prcp DESC








