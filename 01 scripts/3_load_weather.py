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

# Importing the psycopg2 library
import psycopg2
import time

start_time = time.perf_counter()

# Define table names where data will be truncated and loaded
table_name = "weather_bronze"

conn = None

try: # try block contains a code that might raise an error. If everything runs fine, the except block is skipped
    # Connecting to the PostgreSQL database
    print("Connecting...")
    conn = psycopg2.connect(
        host="localhost", # Server
        port=5432,
        dbname="analytics_db",
        user="postgres",
        password="admin"
    )
    cur = conn.cursor()  # Creates a cursor object to execute PostgreSQL commands
    print("Connected.")

    # Truncating and loading data into weather_bronze
    print(f"Truncating table {table_name}...")
    cur.execute(f"TRUNCATE TABLE {table_name};")
    print("Table truncated.")

    print("Starting COPY...")
    with open(r"C:\Users\zychl\Desktop\Data Engineering\weather_data_processing\00 raw\weather.csv", "r", encoding="utf-8") as f:
        cur.copy_expert(f"""
            COPY {table_name}
            FROM STDIN
            WITH (
                FORMAT csv,
                HEADER true,
                DELIMITER ',',
                ENCODING 'UTF8'
            )
        """, f)
   
    # Committing changes to the analytics_db database
    conn.commit()
    print(f"Data was loaded successfully to the tables {table_name}.")
    
    elapsed = time.perf_counter() - start_time
    print(f"Load completed in {elapsed / 60:.2f} minutes.")
    
except Exception as e: # Executes only if an error occurs inside the try block and captures the error details in the variable e
    # If something goes wrong before commit(), calling rollback() undoes all changes made in the current transaction, restoring the database to its previous state
    if conn:
        conn.rollback()
    print("An error occurred during the data load process:", e)

finally: # this block runs no matter what happens (success or error)
    # Closing the cursor and connection
    if 'cur' in locals():
        cur.close()
    if 'conn' in locals():
        conn.close()
