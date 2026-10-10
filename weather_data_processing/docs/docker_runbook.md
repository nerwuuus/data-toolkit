# Docker

This directory contains the Docker configuration required to run the Weather Data Processing project.

Docker makes the project environment reproducible by running PostgreSQL, Python,
and the required project dependencies in containers.

## Components

- Python
- PostgreSQL
- Pandas
- Polars
- psycopg2
- Docker Compose

# Docker Runbook

## Quick Start

Open Docker Desktop.

Open PowerShell in the project root:

```text
weather_data_processing
```

Create a local `.env` file from the example file:

```powershell
Copy-Item .env.example .env
```

---

## First-Time Database Setup

The `init-db` service is intended only for the initial database setup or for a
deliberate full rebuild.

It creates the database schemas and layer structures:

- Staging tables
- Bronze tables
- Silver tables
- Gold view

Run:

```powershell
docker compose up db init-db
```

Important:

`init-db` executes DDL scripts that may contain `DROP TABLE IF EXISTS`.
It should therefore not be part of the normal incremental pipeline.

Use it only when creating the database structure for the first time or when
intentionally rebuilding the environment.

---

## Run the Data Pipeline

After the database structure has already been initialized, start the normal
pipeline with:

```powershell
docker compose up load-silver
```

Docker Compose will start the required dependencies automatically:

```text
db
  ↓
load-staging
  ↓
load-bronze
  ↓
load-silver
```

Meaning:

```text
db
    Starts PostgreSQL.

load-staging
    Loads the current raw CSV batch into Staging tables.

load-bronze
    Incrementally loads new records from Staging into Bronze.
    Existing records are detected using natural keys.
    Staging tables are cleared only after successful validation.

load-silver
    Incrementally loads transformed and cleaned records from Bronze into Silver.

gold.poland_weather_observations
    Provides an analysis-ready SQL view based on the current Silver data.
```

The Gold layer uses a regular SQL view, so there is no separate `load-gold`
service required during normal pipeline execution.

The Gold view definition is created during the first-time database setup.

---

## Rebuild Docker Images

If the Python image or dependencies have changed:

```powershell
docker compose build
```

or:

```powershell
docker compose up --build load-silver
```

---

## Run Individual Services

Start only PostgreSQL:

```powershell
docker compose up db
```

Load only Staging:

```powershell
docker compose up load-staging
```

Run the Bronze load:

```powershell
docker compose up load-bronze
```

Run the Silver load:

```powershell
docker compose up load-silver
```

Dependencies defined in `compose.yaml` may cause required earlier services to
start automatically.

---

## Check Logs

Check database initialization:

```powershell
docker compose logs --tail=50 init-db
```

Check Staging load:

```powershell
docker compose logs --tail=50 load-staging
```

Check Bronze load:

```powershell
docker compose logs --tail=50 load-bronze
```

Expected successful Bronze output includes:

```text
Bronze tables have been successfully updated.
```

Check Silver load:

```powershell
docker compose logs --tail=50 load-silver
```

Expected successful Silver output includes:

```text
Silver tables have been successfully updated.
```

---

## Validate Data

Connect from the VS Code PostgreSQL extension:

```text
Host: localhost
Port: 5434
Database: analytics_db
User: postgres
Password: admin
SSL mode: Disable
```

Run:

```sql
SELECT COUNT(*)
FROM staging.weather;

SELECT COUNT(*)
FROM bronze.weather;

SELECT COUNT(*)
FROM bronze.stations;

SELECT COUNT(*)
FROM silver.weather;

SELECT COUNT(*)
FROM silver.stations;

SELECT COUNT(*)
FROM gold.poland_weather_observations;
```

Preview the Gold analysis view:

```sql
SELECT *
FROM gold.poland_weather_observations;
```

After a successful Bronze load, the Staging tables should normally be empty.

---

## Stop the Project

```powershell
docker compose down
```

This stops and removes containers, but keeps the PostgreSQL data volume.

---

## Notes

The Docker pipeline uses sample weather data by default:

```text
00_raw_data/weather_sample.csv
```

The full NOAA dataset is used for local preparation, analysis, and benchmarking,
but it is not loaded by default in the Docker workflow.

The full dataset contains over 422 million weather observation rows.

The Docker workflow is intended to provide a reproducible development and
demonstration environment without requiring the full historical dataset.
