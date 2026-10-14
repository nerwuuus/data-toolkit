# Weather Data Processing

## Initial Project Scope

The project originally started as a small ETL exercise focused on:

- Loading public NOAA weather data into PostgreSQL
- Processing the data with Pandas
- Creating simple weather variables
- Performing basic data quality checks
- Generating a few exploratory plots
- Exporting the processed data to CSV

The scope expanded over time as the project evolved into a broader Data Engineering learning environment, including large-scale Parquet processing, Polars Lazy, PySpark, SQL transformations, incremental loading, Docker, and Apache Airflow orchestration.

## Overview

Weather Data Processing is an end-to-end Data Engineering project built around the NOAA Global Historical Climatology Network Daily (GHCN-Daily) dataset.

The project demonstrates a complete data processing workflow, starting from raw weather observations, through staging and layered PostgreSQL processing, to automated orchestration and data quality validation.

The current architecture uses:

`Staging -> Bronze -> Silver -> Gold`

The primary goal of this project is to practice Data Engineering concepts rather than perform extensive exploratory data analysis.

---

## Dataset

- Source: NOAA Global Historical Climatology Network Daily (GHCN-Daily)
- Time period: 2015-2025, with newer 2026 observations used for incremental loading tests
- Number of observations: ~422 million
- Number of weather stations: worldwide
- Docker demo dataset: smaller weather sample used for reproducible local testing

The full NOAA dataset is used for local data preparation, benchmarking, and large-scale processing.

A smaller sample dataset is included to make the Dockerized pipeline easier to run and test.

---

## Project Objectives

- Process a large real-world dataset (~422 million observations)
- Compare CSV and Apache Parquet storage formats
- Compare Pandas and Polars performance
- Experiment with PySpark
- Build a Staging -> Bronze -> Silver -> Gold data pipeline
- Load and transform data in PostgreSQL
- Implement incremental loading
- Add automated data quality checks
- Orchestrate the pipeline with Apache Airflow
- Practice reproducible Data Engineering workflows with Docker
- Build a project that evolves beyond a simple ETL exercise

---

## Project Structure

```text
weather_data_processing/
├── 00_raw_data/                    # Raw data files, station metadata and sample dataset
├── 01_scripts/                     # Python, SQL, notebooks, benchmarks and ETL scripts
│   └── tests/                      # Tests for Python scripts and transformation logic
├── 02_plots/                       # Generated charts
├── 03_docker/                      # Dockerfile and Docker-related notes
├── 04_data_quality_checks_sql/      # Manual and automated SQL data quality checks
│   └── automated_airflow_checks/   # SQL DQ checks executed automatically by Airflow
├── 06_airflow/                     # Airflow DAGs, logs, plugins and configuration
├── docs/                           # Project documentation and pipeline diagrams
├── compose.yaml                    # Docker Compose configuration
├── requirements.txt                # Python dependencies
├── .env                            # Local Docker environment variables, not committed to Git
├── .env.example                    # Example Docker environment configuration
├── .env.analysis                   # Local analysis environment variables, not committed to Git
├── .dockerignore                   # Files excluded from Docker build context
└── README.md
```

---

## Technologies

- Python
- Pandas
- Polars
- PySpark
- PostgreSQL
- Apache Airflow
- Apache Parquet
- Jupyter Notebook
- Docker
- Git
- GitHub
- VS Code PostgreSQL extension
- ChatGPT

---

## Data Pipeline

```text
NOAA GHCN-Daily
        │
        ▼
Raw CSV files
        │
        ▼
Staging
        │
        ▼
Bronze
        │
        ▼
Silver
        │
        ▼
Gold VIEW
        │
        ▼
Data Quality Checks/Analysis
```

The pipeline is orchestrated with Apache Airflow.

Staging represents the current incoming batch, while Bronze and Silver preserve historical data using incremental loading logic.

Gold is implemented as a PostgreSQL VIEW and does not require a separate load step during each pipeline run.

---

## Bronze Layer

The Bronze layer stores source data with minimal structural normalization.

Current Bronze tables:

- `bronze.weather`
- `bronze.stations`

Raw NOAA values are preserved.

Before loading, positional NOAA source columns are renamed to semantic column names such as:

- `station`
- `observation_date`
- `metric`
- `value`
- `measurement_flag`
- `quality_flag`
- `source_flag`
- `observation_time`

This is a structural normalization step rather than a business transformation.

No business cleaning, value conversion, or analytical transformation is applied at this stage.

The semantic column names simplify PostgreSQL DDL, SQL processing, and later Silver transformations while preserving the original source values.

---

## Silver Layer

The Silver layer contains cleaned and transformed data.

Examples of transformations include:

- Trimming station identifiers
- Cleaning station names
- Converting NOAA temperature values to meaningful units
- Replacing invalid elevation sentinel values with `NULL`
- Preserving only valid structured records for downstream use

Incremental loading is used so that only records not already present in Silver are inserted.

---

## Gold Layer

The Gold layer is implemented as a PostgreSQL VIEW.

It combines prepared weather observations with station metadata and exposes data in a form suitable for downstream analysis.

Because Gold is a normal VIEW, it does not require a separate load task during each Airflow run.

---

## Incremental Loading

The pipeline uses natural keys to prevent duplicate inserts.

For weather observations, the natural key is:

```text
station + observation_date + metric
```

For stations, the natural key is:

```text
station
```

Incremental loading is implemented using PostgreSQL logic based on:

- `WHERE NOT EXISTS`
- `UNIQUE` constraints
- `ON CONFLICT DO NOTHING`

This makes repeated pipeline runs idempotent and prevents duplicate historical records from being inserted.

---

## Current Airflow Pipeline

Apache Airflow is configured and running locally through Docker Compose.

The current DAG orchestrates the following workflow:

```text
load_staging
      |
      v
load_bronze
      |
      v
bronze_dq
      |
      v
load_silver
      |
      +--> silver_dq
      |
      +--> gold_dq
```

Current tasks:

- `load_staging`
  - uses `BashOperator`
  - runs `/app/01_scripts/4a_load_staging.py`
  - loads the current source batch into Staging

- `load_bronze`
  - uses `SQLExecuteQueryOperator`
  - executes the PostgreSQL `load_bronze()` procedure

- `load_silver`
  - uses `SQLExecuteQueryOperator`
  - executes the PostgreSQL `load_silver()` procedure

- `bronze_dq`
  - runs automated Bronze data quality validation

- `silver_dq`
  - runs automated Silver data quality validation

- `gold_dq`
  - runs automated Gold data quality validation

Data quality SQL uses PostgreSQL exception logic so that failed validation causes the Airflow task to fail automatically.

[Weather Data Pipeline](docs/weather_data_pipeline-graph.png)

---

## Staging

Staging represents only the current incoming batch.

`4a_load_staging.py` truncates:

- `staging.stations`
- `staging.weather`

before loading the next batch.

This behavior is intentional.

Historical data is not preserved in Staging because its purpose is to hold only the current incoming source batch.

Incremental history is preserved in Bronze and Silver.

The expected flow is:

```text
Current source batch
        |
        v
Staging
        |
        v
Incremental Bronze load
        |
        v
Incremental Silver load
```

---

## Data Quality

The project contains automated Data Quality checks for:

- Bronze
- Silver
- Gold

Examples include validation of:

- NULL values
- duplicate natural keys
- valid date ranges
- valid metrics
- whitespace issues
- invalid elevation values
- expected record presence

The Airflow DQ tasks use SQL validation logic based on:

```sql
DO $$
BEGIN
    IF EXISTS (...) THEN
        RAISE EXCEPTION 'Data quality check failed.';
    END IF;
END $$;
```

If a validation condition is detected, PostgreSQL raises an exception and the corresponding Airflow task fails.

---

## Docker Workflow

The project includes a Docker Compose setup for running PostgreSQL, Python ETL scripts, and Apache Airflow locally.

The main components include:

- `db`
  - PostgreSQL database used by the weather pipeline

- `init-db`
  - optional setup service used to initialize or rebuild database objects

- `load-staging`
  - loads the incoming source batch into Staging

- `load-bronze`
  - executes the Bronze load

- `load-silver`
  - executes the Silver load

- `airflow-postgres`
  - separate PostgreSQL database used only for Airflow metadata

- `airflow-apiserver`
  - exposes the Airflow UI and API

- `airflow-scheduler`
  - schedules DAG runs and tasks

- `airflow-dag-processor`
  - processes DAG definitions

Airflow uses `LocalExecutor`.

The weather PostgreSQL database and Airflow metadata database run in separate containers and use separate Docker volumes.

---

## Airflow Project Mount

The project repository is mounted inside Airflow containers as:

```text
/app
```

This allows Airflow tasks to execute existing project scripts directly.

Example:

```text
Windows/host repository
        |
        v
Docker bind mount
        |
        v
/app/01_scripts/4a_load_staging.py
```

This makes it possible to reuse existing ETL scripts instead of rewriting them directly inside DAG files.

---

## Environment Variables

The project uses local environment files for configuration.

Example Docker environment variables:

```env
POSTGRES_USER=your_user_placeholder
POSTGRES_PASSWORD=your_password_placeholder
POSTGRES_DB=analytics_db

DB_HOST=db
DB_PORT=5432
HOST_POSTGRES_PORT=5434

DATA_DIR=/app/00_raw_data
STATIONS_CSV=/app/00_raw_data/stations.csv
WEATHER_CSV=/app/00_raw_data/weather_sample.csv

FERNET_KEY=your_fernet_key_here
AIRFLOW_UID=50000
```

Inside Docker Compose, Python connects to PostgreSQL using:

```text
db:5432
```

From the host machine, PostgreSQL can be accessed using:

```text
localhost:5434
```

Sensitive local values are stored in `.env` files and are not committed to Git.

---

## Running the Docker Environment

Start the Dockerized environment:

```powershell
docker compose up -d
```

Rebuild containers if required:

```powershell
docker compose up -d --build
```

Check service status:

```powershell
docker compose ps -a
```

Check logs for a service:

```powershell
docker compose logs <service>
```

Stop the environment:

```powershell
docker compose down
```

---

## Running Airflow

The Airflow UI is available locally at:

```text
http://localhost:8080
```

The current DAG can be triggered manually from the Airflow UI.

Each task has its own logs, including output generated by Python scripts and SQL execution.

---

## PostgreSQL Connection from VS Code

The PostgreSQL database can be accessed from VS Code using a PostgreSQL extension.

Example local connection settings:

```text
Host: localhost
Port: 5434
Database: analytics_db
User: postgres
SSL mode: Disable
```

Example validation queries:

```sql
SELECT COUNT(*)
FROM bronze.weather;

SELECT COUNT(*)
FROM silver.weather;

SELECT *
FROM gold.weather_observations
LIMIT 10;
```

---

## Benchmarks

The project includes performance comparisons of:

- CSV vs Apache Parquet
- Pandas vs Polars
- Read performance
- Write performance
- Storage efficiency
- Large-scale lazy processing

The benchmarks were performed using the complete NOAA dataset containing approximately 422 million observations.

---

## PostgreSQL Performance Experiments

The project also includes PostgreSQL performance experiments related to:

- incremental loading
- indexing
- unique constraints
- query execution plans
- large historical loads
- bootstrap vs incremental processing

A full historical Bronze load using incremental duplicate protection required significantly more time than a simple bulk load (12 hours to load 422 mln rows).

This demonstrated an important architectural lesson:

```text
Historical bootstrap and recurring incremental loading should not always use the same loading strategy.
```

Incremental logic optimized for recurring small batches can become expensive when applied to hundreds of millions of historical records.

---

## Analysis

The analytical part of the project is intentionally limited.

Its purpose is to validate the processed dataset and demonstrate SQL queries, Pandas, Polars, PySpark, and basic visualizations rather than perform comprehensive exploratory data analysis.

The primary focus remains Data Engineering.

---

## Current Status

Completed:

- Raw data preparation
- Pandas processing
- Polars processing
- Polars Lazy processing
- PySpark processing experiment
- CSV vs Parquet benchmark
- Pandas vs Polars benchmark
- PostgreSQL Staging architecture
- PostgreSQL Bronze layer
- PostgreSQL Silver layer
- PostgreSQL Gold VIEW
- Bronze incremental loading
- Silver incremental loading
- Natural key and duplicate protection
- Bronze data quality checks
- Silver data quality checks
- Gold data quality checks
- PostgreSQL performance experiments
- Dockerfile for Python environment
- Docker Compose setup
- Automated database initialization
- Apache Airflow setup
- Airflow LocalExecutor configuration
- Airflow orchestration of Staging -> Bronze -> Silver
- Automated Airflow DQ tasks
- Airflow task logging
- PostgreSQL connection from VS Code

In progress:

- Automated incremental NOAA data retrieval
- Automatic detection of the newest observation already stored in Bronze
- Filtering NOAA data to only new observations
- Saving the missing batch as the next Staging input
- Adding the incremental NOAA update as the first Airflow DAG task
- SQL window functions practice
- Selected pytest tests
- Final project documentation

---

## Future Improvements

- Complete automated incremental NOAA data retrieval
- Add the incremental NOAA preparation step as the first Airflow task
- Add selected pytest tests where they provide real value
- Practice SQL window functions on the weather dataset
- Improve final project documentation
- Improve the architecture diagram
- Review Docker Compose configuration and understand each important section
- Review `.env`, `.env.analysis`, `.env.example`, and `.env.example.analysis`
- Add cloud storage integration as a later learning step
- Explore Data Warehouse / Data Lake / Data Lakehouse architecture concepts
- Explore Spark, Kafka, and cloud services only after the current pipeline is complete

---

## License

This project is available under the MIT License.