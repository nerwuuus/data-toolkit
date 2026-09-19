/*
==============================================================================
Data Quality Script: Validate Weather Data Pipeline
==============================================================================

Script Purpose:
    This script contains data quality checks for the weather data pipeline.

    The checks are intended to validate data across the Bronze, Silver, and Gold
    layers and confirm that the pipeline not only runs successfully, but also
    produces complete, consistent, and reasonable analytical data.

    The script should be used to check:
        - row counts in key tables and views,
        - missing values in important columns,
        - duplicate weather observations,
        - expected date ranges,
        - realistic ranges for weather metric values,
        - station metadata coverage after joining observations with stations.

    These checks can be run manually during development and may later be added
    to Docker Compose as a separate data-quality service. In the future, they
    can also be orchestrated with Airflow as part of the full pipeline.

Pipeline Layers:
    Bronze:
        Raw loaded data from source files.

    Silver:
        Cleaned and standardized weather and station data.

    Gold:
        Analysis-ready weather observations enriched with station metadata.

Usage:
    Run this script after the Bronze, Silver, and Gold layers have been created
    and populated.

==============================================================================
*/
