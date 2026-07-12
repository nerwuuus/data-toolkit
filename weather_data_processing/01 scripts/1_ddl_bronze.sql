/*
============================================================================
DDL Bronze Script: Create Raw Data Table
============================================================================
Script Purpose:
  This script creates table dropping existing table
  if it already exists.
Run this script to redefine the Bronze DDL structure.
============================================================================
*/

DROP TABLE IF EXISTS weather_bronze;
CREATE TABLE weather_bronze (
    station VARCHAR(11),
    observation_date DATE,
    metric VARCHAR(4),
    value INTEGER,
    measurement_flag CHAR(1),
    quality_flag CHAR(1),
    source_flag CHAR(1),
    observation_time VARCHAR(4)
);

DROP TABLE IF EXISTS stations_bronze;
CREATE TABLE stations_bronze (
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
