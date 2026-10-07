/*
==============================================================================
SQL Practice Script: Window Functions
==============================================================================

Script Purpose:
    This script is intended for practicing SQL window functions on the weather
    dataset.

    Window functions are used to calculate values across related rows without
    collapsing the result set like GROUP BY does. They are useful for rankings,
    running totals, moving averages, comparisons with previous rows, and
    station-level or time-based analysis.

    This script should be used to practice:
        - ROW_NUMBER(),
        - RANK() and DENSE_RANK(),
        - LAG() and LEAD(),
        - AVG() OVER(),
        - COUNT() OVER(),
        - running and rolling calculations,
        - partitioning by station, year, metric, or other dimensions.

Example Use Cases:
    - rank the warmest days by station,
    - compare daily temperature with the previous observation,
    - calculate average temperature per station without losing row-level detail,
    - calculate monthly or yearly rankings,
    - identify stations with the highest or lowest average temperatures.

Data Source:
    The exercises should use analysis-ready data from the Gold layer, especially:

        gold.weather_observations

    or another validated analytical table/view created from the Silver layer.

Usage:
    Run each query separately while learning and experimenting with SQL window
    functions. This script is for practice and learning, not for production data
    loading.

==============================================================================
*/
