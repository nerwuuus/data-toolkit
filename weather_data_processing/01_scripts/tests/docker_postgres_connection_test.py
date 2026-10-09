# This script is a Docker Compose sanity check for the Python app and PostgreSQL database.
# It connects to analytics_db, creates a test table, inserts sample data, reads it back, and prints the result.

import os
import psycopg2

# Read database configuration from environment variables.
POSTGRES_USER = os.getenv('POSTGRES_USER')
POSTGRES_PASSWORD = os.getenv('POSTGRES_PASSWORD')
POSTGRES_DB = os.getenv('POSTGRES_DB')

DB_HOST = os.getenv('DB_HOST')
DB_PORT = os.getenv('DB_PORT')

conn = psycopg2.connect(
    host=DB_HOST,
    port=int(DB_PORT), # Convert DB_PORT from string to integer.
    dbname=POSTGRES_DB,
    user=POSTGRES_USER,
    password=POSTGRES_PASSWORD
)

cur = conn.cursor()
print("Connected.")

# Execute the SQL query. Doesn't print anything in the console.
cur.execute("DROP TABLE IF EXISTS docker_test;")

cur.execute("""
    CREATE TABLE docker_test (
        id INTEGER,
        name TEXT
    );
""")

cur.execute("""
    INSERT INTO docker_test (id, name)
    VALUES
        (1, 'Python'),
        (2, 'PostgreSQL');
""")

conn.commit()

cur.execute("""
    SELECT *
    FROM docker_test
    ORDER BY id;
""")

# Fetch all rows from the query result and
# display the result in the terminal
rows = cur.fetchall()
print(rows)

cur.close()
conn.close()
