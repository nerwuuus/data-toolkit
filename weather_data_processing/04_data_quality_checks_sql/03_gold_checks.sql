/*
==============================================================================
Data Quality Checks: Gold Layer
==============================================================================
Script Purpose:
    This script contains data quality checks for the Gold layer of the
    weather data pipeline.
    The checks are intended to validate analysis-ready weather data enriched
    with station metadata and confirm that joins and final transformations
    produced complete and consistent results.

    The script should be used to check:
        - Row counts in Gold tables and views
        - Missing values in important columns
        - Duplicate analytical records
        - Expected observation date ranges
        - Station metadata coverage after joins
        - Data completeness after Silver-to-Gold transformations
        - Consistency of final analytical output

Gold Layer:
    Analysis-ready weather observations enriched with station metadata and
    prepared for reporting and further analysis.

Usage:
    Run this script after the Gold layer has been created and populated.
==============================================================================
*/






