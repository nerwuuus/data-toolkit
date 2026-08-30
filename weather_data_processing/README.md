# Weather Data Processing

## Overview

Weather Data Processing is an end-to-end Data Engineering project built around the NOAA Global Historical Climatology Network Daily (GHCN-Daily) dataset.

The project demonstrates the complete data processing pipeline, starting from raw weather observations, through data preparation and transformation, to loading the processed data into PostgreSQL for analysis.

**The primary goal of this project is to practice Data Engineering concepts rather than perform extensive exploratory data analysis.**

---

## Dataset

- Source: NOAA Global Historical Climatology Network Daily (GHCN-Daily)
- Time period: 2015–2025
- Number of observations: ~422 million
- Number of weather stations: worldwide

---

## Project Objectives

- Process a large real-world dataset (~422 million observations)
- Compare CSV and Apache Parquet storage formats
- Compare Pandas and Polars performance
- Build a Bronze → Silver → Gold data pipeline
- Load processed data into PostgreSQL
- Perform basic analytical queries and visualizations using Seaborn
- Containerize the project using Docker

---

## Project Structure

```text
weather_data_processing/
├── 00_raw_data/        # Raw weather observations and metadata
├── 01_scripts/         # Data preparation notebooks, SQL scripts, benchmark results and ETL
├── 02_plots/           # Generated charts
├── 03_docker/          # Docker configuration
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
- Git
- GitHub
- Copilot

---

## Data Pipeline

```text
NOAA GHCN-Daily
        │
        ▼
Raw CSV Files
        │
        ▼
Data Preparation
(Pandas/Polars)
        │
        ▼
CSV/Apache Parquet
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
Pandas/Seaborn Analysis & Visualizations
```

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

Its purpose is to validate the processed dataset and demonstrate SQL queries rather than perform comprehensive exploratory data analysis.

---

## Future Improvements

- Dockerized environment
- Automated ETL pipeline
- Apache Airflow
- Cloud storage integration
- Additional SQL analytics
- Interactive dashboards

---

## License

This project is available under the MIT License.
