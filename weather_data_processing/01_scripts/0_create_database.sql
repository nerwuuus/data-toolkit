/*
============================================================================
Create Database
============================================================================
Script Purpose:
  This script creates a PostgreSQL database for the weather data pipeline

WARNING:
  Running DROP DATABASE permanently deletes the database and all objects
  stored inside it. Run this script only when connected to another database,
  such as postgres.
============================================================================
*/

-- Drop and recreate the project database
DROP DATABASE IF EXISTS analytics_db;
CREATE DATABASE analytics_db;
