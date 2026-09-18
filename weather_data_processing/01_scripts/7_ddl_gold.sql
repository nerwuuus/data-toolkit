/* 
============================================================================== 
DDL Script: Create Gold View
============================================================================== 
Script Purpose: 
    This script creates view for the Gold layer of the weather data pipeline.

    The Gold layer provides analysis-ready datasets built from the Silver layer.
    In this project, the main Gold object is a view with weather observations
    enriched with station metadata.

    The view is filtered to include only Polish weather stations
    (station IDs starting with 'PL'), because the analytical part of this
    project focuses on weather data from Poland.

    This view does not physically store data. This keeps the Gold layer flexible:
    when Silver data is refreshed, the view automatically reflects the latest
    available data.

    The view can be queried directly from SQL, Python, Pandas, Polars,
    Power BI, or other analytics and visualization tools.
============================================================================== 
*/

DROP VIEW IF EXISTS gold.poland_weather_observations; 

CREATE VIEW gold.poland_weather_observations AS
    SELECT
        w.station,
        s.station_name,
        s.elevation,
        w.observation_date,
        -- TO_CHAR(w.observation_date, 'MM-YYYY') AS month_year,
        w.metric,
        w.value
    FROM silver.weather AS w
    LEFT JOIN silver.stations AS s
        ON w.station = s.station
    WHERE w.station LIKE 'PL%';

-- -- Data quality check:
-- -- Verify that all weather stations have matching station metadata.
-- SELECT COUNT(*)
-- FROM gold.weather_observations
-- WHERE station_name IS NULL;
