INSERT INTO silver.weather (
    station,
    observation_date,
    metric,
    value
)
SELECT
    TRIM(station) AS station,
    observation_date,
    metric,
    -- NOAA temperature observations are stored as integers representing
    -- tenths of a degree Celsius (e.g. 221 = 22.1°C).
    -- Divide by 10 to convert them to degrees Celsius.
    CASE
        WHEN metric IN ('TAVG', 'TMIN', 'TMAX') THEN value / 10.0
        ELSE value
    END AS value
FROM bronze.weather;

INSERT INTO silver.stations (
        station,
        elevation,
        station_name
    )
    SELECT
        TRIM(station) AS station,
        CASE
            WHEN elevation <= -999.9 THEN NULL
            ELSE elevation
        END AS elevation,
    -- Capitalize the first letter of each word
    TRIM(INITCAP(station_name)) AS station_name
    FROM bronze.stations;
