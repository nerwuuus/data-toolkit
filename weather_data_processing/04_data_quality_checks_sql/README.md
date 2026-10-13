# Automated Airflow Checks

This folder contains automated data quality checks executed by Airflow.

Unlike the manual DQ scripts in the parent folder, these checks are designed to return a clear pass/fail result. If invalid data is detected, the SQL raises an exception so the corresponding Airflow task fails.

This keeps:
- manual profiling and inspection separate from automation,
- DQ logic outside the DAG file,
- Airflow responsible only for orchestration and task status.