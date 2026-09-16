# Weather Data Processing

## Overview

Weather Data Processing is an end-to-end Data Engineering project built around the NOAA Global Historical Climatology Network Daily (GHCN-Daily) dataset.

The project demonstrates a complete data processing workflow, starting from raw weather observations, through data preparation and format benchmarking, to loading data into PostgreSQL using a Bronze → Silver → Gold architecture.

**The primary goal of this project is to practice Data Engineering concepts rather than perform extensive exploratory data analysis.**

---

## Dataset

- Source: NOAA Global Historical Climatology Network Daily (GHCN-Daily)
- Time period: 2015–2025
- Number of observations: ~422 million
- Number of weather stations: worldwide
- Docker demo dataset: 100,000 weather observations sample

The full NOAA dataset is used for local data preparation and benchmarking.

A smaller sample dataset is included to make the Dockerized pipeline easier to run and test.

---

## Project Objectives

- Process a large real-world dataset (~422 million observations)
- Compare CSV and Apache Parquet storage formats
- Compare Pandas and Polars performance
- Build a Bronze → Silver → Gold data pipeline
- Load data into PostgreSQL
- Automate the Bronze layer load with Docker Compose
- Perform basic analytical queries and visualizations
- Practice reproducible Data Engineering workflows with Docker

---

## Project Structure

```text
weather_data_processing/
├── 00_raw_data/        # Raw data files, station metadata and sample dataset
├── 01_scripts/         # Python notebooks, SQL scripts, benchmarks and ETL scripts
├── 02_plots/           # Generated charts
├── 03_docker/          # Dockerfile and Docker-related notes
├── compose.yaml        # Docker Compose configuration
├── requirements.txt    # Python dependencies
├── .env                # Local environment variables, not committed to Git
├── .dockerignore       # Files excluded from Docker build context
└── README.md
```

---

## Technologies

- Python
- Pandas
- Polars
- PostgreSQL
- SQL
- Jupyter Notebook
- Docker
- Docker Compose
- Git
- GitHub
- VS Code PostgreSQL extension

---

## Data Pipeline

```text
NOAA GHCN-Daily
        │
        ▼
Raw CSV files
        │
        ▼
Data preparation
(Pandas / Polars)
        │
        ▼
CSV / Apache Parquet
        │
        ▼
PostgreSQL
Bronze Layer
        │
        ▼
Silver Layer
        │
        ▼
Gold Layer
        │
        ▼
SQL analysis / Pandas / Seaborn visualizations
```

---

## Docker Workflow

The project includes a Docker Compose setup for running PostgreSQL and Python ETL scripts in containers.

The current Docker Compose workflow includes:

- `db` - PostgreSQL database container
- `init-db` - one-time container that initializes database schemas and Bronze tables using SQL scripts
- `load-bronze` - one-time container that loads sample CSV data into the Bronze layer
- `app` - Python application container used for sanity checks and manual script execution

The PostgreSQL database runs inside Docker, while VS Code can connect to it through the exposed host port.

---

## Environment Variables

The project uses environment variables stored in a local `.env` file.

Example values:

```env
POSTGRES_USER=your_user_placeholder
POSTGRES_PASSWORD=your_password_placeholder
POSTGRES_DB=analytics_db

DB_HOST=db
DB_PORT=5432
HOST_POSTGRES_PORT=5434

DATA_DIR=/app/00_raw_data
STATIONS_CSV=/app/00_raw_data/stations.csv
WEATHER_CSV=/app/00_raw_data/weather_sample.csv
```

Inside Docker Compose, Python connects to PostgreSQL using:

```text
db:5432
```

From the host machine, PostgreSQL can be accessed using:

```text
localhost:5434
```

---

## Running the Docker Pipeline

Start the Dockerized environment and run the Bronze pipeline:

```powershell
docker compose up -d --build
```

Check running services:

```powershell
docker compose ps
```

Check Bronze load logs:

```powershell
docker compose logs --tail=30 load-bronze
```

Stop the environment:

```powershell
docker compose down
```

---

## PostgreSQL Connection from VS Code

The PostgreSQL database can be accessed from VS Code using a PostgreSQL extension.

Connection settings:

```text
Host: localhost
Port: 5434
Database: analytics_db
User: postgres
Password: admin
SSL mode: Disable
```

Example validation queries:

```sql
SELECT COUNT(*)
FROM bronze.weather;

SELECT COUNT(*)
FROM bronze.stations;

SELECT *
FROM bronze.weather
LIMIT 10;
```

---

## Bronze Layer

The Bronze layer stores raw loaded data with minimal transformation.

Current Bronze tables:

- `bronze.weather`
- `bronze.stations`

The Docker Bronze load uses the sample weather dataset:

```text
00_raw_data/weather_sample.csv
```

This allows the project to be tested without loading the full NOAA dataset, which contains 422 million rows.

---

## Benchmarks

The project includes performance comparisons of:

- CSV vs Apache Parquet
- Pandas vs Polars
- Read and write performance
- Storage efficiency

The benchmarks were performed using the complete NOAA dataset (~422 million observations).

---

## Analysis

The analytical part of the project is intentionally limited.

Its purpose is to validate the processed dataset and demonstrate SQL queries and basic visualizations rather than perform comprehensive exploratory data analysis.

---

## Current Status

Completed:

- Raw data preparation
- Pandas and Polars performance comparison
- CSV vs Parquet benchmark
- PostgreSQL Bronze DDL
- Dockerfile for Python environment
- Docker Compose setup with PostgreSQL
- Automated database initialization
- Automated Bronze data load using sample data
- PostgreSQL connection from VS Code

In progress:

- Silver layer DDL
- Silver layer load
- Gold layer DDL
- Gold layer load
- Final SQL validation queries

---

## Future Improvements

- Complete automated Silver and Gold pipeline in Docker Compose
- Add `.env.example`
- Add stronger data quality checks
- Add Apache Airflow orchestration
- Add cloud storage integration
- Add more SQL analytics
- Add interactive dashboards

---

## License

This project is available under the MIT License.