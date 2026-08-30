# Docker Environment

This directory contains the Docker configuration required to run the Weather Data Processing project. Docker ensures that the entire data processing environment (Python, PostgreSQL and dependencies) can be reproduced on any machine with a single command, eliminating configuration differences between development environments.

## Components

- Python
- PostgreSQL
- Pandas
- Polars
- PyArrow
- psycopg2

## Start

```bash
docker compose up
docker compose down
