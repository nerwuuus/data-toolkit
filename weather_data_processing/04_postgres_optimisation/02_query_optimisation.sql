/*
==============================================================================
Query Optimisation Tests
==============================================================================

Purpose:

    This script contains experiments aimed at improving the performance of
    expensive PostgreSQL queries identified during query plan analysis.

    Each test should change one thing at a time and compare:
        - The query plan
        - Estimated cost
        - Execution time
        - The amount of data processed.

    The current baseline is the duplicate check on bronze.weather,
    which takes around 45 minutes on the full raw dataset.

    Index experiments are kept in a separate script.

==============================================================================
*/

















