import psycopg2

conn = psycopg2.connect(
    host="host.docker.internal",
    port=5433,
    dbname="analytics_db",
    user="postgres",
    password="admin"
)

cur = conn.cursor()
print("Connected.")

cur.execute(
    "SELECT * FROM test;"
)
