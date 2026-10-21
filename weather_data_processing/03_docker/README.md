# Docker

This directory contains the Docker configuration used to run the Weather Data Processing project in a reproducible local environment.

## Files

- `Dockerfile` — builds the Python application image and installs project dependencies from `requirements.txt`.
- `compose.yaml` — defines the PostgreSQL database, Python application environment, and Airflow services.
- `.env.example` — example environment configuration for Docker Compose.

## Docker Architecture

Docker Compose provides the infrastructure required by the project.

The main runtime components are:

```text
NOAA
  ↓
Airflow
  ↓
Python / SQL pipeline
  ↓
PostgreSQL
```

Pipeline execution is orchestrated by Airflow rather than by separate Docker Compose load services.

The current incremental workflow is:

```text
load_incremental_batch
        ↓
load_bronze
        ↓
bronze_dq
        ↓
load_silver
      ↙     ↘
silver_dq  gold_dq
```

The Gold layer is implemented as a PostgreSQL VIEW and therefore does not require a separate load task.

## Database Initialization

The `init-db` service is an optional on-demand setup service used to initialize or intentionally rebuild database objects.

It is run manually only when database setup or reconstruction is required.

It is not part of the recurring incremental pipeline because the DDL scripts WILL modify existing database objects.

Historical bootstrap loading is handled separately from recurring incremental processing.

After the historical bootstrap, the required `UNIQUE` constraints are restored to support `ON CONFLICT` during normal incremental loads.

This separation was introduced after the full historical Bronze load took approximately 12 hours 56 minutes when incremental duplicate-checking logic was used, while the dedicated bootstrap approach completed in over 1 hour.

## Airflow

Airflow orchestrates the recurring weather data pipeline.

The current setup uses `LocalExecutor` and includes:

- `airflow-postgres`
- `airflow-init`
- `airflow-apiserver`
- `airflow-scheduler`
- `airflow-dag-processor`

Airflow uses a separate PostgreSQL database for its internal metadata.

The weather PostgreSQL database and the Airflow metadata database therefore run independently.

The Airflow UI is available at:

```text
http://localhost:8080
```

Airflow files are stored in:

```text
06_airflow/
```

For additional Airflow setup notes, see:

```text
docs/airflow_environment.md
```

## Custom Airflow Image

Airflow uses a custom Docker image based on:

```text
apache/airflow:3.3.2
```

The custom image installs the Python dependencies required by the pipeline from the project `requirements.txt`.

The project repository is mounted into the Airflow containers as:

```text
/app
```

The bind mount provides access to project files, while the Docker image provides the Python runtime and required libraries.

This keeps the application and Airflow environments aligned and avoids dependency differences between manually executed pipeline scripts and Airflow tasks.

## Incremental NOAA Processing

The pipeline starts with:

```text
01_scripts/13_process_noaa_incremental_batch.py
```

The script:

- reads the latest `observation_date` stored in Bronze
- downloads the current NOAA yearly weather dataset
- filters observations newer than the Bronze watermark
- downloads and prepares NOAA station metadata
- saves intermediate CSV files
- loads the current batch into PostgreSQL Staging using `COPY`

Staging contains only the current incoming batch.

Historical data is preserved in Bronze and Silver.

## Data Files

Runtime data files are stored under:

```text
00_raw_data/
```

Examples include:

```text
weather.csv
stations.csv
weather_bootstrap.csv
```

Large source and generated data files are excluded from Git and Docker image builds.

Bootstrap data and recurring incremental batches are handled separately.

## PostgreSQL Connections

Containers inside Docker Compose connect to the weather PostgreSQL database using:

```text
db:5432
```

Tools running directly on the Windows host, such as VS Code or Jupyter Notebook, connect to the same Dockerized PostgreSQL database through:

```text
localhost:5434
```

Both connection paths access the same PostgreSQL database.

## Running the Environment

Build and start the environment:

```powershell
docker compose up -d --build
```

Start the existing images without rebuilding:

```powershell
docker compose up -d
```

Check service status:

```powershell
docker compose ps -a
```

Check logs:

```powershell
docker compose logs <service>
```

Stop the environment:

```powershell
docker compose down
```

## Documentation

For additional setup and operational notes, see:

```text
docs/docker_runbook.md
docs/airflow_environment.md
```
