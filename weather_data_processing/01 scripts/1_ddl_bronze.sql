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
    station VARCHAR(255),
    date DATE,
    metric VARCHAR(255),
    value INTEGER,
    measurement_flag VARCHAR(255),
    quality_flag VARCHAR(255),
    source_flag VARCHAR(255),
    observation_time TIMESTAMP
);
