# Docker

This directory contains the Docker configuration used to run the Weather Data Processing project in a reproducible local environment.

## Files

- `Dockerfile` — builds the Python application image and installs project dependencies from `requirements.txt`.
- `compose.yaml` — defines the PostgreSQL database and pipeline services.
- `.env.example` — example environment configuration for Docker Compose.

## Pipeline

The Docker workflow uses the following structure:

```text
db
  ↓
load-staging
  ↓
load-bronze
  ↓
load-silver
```

The Gold layer is implemented as a SQL view, so it does not require a separate load service during normal pipeline execution.

The `init-db` service is intended only for the first database setup or for an intentional full rebuild. It should not be part of the regular incremental pipeline because the DDL scripts may recreate database objects.

## Data

The Docker workflow uses the sample weather dataset and full stations dataset by default:

```text
00_raw_data/weather_sample.csv
00_raw_data/stations.csv
```

The full NOAA dataset is used separately for local analysis and performance benchmarking and is not loaded by default in the Docker environment.

## Documentation

For setup instructions, first-time database initialization, running individual services, checking logs, and validating the pipeline, see:

```text
docs/docker_runbook.md
```
