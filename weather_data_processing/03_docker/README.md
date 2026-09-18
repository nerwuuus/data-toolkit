# Docker

This directory contains the Docker configuration required to run the Weather Data Processing project.

Docker makes the project environment reproducible by running PostgreSQL, Python, and all required dependencies in containers.

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

Start the Dockerized pipeline:

```powershell
docker compose up -d --build
```

This starts PostgreSQL, initializes the database structure, loads the sample weather dataset into the Bronze layer, transforms it into the Silver layer, and exposes the Gold analysis view.

For later runs, when the image is already built, use:

```powershell
docker compose up -d
```

---

## What Docker Compose Runs

```text
db
  ↓
init-db
  ↓
load-bronze
  ↓
load-silver
```

Meaning:

```text
db
    Starts PostgreSQL.

init-db
    Creates database schemas.
    Creates Bronze tables.
    Creates Silver tables.
    Creates Gold view.

load-bronze
    Loads sample CSV data into Bronze tables.

load-silver
    Transforms Bronze data into Silver tables.

gold.poland_weather_observations
    Provides an analysis-ready view for Polish weather observations.
```

The Gold layer currently uses a SQL view, so there is no separate `load-gold` service.

---

## Check Logs

Check database initialization:

```powershell
docker compose logs --tail=50 init-db
```

Check Bronze load:

```powershell
docker compose logs --tail=50 load-bronze
```

Expected successful Bronze output includes:

```text
COPY for bronze.stations finished.
COPY for bronze.weather finished.
Data was loaded successfully
Database connection closed.
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

Connect from VS Code PostgreSQL extension:

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

---

## Stop the Project

```powershell
docker compose down
```

This stops and removes containers, but keeps the PostgreSQL data volume.

---

## Notes

The Docker pipeline uses sample data by default:

```text
00_raw_data/weather_sample.csv
```

The full NOAA dataset is used for preparation and benchmarking, but it is not loaded by default in the Docker demo workflow. It contains over 422 million rows.
