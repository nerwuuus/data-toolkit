CREATE OR REPLACE PROCEDURE test()
LANGUAGE plpgsql
AS $$
BEGIN
    -- Weather data
    INSERT INTO bronze.weather_test (
        station,
        observation_date,
        metric,
        value,
        measurement_flag,
        quality_flag,
        source_flag,
        observation_time
    )
    SELECT
        station,
        observation_date,
        metric,
        value,
        measurement_flag,
        quality_flag,
        source_flag,
        observation_time
    FROM staging.weather_test sw
    WHERE NOT EXISTS (
        SELECT 1
        FROM bronze.weather_test bw
        WHERE
            sw.station = bw.station
            AND sw.observation_date = bw.observation_date
            AND sw.metric = bw.metric
    )
    ON CONFLICT (station, observation_date, metric) DO NOTHING;

    -- Stations data
    INSERT INTO bronze.stations_test (
        station,
        latitude,
        longitude,
        elevation,
        state,
        station_name,
        gsn_flag,
        hcn_flag,
        wmo_id
    )
    SELECT
        station,
        latitude,
        longitude,
        elevation,
        state,
        station_name,
        gsn_flag,
        hcn_flag,
        wmo_id
    FROM staging.stations_test ss
    WHERE NOT EXISTS (
        SELECT 1
        FROM bronze.stations_test bs
        WHERE ss.station = bs.station
    )
    ON CONFLICT (station) DO NOTHING;

    -- Verify that all staging weather rows exist in bronze.weather_test.
    IF EXISTS (
        SELECT 1
        FROM staging.weather_test sw
        WHERE NOT EXISTS (
            SELECT 1
            FROM bronze.weather_test bw
            WHERE
                sw.station = bw.station
                AND sw.observation_date = bw.observation_date
                AND sw.metric = bw.metric
        )
    ) THEN
        RAISE EXCEPTION 'Missing weather rows in bronze_weather.';
    END IF;

    -- Verify that all staging station rows exist in bronze.stations_test.
    IF EXISTS (
        SELECT 1
        FROM staging.stations_test ss
        WHERE NOT EXISTS (
            SELECT 1
            FROM bronze.stations_test bs
            WHERE ss.station = bs.station
        )
    ) THEN
        RAISE EXCEPTION 'Missing station rows in bronze_stations.';
    END IF;

    -- Truncate staging tables only after successful validation.
    TRUNCATE TABLE staging.weather_test;
    TRUNCATE TABLE staging.stations_test;

    -- Final message
    RAISE NOTICE 'Bronze test tables have been successfully updated.';
END;
$$;

CALL test();
