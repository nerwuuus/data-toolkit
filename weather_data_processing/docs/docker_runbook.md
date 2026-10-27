# Docker

Docker provides the infrastructure required to run the Weather Data Processing project.

## Architecture

```text
Docker Compose
    ↓
PostgreSQL + Airflow

First-time setup
    ↓
init-db

Recurring pipeline
    ↓
Airflow DAG
```

Docker Compose runs the infrastructure, while Apache Airflow orchestrates the recurring incremental pipeline.

The `init-db` service is used only for the initial database setup or a full rebuild and is intentionally kept outside the Airflow DAG.

## Quick Start

Create `.env` from the example file:

```powershell
Copy-Item .env.example .env
```

Start the infrastructure:

```powershell
docker compose up -d db
```

## Initialize Database

Run only for the first setup or a full rebuild:

```powershell
docker compose --profile setup run --rm init-db
```

This creates the Staging, Bronze, Silver and Gold database layers.

## Incremental Pipeline

The recurring pipeline is orchestrated by Airflow:

```text
load_incremental_batch
        ↓
load_bronze
        ↓
bronze_dq
        ↓
load_silver
        ↓
silver_dq + gold_dq
```

The incremental batch task downloads current NOAA data, filters observations newer than the latest Bronze date and loads them into Staging.

## Database Access

From Windows / VS Code:

```text
Host: localhost
Port: 5434
Database: analytics_db
User: postgres
```

Inside Docker Compose:

```text
Host: db
Port: 5432
```

## Stop

```powershell
docker compose down
```

PostgreSQL data remains stored in the Docker volume.
