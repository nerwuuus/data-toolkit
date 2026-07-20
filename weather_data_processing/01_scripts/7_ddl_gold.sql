/*
==============================================================================
DDL Script: Create Gold Views
==============================================================================
Script Purpose:
    This script creates views for the Gold layer of the weather data pipeline.

    The Gold layer contains analytics-ready datasets built from the Silver
    layer. These views combine weather observations with station metadata
    to provide clean and enriched data for reporting, visualization,
    and further analysis.

Usage:
    Query these views directly from Python, Polars, Pandas, Power BI,
    or other analytics tools.
==============================================================================
*/

DROP VIEW IF EXISTS gold.weather_observations CASCADE; 

CREATE VIEW gold.weather_observations AS
    SELECT
        w.station,
        s.station_name,
        s.elevation,
        w.observation_date,
        TO_CHAR(w.observation_date, 'MM-YYYY') AS month_year,
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

