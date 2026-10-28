# Weather Data Processing

## Initial Project Scope

The project originally started as a small ETL project focused on:

- Loading public NOAA weather data into PostgreSQL
- Processing the data with Pandas & Polars
- Performing basic data quality checks
- Generating a few exploratory plots
- Exporting the processed data to CSV

The scope expanded over time as the project evolved into a broader Data Engineering learning environment, including large-scale Parquet processing, Polars Lazy, PySpark, SQL transformations, bootstrap and incremental loading, Docker, PostgreSQL performance experiments, automated data quality checks, and Airflow orchestration.

---

## Overview

Weather Data Processing is an end-to-end Data Engineering project built around the NOAA Global Historical Climatology Network Daily (GHCN-Daily) dataset.

The project demonstrates a complete data processing workflow, starting from NOAA source data, through Staging and layered PostgreSQL processing, to automated incremental updates and data quality validation using Airflow.

The current architecture uses:

`NOAA -> Staging -> Bronze -> Silver -> Gold VIEW`

The primary goal of this project is to practice Data Engineering concepts rather than perform extensive exploratory data analysis.

---

## Dataset

- Source: NOAA Global Historical Climatology Network Daily (GHCN-Daily)
- Time period: 2015-2026, with 2026 data updated incrementally
- Number of observations: approximately 429 million
- Number of weather stations: worldwide
- Station metadata: approximately 140,000 stations

The historical dataset is used for bootstrap loading, benchmarking, and large-scale processing experiments.

New NOAA observations are retrieved incrementally and loaded through the same Staging -> Bronze -> Silver pipeline.

---

## Project Objectives

- Process a large real-world dataset containing hundreds of millions of observations
- Compare CSV and Parquet storage formats
- Compare Pandas and Polars performance
- Experiment with PySpark
- Build a Staging -> Bronze -> Silver -> Gold architecture
- Separate historical bootstrap loading from recurring incremental loading
- Load and transform data in PostgreSQL
- Implement natural-key-based incremental loading
- Add automated data quality checks
- Orchestrate the pipeline with Airflow
- Practice reproducible Data Engineering workflows with Docker
- Practice PostgreSQL optimisations and window functions

---

## Project Structure

```text
weather_data_processing/
├── 00_raw_data/                     # Local raw, bootstrap and incremental data files
├── 01_scripts/                      # Python, SQL, notebooks, benchmarks and ETL scripts
│   └── tests/                       # Development and test scripts/notebooks
├── 02_plots/                        # Generated charts
├── 03_docker/                       # Docker-related files and notes
├── 04_data_quality_checks_sql/      # Manual and automated SQL data quality checks
│   └── automated_airflow_checks/    # SQL DQ checks executed automatically by Airflow
├── 05_postgres_optimisation/        # PostgreSQL performance and index experiments
├── 06_airflow/                      # Airflow DAGs, Dockerfile, logs, plugins and documentation
├── docs/                            # Project documentation and pipeline diagrams
├── compose.yaml                     # Docker Compose configuration
├── requirements.txt                 # Shared Python dependencies
├── .env.example                     # Example environment configuration
├── .dockerignore                    # Files excluded from Docker build context
└── README.md
```

---

## Technologies

- Python
- Pandas
- Polars
- PySpark
- PostgreSQL
- Airflow
- Parquet
- Jupyter Notebook
- Docker
- SQLAlchemy
- psycopg2
- Git
- GitHub
- VS Code PostgreSQL extension
- ChatGPT/AI-assisted development (especially Docker)

---

## Data Pipeline

```text
NOAA GHCN-Daily (Weather & Stations)
              |
              v
    load_incremental_batch
              |
              v
     Intermediate CSV batch
              |
              v
       Staging (PostgreSQL)
              |
              v
        load_bronze
              |
              v
         Bronze
              |
              v
        bronze_dq
              |
              v
        load_silver
              |
              v
          Silver
              |
        +-----+------+
        |            |
        v            v
    silver_dq     gold_dq
                     |
                     v
              Gold VIEW (read)
```

The recurring pipeline is orchestrated with Airflow.

Staging represents only the current incoming batch, while Bronze and Silver preserve historical data using incremental loading logic.

Gold is implemented as a PostgreSQL VIEW and therefore does not require a separate load step during each pipeline run.

---

## Bootstrap Loading

Historical bootstrap loading is intentionally separated from recurring incremental loading.

The initial historical dataset is prepared and loaded with bootstrap-specific scripts. This avoids applying expensive incremental duplicate-protection logic to hundreds of millions of rows during the first load.

Examples include:

- `3a_bootstrap_prepare_weather_data_pandas.ipynb`
- `4a_load_staging_bootstrap.py`

After the historical bootstrap, the required `UNIQUE` constraints are restored to support `ON CONFLICT` during recurring incremental loads.

This separation was introduced after the full historical Bronze load took approximately 12 hours 56 minutes when incremental duplicate-checking logic was used, while the dedicated bootstrap approach completed in over 1 hour.

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

---

## Silver Layer

The Silver layer contains cleaned and transformed data.

Examples of transformations include:

- Trimming station identifiers
- Cleaning station names
- Converting NOAA temperature values to meaningful units by dividing by 10
- Replacing invalid elevation sentinel values -999.99 with `NULL`

Incremental loading inserts only records not already present in Silver.

---

## Gold Layer

The Gold layer is implemented as a PostgreSQL VIEW.

It combines prepared weather observations with station metadata and exposes data in a form suitable for analysis.

Because Gold is a normal VIEW, it automatically reflects current Silver data and does not require a separate load or refresh task during each Airflow run.

---

## Incremental NOAA Processing

The recurring source-processing step is implemented in:

`01_scripts/13_process_noaa_incremental_batch.py`

The script:

1. Connects to PostgreSQL and reads `MAX(observation_date)` from `bronze.weather`.
2. Detects the current year dynamically.
3. Downloads the current NOAA yearly weather dataset.
4. Reads and prepares weather data with Polars.
5. Converts `observation_date` to a proper `Date` type.
6. Filters observations newer than the current Bronze watermark.
7. Downloads NOAA station metadata from the fixed-width station file.
8. Parses the station metadata with Pandas and converts it to Polars.
9. Writes intermediate `weather.csv` and `stations.csv` files.
10. Uses PostgreSQL `COPY` through psycopg2 to load the current batch into Staging.

The current-year NOAA file can contain millions of records, so PostgreSQL `COPY` is used instead of row-by-row inserts.

---

## Incremental Loading

The pipeline uses natural keys to prevent duplicate inserts. A natural key is a combination of business-related columns that uniquely 
identifies a record without using an artificial ID.

For weather observations, the natural key is `station + observation_date + metric`.

For stations, the natural key is `station`.

Incremental loading is implemented using PostgreSQL logic based on:

- `WHERE NOT EXISTS`
- `UNIQUE` constraints
- `ON CONFLICT DO NOTHING`

This prevents duplicate historical records from being inserted.

---

## Current Airflow Pipeline

The current pipeline is orchestrated using Airflow, with incremental data loading, Bronze and Silver transformations, and automated data quality checks.

<<<<<<< HEAD
For more detailed information about the pipeline architecture, DAG task dependencies, execution flow and data quality validation, see the [Airflow README](./06_airflow/README.md).
=======
The current DAG orchestrates the complete recurring incremental workflow:

```text
load_incremental_batch
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

- `load_incremental_batch`
  - uses `BashOperator`
  - runs `/app/01_scripts/13_process_noaa_incremental_batch.py`
  - retrieves the latest Bronze watermark
  - downloads and prepares NOAA weather and station data
  - filters the new weather observations
  - loads the current batch into Staging using PostgreSQL `COPY`

- `load_bronze`
  - uses `SQLExecuteQueryOperator`
  - executes the PostgreSQL `load_bronze()` procedure
  - loads new Staging records into Bronze

- `bronze_dq`
  - runs automated Bronze data quality validation before Silver processing

- `load_silver`
  - uses `SQLExecuteQueryOperator`
  - executes the PostgreSQL `load_silver()` procedure
  - transforms and loads new Bronze records into Silver

- `silver_dq`
  - runs automated Silver data quality validation

- `gold_dq`
  - runs automated Gold data quality validation

Data quality SQL uses PostgreSQL exception logic so that failed validation causes the corresponding Airflow task to fail automatically.

![Weather Data Pipeline](https://raw.githubusercontent.com/nerwuuus/data-toolkit/main/weather_data_processing/docs/weather_data_pipeline-graph.png)
>>>>>>> d953776f9c21de836ed928eb8d3e935571a265cf

---

## Staging

Staging represents only the current incoming batch.

During recurring incremental runs, `13_process_noaa_incremental_batch.py` truncates and reloads:

- `staging.stations`
- `staging.weather`

before loading the newly prepared source batch.

This behavior is intentional.

Historical data is not preserved in Staging because its purpose is to hold only the current incoming source batch.

Incremental history is preserved in Bronze and Silver.

The expected recurring flow is:

```text
Current NOAA data
        |
        v
Filter observations newer than Bronze watermark
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

Docker Compose is used to run the local PostgreSQL and Airflow environment.

The main components include:

- `db`
  - PostgreSQL database used by the weather pipeline

- `init-db`
  - optional on-demand setup service used to initialize or rebuild database objects
  - **intended to be run manually only when database setup or reconstruction is required**

- `app`
  - Python application image used for standalone pipeline/script execution and development tests

- `airflow-postgres`
  - separate PostgreSQL database used only for Airflow metadata

- `airflow-apiserver`
  - exposes the Airflow UI and API

- `airflow-scheduler`
  - schedules DAG runs and tasks

- `airflow-dag-processor`
  - processes DAG definitions

Airflow uses `LocalExecutor`.

Runtime pipeline orchestration is handled by Airflow rather than duplicated through separate Docker Compose load services.

The weather PostgreSQL database and the Airflow metadata database run in separate containers and use separate Docker volumes.

---

## Running the Docker Environment

The project uses Docker Compose to manage and run the containerized environment.

For detailed instructions on starting, rebuilding, monitoring, troubleshooting and stopping Docker services, see the [Docker Runbook](./docs/docker_runbook.md).

---

## Custom Airflow Image

Airflow runs in its own Docker containers with a separate Python environment from the project's app service.

The project repository is mounted into the Airflow containers using:

```text
.:/app
```

This makes the project files accessible inside the containers. However, mounting a directory does not make Python dependencies installed in the app image available to Airflow.

To ensure that Airflow has access to all required dependencies, the project uses a custom Docker image based on:

```text
apache/airflow:3.3.2
```

<<<<<<< HEAD
The custom image installs the project dependencies from `requirements.txt`.
=======
The custom image includes the Python packages required to execute the project's data pipelines.
>>>>>>> d953776f9c21de836ed928eb8d3e935571a265cf

The Docker and Docker Airflow environment were developed with AI assistance and manually tested during project development.

The main separation is:

- Docker volumes provide access to project files.
- Docker images provide the Python runtime and installed dependencies.
- Docker Compose networking allows Airflow tasks to reach PostgreSQL through `db:5432`.

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
/app/01_scripts/13_process_noaa_incremental_batch.py
```


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
WEATHER_CSV=/app/00_raw_data/weather.csv
WEATHER_BOOTSTRAP_CSV=/app/00_raw_data/weather_bootstrap.csv

FERNET_KEY=your_fernet_key_here
AIRFLOW_UID=50000
```

Inside Docker Compose, Python and Airflow tasks connect to PostgreSQL using:

```text
db:5432
```

From the Windows host, local tools such as VS Code and Jupyter connect to the same PostgreSQL container using:

```text
localhost:5434
```

Sensitive local values are stored in `.env` and are not committed to Git.

---

## Running Airflow

The Airflow UI is available locally at:

```text
http://localhost:8080
```

The current DAG can be triggered manually from the Airflow UI.

Airflow retries are configured at DAG level so transient task failures can be retried automatically.

---

## PostgreSQL Connection from VS Code and Jupyter

The PostgreSQL database runs inside Docker but is exposed to the Windows host through port `5434`.

Example local connection settings:

```text
Host: localhost
Port: 5434
Database: analytics_db
User: postgres
SSL mode: Disable
```

Local Jupyter notebooks use the same host connection, while scripts running inside Docker use `db:5432`.

---


## Benchmarks

The project includes performance comparisons of CSV vs Parquet and Pandas vs Polars, focusing on read/write performance, storage efficiency and large-scale data processing.

Benchmarks were performed using the historical NOAA dataset containing over 422 million observations.

For detailed results and implementation, see:

- [Pandas vs Polars Benchmark](./01_scripts/3e_pandas_vs_polars_benchmark.ipynb)
- [CSV vs Parquet Benchmark](./01_scripts/3d_csv_vs_parquet_benchmark.ipynb)


---


## PostgreSQL Optimisation

The project includes PostgreSQL performance experiments covering indexing, query execution plans, unique constraints and historical vs incremental loading strategies.

The experiments demonstrated how query selectivity affects index usage and why large historical loads may require a different approach from recurring incremental batches.

For more details, see the [PostgreSQL Optimisation](./05_postgres_optimisation/) directory.


---

## Analysis and SQL Practice

The analytical part of the project is intentionally limited.

Its purpose is to validate the processed dataset and demonstrate SQL, Pandas, Polars, PySpark, and basic visualizations rather than perform comprehensive exploratory data analysis.

A dedicated SQL practice script is used to continue learning analytical SQL, including window functions, on the real weather dataset.

The primary focus remains Data Engineering.

---

## License

This project is available under the MIT License.
