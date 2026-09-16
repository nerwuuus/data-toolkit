# ============================================================================
# This script is a sample-data ETL (Extract, Transform, Load) process using
# psycopg2 to load a small weather dataset into PostgreSQL.
# ============================================================================
# Purpose:
#   This script is used for Docker Compose/PostgreSQL testing with sample data,
#   not for loading the full NOAA dataset.
#
#   It loads:
#     - weather_sample.csv into bronze.weather_sample
#     - stations into bronze.stations_sample
# ============================================================================
# In short:
#   try: Execute the sample ETL process.
#   except: Handle errors and undo changes with rollback().
#   finally: Always close database resources.
# ============================================================================
# PostgreSQL does not open the CSV file itself.
# Python opens the file and streams its contents to PostgreSQL
# through STDIN (standard input) using COPY.
# ============================================================================

# Importing libraries
import psycopg2
import time
import os

# Read database configuration from environment variables.
POSTGRES_USER = os.getenv('POSTGRES_USER')
POSTGRES_PASSWORD = os.getenv('POSTGRES_PASSWORD')
POSTGRES_DB = os.getenv('POSTGRES_DB')

DB_HOST = os.getenv('DB_HOST')
DB_PORT = os.getenv('DB_PORT')

# Read input file paths from environment variables.
DATA_DIR =  os.getenv('DATA_DIR')
STATIONS_CSV = os.getenv('STATIONS_CSV')
WEATHER_CSV = os.getenv('WEATHER_CSV')

# Set the counter
start_time = time.perf_counter()

# Define table names where data will be truncated and loaded
weather_table = "bronze.weather_sample"
stations_table = "bronze.stations_sample"

# Initialize database objects before the try block
# They remain None if the connection cannot be established
cur = None
conn = None

# try block contains a code that might raise an error
# If everything runs fine, the except block is skipped
try: 
    conn = psycopg2.connect( # Connecting to the PostgreSQL database
    host=DB_HOST,
    port=int(DB_PORT), # Convert DB_PORT from string to integer.
    dbname=POSTGRES_DB,
    user=POSTGRES_USER,
    password=POSTGRES_PASSWORD
)
    
    cur = conn.cursor()  # Creates a cursor object used to execute SQL statements
    print("Connected.")

    # Load the smaller station table first so formatting errors are detected
    # before starting the much larger weather data load
    print(f"Truncating table {stations_table}...")
    cur.execute(f"TRUNCATE TABLE {stations_table};")

    print(f"Starting COPY for {stations_table}...")
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
            COPY {stations_table}
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

    print(f"COPY for {stations_table} finished.")

    print(f"Truncating table {weather_table}...")
    cur.execute(f"TRUNCATE TABLE {weather_table};")

    print(f"Starting COPY for {weather_table}...")
    with open(
        WEATHER_CSV,
        "r",
        encoding="utf-8"
    ) as file:
        cur.copy_expert(
            f"""
            COPY {weather_table}
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

    print(f"COPY for {weather_table} finished. Committing transaction...")

    # Save all changes permanently
    conn.commit()
    print(f"Data was loaded successfully to the table {weather_table} and {stations_table}.")

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

# Always close the cursor and database connection,
# regardless of whether the ETL succeeded or failed
finally:
    if cur is not None:
        cur.close()
    if conn is not None:
        conn.close()
    print("Database connection closed.")
