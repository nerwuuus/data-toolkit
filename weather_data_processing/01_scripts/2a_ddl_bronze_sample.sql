/*
=================================================================================
DDL Bronze Sample Script: Create Sample Raw Data Tables
=================================================================================
Script Purpose:
  This script creates sample Bronze tables used for testing the Docker Compose
  PostgreSQL pipeline with smaller datasets.

  It drops existing sample tables if they already exist and recreates them
  with the same structure as the main Bronze tables.

  These tables are intended for sample data only, not for the full NOAA dataset.
=================================================================================
*/

DROP TABLE IF EXISTS bronze.weather_sample;
CREATE TABLE bronze.weather_sample (
    station VARCHAR(11),
    observation_date DATE,
    metric VARCHAR(4),
    value INTEGER,
    measurement_flag CHAR(1),
    quality_flag CHAR(1),
    source_flag CHAR(1),
    observation_time VARCHAR(4)
);

DROP TABLE IF EXISTS bronze.stations_sample;
CREATE TABLE bronze.stations_sample (
    station VARCHAR(11),
    latitude NUMERIC(8,4),
    longitude NUMERIC(9,4),
    elevation NUMERIC(6,1),
    state VARCHAR(50),
    station_name VARCHAR(100),
    gsn_flag VARCHAR(3),
    hcn_flag VARCHAR(3),
    wmo_id NUMERIC(6,1)
);
