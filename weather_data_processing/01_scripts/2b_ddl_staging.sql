/*
============================================================================
DDL Staging Script: Create Temporary Raw Data Tables
============================================================================
Script Purpose:
    This script creates staging tables used to temporarily store incoming
    source data before it is loaded into the Bronze layer.

    The staging tables are intended to hold only the current incoming batch
    of raw weather and station data.

    Run this script to redefine the Staging DDL structure.
============================================================================
*/

DROP TABLE IF EXISTS staging.weather;
CREATE TABLE staging.weather (
    station VARCHAR(11),
    observation_date DATE,
    metric VARCHAR(4),
    value INTEGER,
    measurement_flag CHAR(1),
    quality_flag CHAR(1),
    source_flag CHAR(1),
    observation_time VARCHAR(10),
    insert_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

DROP TABLE IF EXISTS staging.stations;
CREATE TABLE staging.stations (
    station VARCHAR(11),
    latitude NUMERIC(8,4),
    longitude NUMERIC(9,4),
    elevation NUMERIC(6,1),
    state VARCHAR(50),
    station_name VARCHAR(100),
    gsn_flag VARCHAR(3),
    hcn_flag VARCHAR(3),
    wmo_id NUMERIC(6,1),
    insert_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
