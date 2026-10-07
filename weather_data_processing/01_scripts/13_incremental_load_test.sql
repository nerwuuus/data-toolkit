/*
==============================================================================
Staging-to-Bronze Incremental Load Tests
==============================================================================
Script Purpose:
    This script is used to test different approaches for incremental loading
    between the Staging and Bronze layers.

    The test tables are intentionally small and isolated from the main pipeline
    so that loading logic can be developed and verified safely.

    This script may contain experiments with:
        - NOT EXISTS
        - LEFT JOIN ... IS NULL
        - UNIQUE constraints
        - ON CONFLICT DO NOTHING
        - Watermark-based loading
        - Duplicate prevention
        - Re-running the same load safely

Usage:
    Use this script as a sandbox for testing incremental loading logic before
    applying it to the main weather pipeline.
==============================================================================
*/

DROP TABLE IF EXISTS bronze.weather_test;
CREATE TABLE bronze.weather_test (
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

DROP TABLE IF EXISTS staging.weather_test;
CREATE TABLE staging.weather_test (
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


-- SELECT topic_id, topic_date, topic_body
-- FROM ${TARGET_SCHEMA_IMPORT}.tmp_topic src
-- WHERE NOT EXISTS (
--         SELECT *
--         FROM ${TARGET_SCHEMA_FINAL}.topic nx
--         WHERE nx.topic_id = src.topic_id
--         );

