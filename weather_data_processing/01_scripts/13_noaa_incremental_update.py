# Placeholder for a future scheduled NOAA 2026/2027 update pipeline.
# Current-year data is incomplete and should stay outside the main 2015–2025 analysis dataset.
# The goal is to download NOAA 2026/2027 data on a regular schedule and load it into a separate test table.

# Key questions to revisit later:
# - Should the pipeline run weekly or monthly?
# - Should the 2026 table be fully replaced on each run or loaded incrementally?
# - What should be the unique key for deduplication? Probably: station + observation_date + metric.
# - How should already existing records be handled?
# - Should raw downloaded files be versioned/snapshotted or overwritten?
# - Should the pipeline keep only Polish stations and selected metrics before loading?
# - Should data quality checks be run before inserting data into the test table?
# - Should failed downloads or partial NOAA files stop the pipeline?
# - Should this be implemented as a standalone script first or directly as an Airflow DAG?
# - How should this test table eventually relate to the main bronze/silver/gold pipeline?

# ======================================================================
# Import libraries
import os
from dotenv import load_dotenv
from sqlalchemy import create_engine
from pathlib import Path
import pandas as pd
import polars as pl

# analytics_db connection
# Define project paths and load local database credentials from the .env file
PROJECT_PATH = Path(
    r"C:\Users\zychl\Documents\GitHub\data-toolkit\weather_data_processing"
)

load_dotenv(PROJECT_PATH / ".env") 

# PostgreSQL connection details
username = os.getenv('POSTGRES_USER')
password = os.getenv('POSTGRES_PASSWORD')
host = 'localhost'
port = os.getenv('HOST_POSTGRES_PORT')
database = os.getenv('POSTGRES_DB')

engine = create_engine(
    f'postgresql+pg8000://{username}:{password}@{host}:{port}/{database}'
    )

# Fetch the data from PostgreSQL analytics_db server - bronze layer
print('Executing query...')

bronze_observation_date = pd.read_sql(
    'SELECT MAX(observation_date) AS max_observation_date ' \
    'FROM bronze.weather',
    con=engine
    )

print(f'Executing query finished. The result is {bronze_observation_date}')

