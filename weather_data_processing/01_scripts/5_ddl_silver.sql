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

DROP TABLE IF EXISTS silver.weather CASCADE;
CREATE TABLE silver.weather (
    station VARCHAR(11),
    observation_date DATE,
    metric VARCHAR(4),
    value NUMERIC(5,1),
    insert_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

DROP TABLE IF EXISTS silver.stations CASCADE;
CREATE TABLE silver.stations (
    station VARCHAR(11),
    elevation NUMERIC(6,1),
    station_name VARCHAR(100),
    insert_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
