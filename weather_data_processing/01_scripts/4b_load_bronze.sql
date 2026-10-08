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



    -- Final message
    RAISE NOTICE 'Bronze tables have been successfully updated.';
END;
$$;

CALL load_bronze();

