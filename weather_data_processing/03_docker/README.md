# Docker Environment
This directory contains the Docker configuration required to run the Weather Data Processing project. Docker ensures that the entire data processing environment (Python, PostgreSQL and dependencies) can be reproduced on any machine with a single command, eliminating configuration differences between development environments.

## Components
- Python
- PostgreSQL
- Pandas
- Polars
- psycopg2

# Docker Runbook

## Purpose

This runbook describes how to start and validate the Dockerized weather data pipeline.

The Docker setup runs:

- PostgreSQL database in a container
- database initialization scripts
- Bronze data load from sample CSV files
- Python ETL scripts inside a containerized Python environment

---

## Images vs Containers

Docker image is a blueprint used to create containers.

Docker container is a running instance of an image.

In Docker Desktop, the `Images` tab shows built images such as:

```text
weather-python
weather_data_processing-app
```

These are not running containers.

Running containers should be checked with:

```powershell
docker compose ps
```

---

## Services

The project uses Docker Compose services:

```text
db
```

PostgreSQL database container.

```text
init-db
```

One-time service that initializes database schemas and tables by running SQL scripts.

```text
load-bronze
```

One-time service that loads sample CSV data into the Bronze layer.

```text
app
```

Python application container used for sanity checks and script execution.

---

## Environment

The project uses a local `.env` file.

Example:

```env
POSTGRES_USER=postgres
POSTGRES_PASSWORD=admin
POSTGRES_DB=analytics_db

DB_HOST=db
DB_PORT=5432
HOST_POSTGRES_PORT=5434

DATA_DIR=/app/00_raw_data
STATIONS_CSV=/app/00_raw_data/stations.csv
WEATHER_CSV=/app/00_raw_data/weather_sample.csv
```

Important:

```text
DB_HOST=db
DB_PORT=5432
```

is used inside Docker Compose.

```text
localhost:5434
```

is used from the host machine, for example from VS Code PostgreSQL extension.

---

## Start the Project

Open Docker Desktop.

Open PowerShell in the project root:

```text
weather_data_processing
```

Run:

```powershell
docker compose up -d --build
```

This starts the Docker Compose pipeline in detached mode.

---

## Check Services

Run:

```powershell
docker compose ps
```

Expected idea:

```text
db           running / healthy
init-db      exited successfully
load-bronze  exited successfully
app          started or exited
```

One-time services may exit after completing their job.  
That is expected.

---

## Check Bronze Load Logs

Run:

```powershell
docker compose logs load-bronze
```

Expected successful output should include:

```text
Connected.
COPY for bronze.stations finished.
COPY for bronze.weather finished.
Data was loaded successfully
Database connection closed.
```

Older errors may still appear in full logs.  


---

## Validate Data in PostgreSQL

Connect from VS Code PostgreSQL extension using:

```text
Host: localhost
Port: 5434
Database: analytics_db
User: postgres
Password: admin
SSL mode: Disable
```

Run validation queries:

```sql
SELECT COUNT(*)
FROM bronze.weather;

SELECT COUNT(*)
FROM bronze.stations;
```

Preview data:

```sql
SELECT *
FROM bronze.weather
LIMIT 100;
```

---

## Stop the Project

Stop containers but keep database volume:

```powershell
docker compose down
```

This removes containers and the Docker network, but keeps PostgreSQL data in the named volume.


---

## Manual Script Execution

Run a Python script inside the app container:

```powershell
docker compose run --rm app python 01_scripts/docker_postgres_connection_test.py
```

Run the Bronze loader manually:

```powershell
docker compose run --rm app python 01_scripts/4_load_bronze.py
```

The `--rm` flag removes the temporary one-off container after the script finishes.

It does not remove:

- Docker images
- PostgreSQL database
- Docker volumes
- local project files

---

## Current Pipeline Order

Current Docker Compose flow:

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

## Notes

The Docker pipeline uses sample data by default:

```text
00_raw_data/weather_sample.csv
```

This makes the project easy to run without loading the full NOAA dataset.

The full NOAA dataset is used for data preparation and benchmarking, but it is not loaded by default in the Docker demo workflow.