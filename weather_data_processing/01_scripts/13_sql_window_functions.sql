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
-- for each year.
WITH annual_prcp_ranking AS (
    SELECT
        station_name,
        EXTRACT(YEAR FROM observation_date) AS year,
        SUM(value) total_prcp,
        RANK() OVER(
            PARTITION BY EXTRACT(YEAR FROM observation_date) 
            ORDER BY SUM(value) DESC
            ) AS rank_stations
    FROM gold.poland_weather_observations
    WHERE metric = 'PRCP'
    GROUP BY
        station_name,
        EXTRACT(YEAR FROM observation_date)
)
SELECT *
FROM annual_prcp_ranking
WHERE rank_stations <=3
ORDER BY
    year DESC,
    rank_stations;



-- Identify the top 3 weather stations with the highest cumulative snow depth
-- for each year.
WITH annual_snwd_ranking AS (
    SELECT
        station_name,
        EXTRACT(YEAR FROM observation_date) AS year,
        SUM(value) total_snwd,
        RANK() OVER(
            PARTITION BY EXTRACT(YEAR FROM observation_date) 
            ORDER BY SUM(value) DESC
            ) AS rank_stations
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
WHERE rank_stations <=3
ORDER BY
    year DESC,
    rank_stations;



-- Identify the top 3 weather stations with the highest number of days
-- with snow cover (SNWD > 0) for each year.
WITH annual_snow_cover_ranking AS (
    SELECT
        station_name,
        COUNT(observation_date) AS days_with_snow_cover,
        EXTRACT(YEAR FROM observation_date) AS year,
        RANK() OVER(
            PARTITION BY EXTRACT(YEAR FROM observation_date)
            ORDER BY COUNT(observation_date) DESC
        ) AS rank_stations
    FROM gold.poland_weather_observations
    WHERE 
        metric = 'SNWD'
        AND value > 0
    GROUP BY
        station_name,
        EXTRACT(YEAR FROM observation_date)
)
SELECT *
FROM annual_snow_cover_ranking
WHERE rank_stations <=3
ORDER BY
    year DESC,
    rank_stations;



-- Calculate a 7-observation moving average of daily maximum temperature (TMAX)
-- for each weather station using AVG() and ROWS BETWEEN to smooth short-term
-- temperature fluctuations while preserving daily observations.
SELECT
    station_name,
    value,
    observation_date,
    ROUND(
        AVG(value) OVER(
            PARTITION BY station_name
            ORDER BY observation_date
            ROWS BETWEEN 6 PRECEDING AND CURRENT ROW 
        ), 2
    ) AS moving_average
FROM gold.poland_weather_observations
WHERE metric = 'TMAX';



-- Compare daily maximum temperature (TMAX) with the previous and next
-- available observations for each weather station using LAG() and LEAD(),
-- while preserving the chronological order of temperature measurements.
SELECT
    station_name,
    observation_date,
    value AS current_temp,
    LAG(value, 1) OVER(
        PARTITION BY station_name
        ORDER BY observation_date
    ) AS previous_temp,
    LEAD(value, 1) OVER(
        PARTITION BY station_name
        ORDER BY observation_date
    ) AS next_temp
FROM gold.poland_weather_observations
WHERE metric = 'TMAX'
ORDER BY 
    station_name DESC,
    observation_date;



-- Find the 3 warmest days for each station in 2025
WITH top3_warmest_2025 AS (
    SELECT
        station_name,
        observation_date,
        value,
        ROW_NUMBER() OVER(
            PARTITION BY station_name
            ORDER BY value DESC, observation_date ASC
        ) AS rank_stations
    FROM gold.poland_weather_observations
    WHERE 
        metric = 'TMAX'
        AND EXTRACT(YEAR FROM observation_date) = 2025
)
SELECT *
FROM top3_warmest_2025
WHERE rank_stations <= 3;



-- TODO 5: Rank the warmest days for each station using DENSE_RANK()
-- and compare the results with RANK() when temperatures are equal.





-- TODO 6: Count available temperature observations for each station
-- in 2025 using COUNT() OVER(), while preserving daily records.
SELECT
    station_name,
    observation_date,
    COUNT(*) OVER(
        PARTITION BY station_name
    )
FROM gold.poland_weather_observations
WHERE 
    metric IN (
        'TMAX', 'TMIN', 'TAVG'
    )
    AND EXTRACT(YEAR FROM observation_date) = '2025'
ORDER BY 
    station_name,
    observation_date;


-- TODO 7: Calculate cumulative precipitation (PRCP) for each station
-- throughout 2025 using SUM() and UNBOUNDED PRECEDING.










