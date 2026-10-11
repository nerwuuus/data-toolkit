# Airflow

This directory contains the Apache Airflow configuration used to orchestrate the Weather Data Processing pipeline.

The current local setup uses `LocalExecutor`.

## Executor Choice

The Airflow configuration currently uses:

```text
AIRFLOW__CORE__EXECUTOR=LocalExecutor
```

`LocalExecutor` is sufficient for this project because the pipeline is developed and tested locally on a single machine.

## Why Celery Components Are Disabled

This project uses `LocalExecutor`, so Celery-specific components are not required:

- **Redis** — Celery message broker.
- **airflow-worker** — executes Celery tasks.
- **Flower** — monitors Celery workers and queues.

They are disabled because tasks are executed locally.

## Current Airflow Services

The local setup currently uses:

- airflow-postgres
- airflow-init
- airflow-apiserver
- airflow-scheduler
- airflow-dag-processor

Redis, Celery workers, and Flower are intentionally excluded.
