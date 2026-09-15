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

cur.execute(""" \
    "SELECT * " \
    "FROM docker_test " \
    "ORDER BY id;"
""")

# Fetch all rows from the query result and
# display the result in the terminal
rows = cur.fetchall()
print(rows)

cur.close()
conn.close()
