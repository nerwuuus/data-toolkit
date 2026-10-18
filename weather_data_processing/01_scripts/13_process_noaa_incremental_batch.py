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

WEATHER_EXPORT = EXPORT_PATH / 'weather.csv'
STATIONS_EXPORT = EXPORT_PATH / 'stations.csv'

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
# Get and prepare the latest weather data from NOAA
# ======================================================================

from datetime import datetime

current_year = datetime.now().year

url = f"https://www.ncei.noaa.gov/pub/data/ghcn/daily/by_year/{current_year}.csv.gz"

print(f"Downloading NOAA weather data for {current_year}...")

noaa_weather_raw = pl.read_csv(
    url,
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

print(f"Incremental batch contains {noaa_weather.height} rows.")

print("Exporting incremental weather batch...")

noaa_weather.write_csv(WEATHER_EXPORT)

print(f"Incremental weather batch saved in {WEATHER_EXPORT}")

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

# try block contains a code that might raise an error
# If everything runs fine, the except block is skipped
try: 
    conn = psycopg2.connect(
        host=DB_HOST,
        port=int(DB_PORT),
        dbname=POSTGRES_DB,
        user=POSTGRES_USER,
        password=POSTGRES_PASSWORD
)
    
    cur = conn.cursor()  # Creates a cursor object used to execute SQL statements
    print("Connected.")

    # Load the smaller station table first so formatting errors are detected
    # before starting the much larger weather data load
    print(f"Truncating table {staging_stations}...")
    cur.execute(f"TRUNCATE TABLE {staging_stations};")

    print(f"Starting COPY for {staging_stations}...")
    # Open the CSV file in read mode.
    # The file object will be used as the data source for COPY
    with open( 
        STATIONS_CSV,
        "r",
        encoding="utf-8"
    ) as file:
        # Execute the PostgreSQL COPY command
        # Data is streamed from the opened file through STDIN
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
    print(f"Data was loaded successfully to the table {staging_weather} and {staging_stations}.")

    # Convert the elapsed time from seconds to minutes and display it
    # with two decimal places
    elapsed = time.perf_counter() - start_time
    print(f"Load completed in {elapsed / 60:.2f} minutes.")

# Executes only if an error occurs inside the try block and captures the error details in the variable e. 
# If something goes wrong before commit(), calling rollback() undoes all changes made in the current 
# transaction, restoring the database to its previous state. 
except Exception as e: 
    if conn is not None:
        conn.rollback()
    print("An error occurred during the data load process:", e)
    traceback.print_exc()

# Always close the cursor and database connection,
# regardless of whether the ETL succeeded or failed
finally:
    if cur is not None:
        cur.close()
    if conn is not None:
        conn.close()
    print("Database connection closed.")
