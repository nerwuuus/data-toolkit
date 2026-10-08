/*
============================================================================
Stored Procedure: Load Bronze Layer (Staging -> Bronze)
============================================================================
Script Purpose:
  This stored procedure performs the load process to populate the 'bronze'
  schema tables from the 'staging' schema.

Actions Performed:
  - Reads incoming raw data from Staging tables.
  - Inserts new records into Bronze tables.
  - Preserves raw source values without analytical transformations.
  - Prevents already existing records from being loaded again.
============================================================================
*/

CREATE OR REPLACE PROCEDURE load_bronze()
LANGUAGE plpgsql
AS $$
BEGIN
  -- Weather data
  INSERT INTO bronze.weather (
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
  FROM staging.weather sw
  WHERE NOT EXISTS (
      SELECT *
      FROM bronze.weather bw
      WHERE
          sw.station = bw.station 
          AND sw.observation_date = bw.observation_date 
          AND sw.metric = bw.metric
  )
  ON CONFLICT (station, observation_date, metric) DO NOTHING;

  -- Stations data
  INSERT INTO bronze.stations (
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
  FROM staging.stations ss
  WHERE NOT EXISTS (
      SELECT *
      FROM bronze.stations bs
      WHERE ss.station = bs.station 
  )
  ON CONFLICT (station) DO NOTHING;  

    -- Final message
    RAISE NOTICE 'Bronze tables have been successfully updated.';
END;
$$;

CALL load_bronze();
