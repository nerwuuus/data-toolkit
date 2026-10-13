/**
==============================================================================
Automated Data Quality Checks: Silver Layer
==============================================================================
Purpose:
    Validate key Silver layer fields and transformed data used by the Airflow 
    pipeline.

Checks:
    - NULL values in key columns
    - Duplicate natural keys (station + observation_date + metric for weather; 
    station for stations)
    - Invalid transformed values

Usage:
    Executed automatically by Airflow after loading the Silver layer.
==============================================================================
*/

-- Check for NULL station values in silver.weather
DO $$
BEGIN
    IF EXISTS (
        SELECT station
        FROM silver.weather
        WHERE station IS NULL
    ) THEN
        RAISE EXCEPTION 'DQ failed: NULL station values found in silver.weather';
    END IF;
END $$;



-- Check for NULL observation_date values in silver.weather
DO $$
BEGIN
    IF EXISTS (
        SELECT observation_date
        FROM silver.weather
        WHERE observation_date IS NULL
    ) THEN
        RAISE EXCEPTION 'DQ failed: NULL observation_date values found in silver.weather';
    END IF;
END $$;



-- Check for NULL metric values in silver.weather
DO $$
BEGIN
    IF EXISTS (
        SELECT metric
        FROM silver.weather
        WHERE metric IS NULL
    ) THEN
        RAISE EXCEPTION 'DQ failed: NULL metric values found in silver.weather';
    END IF;
END $$;



-- Check for NULL station values in silver.stations
DO $$
BEGIN
    IF EXISTS (
        SELECT station
        FROM silver.stations
        WHERE station IS NULL
    ) THEN
        RAISE EXCEPTION 'DQ failed: NULL station values found in silver.stations';
    END IF;
END $$;



-- Check for sentinel values in the value column of silver.weather
DO $$
BEGIN
    IF EXISTS (
        SELECT value
        FROM silver.weather
        WHERE value = -999.9
    ) THEN
        RAISE EXCEPTION 'DQ failed: sentinel value -999.9 found in silver.weather';
    END IF;
END $$;



-- Check for duplicate natural keys in silver.weather
DO $$
BEGIN
    IF EXISTS (
    SELECT
        station,
        observation_date,
        metric
    FROM silver.weather
    GROUP BY
        station,
        observation_date,
        metric
    HAVING COUNT(*) > 1
    ) THEN
        RAISE EXCEPTION 'DQ failed: duplicate natural keys found in silver.weather';
    END IF;
END $$;



-- Check for duplicate station identifiers in silver.stations
DO $$
BEGIN
    IF EXISTS (
        SELECT station
        FROM silver.stations
        GROUP BY station
        HAVING COUNT(*) > 1
    ) THEN
        RAISE EXCEPTION 'DQ failed: duplicate natural keys found in silver.stations';
    END IF;
END $$;



-- Check for duplicate natural keys in silver.weather
DO $$
BEGIN
    IF EXISTS (
    SELECT
        station,
        observation_date,
        metric
    FROM silver.weather
    GROUP BY
        station,
        observation_date,
        metric
    HAVING COUNT(*) > 1
    ) THEN
        RAISE EXCEPTION 'DQ failed: duplicate natural keys found in silver.weather';
    END IF;
END $$;



-- Check for leading or trailing whitespace in station values in silver.weather
DO $$
BEGIN
    IF EXISTS (
        SELECT btrim(station)
        FROM silver.weather
        WHERE btrim(station) != station
    ) THEN
        RAISE EXCEPTION 'DQ failed: leading or trailing whitespace found in station column of silver.weather';
    END IF;
END $$;
