# Placeholder for a future scheduled NOAA 2026/2027 update pipeline.
# Current-year data is incomplete and should stay outside the main 2015–2025 analysis dataset.
# The goal is to download NOAA 2026/2027 data on a regular schedule and load it into a separate test table.

# Key questions to revisit later:
# - Should the pipeline run weekly or monthly?
# - Should the 2026 table be fully replaced on each run or loaded incrementally?
# - What should be the unique key for deduplication? Probably: station + observation_date + metric.
# - How should already existing records be handled?
# - Should raw downloaded files be versioned/snapshotted or overwritten?
# - Should the pipeline keep only Polish stations and selected metrics before loading?
# - Should data quality checks be run before inserting data into the test table?
# - Should failed downloads or partial NOAA files stop the pipeline?
# - Should this be implemented as a standalone script first or directly as an Airflow DAG?
# - How should this test table eventually relate to the main bronze/silver/gold pipeline?

# Planned for a later stage, most likely after introducing Airflow orchestration.
