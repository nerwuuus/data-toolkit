# Docker

Docker provides the infrastructure required to run the Weather Data Processing project.

## Architecture

```text
Docker Compose
    ↓
PostgreSQL + Airflow

First-time database setup
    ↓
init-db

Recurring pipeline
    ↓
Airflow DAG
```

Docker Compose runs the infrastructure.

Airflow orchestrates the recurring incremental pipeline.

The `init-db` service is used only for the initial database setup or an intentional full rebuild. It is kept outside the Airflow DAG because it creates database objects and may execute destructive DDL statements.

## Quick Start

Create a local `.env` file:

```powershell
Copy-Item .env.example .env
```

Start the infrastructure:

```powershell
docker compose up -d
```

## First-Time Database Setup

Run only when creating the database structure for the first time or rebuilding it intentionally:

```powershell
docker compose --profile setup run --rm init-db
```

This creates the required database layers:

- Staging
- Bronze
- Silver
- Gold

## Incremental Pipeline

The recurring pipeline is orchestrated by Apache Airflow:

```text
load_incremental_batch
        ↓
load_bronze
        ↓
bronze_dq
        ↓
load_silver
       ↙       ↘
silver_dq   gold_dq
```

`load_incremental_batch`:

- fetches the latest Bronze observation date
- downloads current NOAA weather data
- filters only new observations
- prepares NOAA station metadata
- loads the incremental batch into PostgreSQL Staging

Bronze and Silver are then updated using SQL procedures, followed by automated data quality checks.

## Database Access

From Windows tools such as VS Code or Jupyter:

```text
Host: localhost
Port: 5434
Database: analytics_db
User: postgres
```

From containers inside Docker Compose:

```text
Host: db
Port: 5432
Database: analytics_db
```

Both connection methods access the same PostgreSQL database running in Docker.

## Historical Bootstrap

The historical NOAA dataset contains more than 420 million weather observation records.

The historical bootstrap is handled separately from the recurring incremental pipeline because full historical loads and incremental loads require different strategies.

Bootstrap scripts are not part of the normal Airflow DAG.

## Stop

```powershell
docker compose down
```

PostgreSQL data remains stored in the Docker volume.
