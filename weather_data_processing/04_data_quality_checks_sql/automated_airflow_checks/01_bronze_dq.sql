/**
==============================================================================
Automated Data Quality Checks: Bronze Layer
==============================================================================
Purpose:
    Validate key Bronze layer fields used by the Airflow pipeline.

Checks:
    - NULL values in key columns
    - Duplicate natural keys

Usage:
    Executed automatically by Airflow after loading the Bronze layer.
==============================================================================
*/

-- Check for NULL station values in bronze.weather
DO $$
BEGIN
    IF EXISTS (
        SELECT station
        FROM bronze.weather
        WHERE station IS NULL
    ) THEN
        RAISE EXCEPTION 'DQ failed: NULL station values found in bronze.weather';
    END IF;
END $$;



-- Check for NULL observation_date values in bronze.weather
DO $$
BEGIN
    IF EXISTS (
        SELECT observation_date
        FROM bronze.weather
        WHERE observation_date IS NULL
    ) THEN
        RAISE EXCEPTION 'DQ failed: NULL observation_date values found in bronze.weather';
    END IF;
END $$;



-- Check for NULL metric values in bronze.weather
DO $$
BEGIN
    IF EXISTS (
        SELECT metric
        FROM bronze.weather
        WHERE metric IS NULL
    ) THEN
        RAISE EXCEPTION 'DQ failed: NULL metric values found in bronze.weather';
    END IF;
END $$;



-- Check for NULL station values in bronze.stations
DO $$
BEGIN
    IF EXISTS (
        SELECT station
        FROM bronze.stations
        WHERE station IS NULL
    ) THEN
        RAISE EXCEPTION 'DQ failed: NULL station values found in bronze.stations';
    END IF;
END $$;




-- Check for duplicate natural keys in bronze.weather
DO $$
BEGIN
    IF EXISTS (
    SELECT
        station,
        observation_date,
        metric
    FROM bronze.weather
    GROUP BY
        station,
        observation_date,
        metric
    HAVING COUNT(*) > 1
    ) THEN
        RAISE EXCEPTION 'DQ failed: duplicate natural keys found in bronze.weather';
    END IF;
END $$;



-- Check for duplicate station identifiers in bronze.stations
DO $$
BEGIN
    IF EXISTS (
        SELECT station
        FROM bronze.stations
        GROUP BY station
        HAVING COUNT(*) > 1
    ) THEN
        RAISE EXCEPTION 'DQ failed: duplicate natural keys found in bronze.stations';
    END IF;
END $$;
