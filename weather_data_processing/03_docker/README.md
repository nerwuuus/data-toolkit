# Docker Environment
This directory contains the Docker configuration required to run the Weather Data Processing project. Docker ensures that the entire data processing environment (Python, PostgreSQL and dependencies) can be reproduced on any machine with a single command, eliminating configuration differences between development environments.

## Components
- Python
- PostgreSQL
- Pandas
- Polars
- psycopg2

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

This starts PostgreSQL, initializes database schemas and tables, and loads the sample weather dataset into the Bronze layer.

For later runs, when the image is already built, this is usually enough:

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
```

Meaning:

```text
Start PostgreSQL
Create schemas and Bronze tables
Load sample CSV data into Bronze tables
```

---

## Check Pipeline Status

```powershell
docker compose ps
```

Expected result:

```text
db           running / healthy
init-db      exited successfully
load-bronze  exited successfully
```

One-time services may exit after completing their job. This is expected.

---

## Check Bronze Load Logs

```powershell
docker compose logs load-bronze
```

Expected successful output includes:

```text
COPY for bronze.stations finished.
COPY for bronze.weather finished.
Data was loaded successfully
Database connection closed.
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

The full NOAA dataset is used for preparation and benchmarking, but it is not loaded by default in the Docker demo workflow. It contains 422 million rows.