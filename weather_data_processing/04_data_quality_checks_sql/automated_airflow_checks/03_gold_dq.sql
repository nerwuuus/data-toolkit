/**
==============================================================================
Automated Data Quality Checks: Gold Layer
==============================================================================
Purpose:
    Validate curated Gold layer data used for analytics and reporting.

Checks:
    - NULL values in key columns
    - Duplicate natural keys
    - Invalid or unexpected analytical values

Usage:
    Executed automatically by Airflow after the Silver layer has been loaded.
==============================================================================
*/

-- Check for duplicate natural keys in Gold view
DO $$
BEGIN
    IF EXISTS (
    SELECT
        station,
        observation_date,
        metric
    FROM gold.poland_weather_observations
    GROUP BY
        station,
        observation_date,
        metric
    HAVING COUNT(*) > 1
    ) THEN
        RAISE EXCEPTION 'DQ failed: duplicate natural keys found in gold.poland_weather_observations';
    END IF;
END $$;
