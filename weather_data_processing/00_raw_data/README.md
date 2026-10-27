# Raw Data

This directory contains source files used by the weather data pipeline.

Large data files are excluded from version control through `.gitignore` because of their size. Only small sample files may be stored in the repository for development and testing.

## Data sources

### Station metadata

NOAA GHCN-D station metadata:

https://www.ncei.noaa.gov/pub/data/ghcn/daily/ghcnd-stations.txt

The file contains station identifiers, coordinates, elevation and station names.

### Weather observations

NOAA GHCN-Daily yearly weather observations:

https://www.ncei.noaa.gov/pub/data/ghcn/daily/by_year/

The pipeline downloads the current yearly dataset and processes only observations newer than the latest date already available in the Bronze layer.

## Local files

- `weather.csv` – current incremental weather batch
- `stations.csv` – current NOAA station metadata
- `weather_sample.csv` – small sample used for development and testing
