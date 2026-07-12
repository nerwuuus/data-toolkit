/*
============================================================================
DDL Script: Create Silver Tables
============================================================================
Script Purpose:
  This script creates tables in the 'silver' schema, dropping existing tables
  if they already exist.
Run this script to redefine the DDL structure of 'silver' Tables.
============================================================================
*/

DROP TABLE IF EXISTS weather_silver;
CREATE TABLE weather_silver (
    station VARCHAR(11),
    observation_date DATE,
    metric VARCHAR(4),
    value INTEGER,
    insert_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

DROP TABLE IF EXISTS stations_silver;
CREATE TABLE stations_silver (
    station VARCHAR(11),
    elevation NUMERIC(6,1),
    station_name VARCHAR(100),
    insert_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
