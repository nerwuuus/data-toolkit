# This script is a simple connection test between Python and PostgreSQL running in Docker.
# It connects to the analytics_db database, queries the test table, and prints the result.
import psycopg2

conn = psycopg2.connect(
    host="db",
    port=5432,
    dbname="analytics_db",
    user="postgres",
    password="admin"
)

# Placeholder

cur = conn.cursor()
print("Connected.")

# Execute the SQL query. Doesn't print anything in the console.
cur.execute(
    "SELECT current_database();"
)

# Fetch all rows from the query result and
# display the result in the terminal
rows = cur.fetchall()
print(rows)

cur.close()
conn.close()
