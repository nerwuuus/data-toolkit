### Station data 
https://www.ncei.noaa.gov/pub/data/ghcn/daily/ghcnd-stations.csv

### Weather data 
https://www.ncei.noaa.gov/pub/data/ghcn/daily/by_year/

Loaded approximately 388 million weather observations from a 14 GB CSV file into PostgreSQL using psycopg2 and COPY FROM STDIN in approximately 82 minutes on a local machine.
