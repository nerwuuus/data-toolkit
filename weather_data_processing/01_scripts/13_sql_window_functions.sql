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

-- Identify the top 3 weather stations with the highest annual precipitation
-- for each year using a CTE and the RANK() window function.
WITH annual_prcp_ranking AS (
    SELECT
        station_name,
        EXTRACT(YEAR FROM observation_date) AS year,
        SUM(value) total_prcp,
        RANK() OVER(
            PARTITION BY EXTRACT(YEAR FROM observation_date) 
            ORDER BY SUM(value) DESC
            ) rank_stations
    FROM gold.poland_weather_observations
    WHERE metric = 'PRCP'
    GROUP BY
        station_name,
        EXTRACT(YEAR FROM observation_date)
    ORDER BY
        year DESC,
        rank_stations
)
SELECT *
FROM annual_prcp
WHERE rank_stations <=3;



-- Identify the top 3 weather stations with the highest cumulative snow depth
-- for each year using a CTE and the RANK() window function.
WITH annual_snwd_ranking AS (
    SELECT
        station_name,
        EXTRACT(YEAR FROM observation_date) AS year,
        SUM(value) total_snwd,
        RANK() OVER(
            PARTITION BY EXTRACT(YEAR FROM observation_date) 
            ORDER BY SUM(value) DESC
            ) rank_stations
    FROM gold.poland_weather_observations
    WHERE metric = 'SNWD'
    GROUP BY
        station_name,
        EXTRACT(YEAR FROM observation_date)
    ORDER BY
        year DESC,
        rank_stations
)
SELECT *
FROM annual_snwd_ranking
WHERE rank_stations <=3;



-- TODO: Rank weather stations by the number of days with snow cover (SNWD > 0)
-- for each year using a CTE and the RANK() window function.
-- Return the top 3 stations for each year.
SELECT
    station, 
    station_name,
    RANK() OVER(
        PARTITION BY EXTRACT(YEAR FROM observation_date)
        ORDER BY COUNT(observation_date) DESC
    )
FROM gold.poland_weather_observations
WHERE 
    metric = 'SNWD'
    AND value > 0
GROUP BY
    station,
    station_name,
    EXTRACT(YEAR FROM observation_date)











