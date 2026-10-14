## Current Airflow Pipeline

The current DAG orchestrates the following workflow:

`load_staging -> load_bronze -> bronze_dq -> load_silver -> [silver_dq, gold_dq]`

- `load_staging`
  - uses `BashOperator`
  - runs `/app/01_scripts/4a_load_staging.py`
  - loads the current source batch into Staging
- `load_bronze`
  - uses `SQLExecuteQueryOperator`
  - executes the PostgreSQL script `01_bronze_dq.sql`
- `bronze_dq`
  - uses `SQLExecuteQueryOperator`
  - executes the PostgreSQL `load_bronze()` procedure
- `load_silver`
  - uses `SQLExecuteQueryOperator`
  - executes the PostgreSQL `load_silver()` procedure
- Silver, and Gold DQ checks run automatically after the load and use `SQLExecuteQueryOperator`
- Gold is implemented as a normal VIEW, so it does not require a separate load task

[Weather Data Pipeline](docs/weather_data_pipeline-graph.png)

## Staging/TRUNCATE

`4a_load_staging.py` currently truncates:

- `staging.stations`
- `staging.weather`

This is intentional if Staging represents only the current incoming batch.

The incremental logic is handled when data moves from Staging to Bronze, rather than by preserving historical data in Staging.