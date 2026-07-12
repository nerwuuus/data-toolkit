# ============================================================================
# This script is a Python ETL (Extract, Transform, Load) process using 
# the psycopg2 library to interact with a PostgreSQL database.
# ============================================================================
# First time run:
#   1) Open PowerShell and download psycopg2: pip install psycopg2.
#   2) Run the below script here or in PowerShell: python "C:\Users\zychl\Desktop\Data Engineering\weather_data_processing\01 scripts\3_load_weather.py"
# ============================================================================
# In short:
#   try: → Attempt the main logic.
#   except: → Handle errors and undo changes with rollback().
#   finally: → Close database resources safely.
# ============================================================================ 

# Importing libraries
import psycopg2
import time

# Set the counter
start_time = time.perf_counter()

# Define table names where data will be truncated and loaded
weather_table = "weather_bronze"
stations_table = "stations_bronze"

cur = None
conn = None

# try block contains a code that might raise an error. If everything runs fine, the except block is skipped
try: 
    print("Connecting...")
    conn = psycopg2.connect( # Connecting to the PostgreSQL database
        host="localhost", # Server
        port=5432,
        dbname="analytics_db",
        user="postgres",
        password="admin"
    )

    cur = conn.cursor()  # Creates a cursor object to execute PostgreSQL commands
    print("Connected.")

    # Load the smaller station table first so formatting errors are detected
    # before starting the much larger weather data load.
    print(f"Truncating table {stations_table}...")
    cur.execute(f"TRUNCATE TABLE {stations_table};")

    print(f"Starting COPY for {stations_table}...")
    with open(
        r"C:\Users\zychl\Desktop\Data Engineering\weather_data_processing\00 raw\ghcnd-stations.csv",
        "r",
        encoding="utf-8"
    ) as file:
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
        r"C:\Users\zychl\Desktop\Data Engineering\weather_data_processing\00 raw\weather.csv",
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

    # Committing changes to the analytics_db database
    conn.commit()
    print(f"Data was loaded successfully to the table {weather_table} and {stations_table}.")

    # Print the load time
    elapsed = time.perf_counter() - start_time
    print(f"Load completed in {elapsed / 60:.2f} minutes.")

# Executes only if an error occurs inside the try block and captures the error details in the variable e.
# If something goes wrong before commit(), calling rollback() undoes all changes made in the current transaction, 
# restoring the database to its previous state. 
except Exception as e: 
    if conn is not None:
        conn.rollback()
    print("An error occurred during the data load process:", e)

# This block runs no matter what happens (success or error)
# Closing the cursor and connection
finally:
    if cur is not None:
        cur.close()
    if conn is not None:
        conn.close()
    print("Database connection closed.")
