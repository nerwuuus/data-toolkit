# ======================================================================
# Connect to PostgreSQL and get the latest Bronze observation date
# ======================================================================

# Import libraries
import os
from dotenv import load_dotenv
from sqlalchemy import create_engine
from pathlib import Path
import polars as pl

# Define project paths and load local database credentials from the .env file
PROJECT_PATH = Path('/app')

EXPORT_PATH = PROJECT_PATH / '00_raw_data'

WEATHER_CSV = EXPORT_PATH / 'weather.csv'
STATIONS_CSV = EXPORT_PATH / 'stations.csv'

load_dotenv(PROJECT_PATH / ".env") 

# PostgreSQL connection details
DB_HOST = os.getenv('DB_HOST')
DB_PORT = os.getenv('DB_PORT')
POSTGRES_DB = os.getenv('POSTGRES_DB')
POSTGRES_USER = os.getenv('POSTGRES_USER')
POSTGRES_PASSWORD = os.getenv('POSTGRES_PASSWORD')

engine = create_engine(
    f'postgresql+pg8000://{POSTGRES_USER}:{POSTGRES_PASSWORD}@{DB_HOST}:{DB_PORT}/{POSTGRES_DB}'
    )

print('Connected.')

# Fetch the latest observation date currently available in the Bronze layer
print("Fetching latest Bronze observation date...")

bronze_max_date = pl.read_database(
    query=
    'SELECT MAX(observation_date) AS max_observation_date '
    'FROM bronze.weather',
    connection=engine
)

bronze_max_date = bronze_max_date['max_observation_date'][0]

print(f"Latest Bronze observation date: {bronze_max_date}")

# ======================================================================
# Download and prepare the latest NOAA weather data
# ======================================================================

from datetime import datetime

current_year = datetime.now().year

weather_url = f"https://www.ncei.noaa.gov/pub/data/ghcn/daily/by_year/{current_year}.csv.gz"

print(f"Downloading NOAA weather data for {current_year}...")

noaa_weather_raw = pl.read_csv(
    weather_url,
    has_header=False
    )

print("NOAA weather data downloaded.")

# Rename source columns
print("Renaming NOAA weather columns...")

noaa_weather = noaa_weather_raw.rename({
    "column_1": "station",
    "column_2": "observation_date",
    "column_3": "metric",
    "column_4": "value",
    "column_5": "measurement_flag",
    "column_6": "quality_flag",
    "column_7": "source_flag",
    "column_8": "observation_time"
})

# Convert observation_date to Date
print("Converting observation_date to Date...")

noaa_weather = noaa_weather.with_columns(
    pl.col('observation_date')
    .cast(pl.String)
    .str.strptime(pl.Date, '%Y%m%d')
)

print("NOAA weather data preparation completed.")

# ======================================================================
# Filter new NOAA weather observations and save the incremental batch
# as an intermediate CSV file
# ======================================================================

print("Filtering new weather observations...")

noaa_weather_incremental = noaa_weather.filter(
    pl.col('observation_date') > bronze_max_date
)

print(f"Incremental batch contains {noaa_weather_incremental.height} rows.")

print("Exporting incremental weather batch...")

noaa_weather_incremental.write_csv(WEATHER_CSV)

print(f"Incremental weather batch saved in {WEATHER_CSV}")

# ======================================================================
# Download and prepare NOAA station metadata
# ======================================================================

import pandas as pd

stations_url = "https://www.ncei.noaa.gov/pub/data/ghcn/daily/ghcnd-stations.txt"

print(f"Downloading NOAA station metadata...")

pandas_stations = pd.read_fwf( # Fixed-width formatted file
    stations_url,
    # Read the fixed-width station metadata file using column positions
    # defined in the NOAA GHCN-D file specification.
    colspecs=[
        (0, 11),
        (12, 20),
        (21, 30),
        (31, 37),
        (38, 40),
        (41, 71),
        (72, 75),
        (76, 79),
        (80, 85)
    ],
    names=[
        "station",
        "latitude",
        "longitude",
        "elevation",
        "state",
        "station_name",
        "gsn_flag",
        "hcn_flag",
        "wmo_id"
    ]
)

stations = pl.from_pandas(pandas_stations)

print("NOAA station metadata preparation completed.")

# ======================================================================
# Save NOAA station metadata as an intermediate CSV file
# ======================================================================

print(f"NOAA station metadata contains {stations.height} rows.")

print("Exporting NOAA station metadata...")

stations.write_csv(STATIONS_CSV)

print(f"NOAA stations metadata saved in {STATIONS_CSV}")

# ======================================================================
# Load the incremental NOAA batch into PostgreSQL Staging using COPY
# ======================================================================

import psycopg2
import time
import traceback

# Set the counter
start_time = time.perf_counter()

# Define table names where data will be truncated and loaded
staging_weather = "staging.weather"
staging_stations = "staging.stations"

# Initialize database objects before the try block
# They remain None if the connection cannot be established
cur = None
conn = None

print("Starting incremental data load into PostgreSQL Staging...")

try: 
    conn = psycopg2.connect(
        host=DB_HOST,
        port=int(DB_PORT),
        dbname=POSTGRES_DB,
        user=POSTGRES_USER,
        password=POSTGRES_PASSWORD
)
    # Create cursor object used to execute SQL statements
    cur = conn.cursor()
    print("Connected.")

    print(f"Truncating table {staging_stations}...")
    cur.execute(f"TRUNCATE TABLE {staging_stations};")
 
    print(f"Starting COPY for {staging_stations}...")

    with open( 
        STATIONS_CSV,
        "r",
        encoding="utf-8"
    ) as file:
        # cur.copy_expert(sql_query, file)
        cur.copy_expert( 
            f"""
            COPY {staging_stations}  (
                station,
                latitude,
                longitude,
                elevation,
                state,
                station_name,
                gsn_flag,
                hcn_flag,
                wmo_id
            )
            FROM STDIN
            WITH (
                FORMAT csv,
                HEADER true,
                DELIMITER ',',
                ENCODING 'UTF8'
            )
            """,
            file
        )

    print(f"COPY for {staging_stations} finished.")

    print(f"Truncating table {staging_weather}...")
    cur.execute(f"TRUNCATE TABLE {staging_weather};")

    print(f"Starting COPY for {staging_weather}...")
    with open(
        WEATHER_CSV,
        "r",
        encoding="utf-8"
    ) as file:
        cur.copy_expert(
            f"""
            COPY {staging_weather} (
                station,
                observation_date,
                metric,
                value,
                measurement_flag,
                quality_flag,
                source_flag,
                observation_time
            )
            FROM STDIN
            WITH (
                FORMAT csv,
                HEADER true,
                DELIMITER ',',
                ENCODING 'UTF8'
            )
            """,
            file
        )

    print(f"COPY for {staging_weather} finished. Committing transaction...")

    # Save all changes permanently
    conn.commit()
    # print(f"Data was loaded successfully to the table {staging_weather} and {staging_stations}.")

    elapsed = time.perf_counter() - start_time
    print(f"Load completed in {elapsed / 60:.2f} minutes.")

except Exception as e: 
    if conn is not None:
        conn.rollback()
    print("An error occurred during the data load process:", e)
    traceback.print_exc()

finally:
    if cur is not None:
        cur.close()
    if conn is not None:
        conn.close()
    print("Database connection closed.")
