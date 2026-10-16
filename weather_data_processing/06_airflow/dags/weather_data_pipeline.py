# Import libraries
from datetime import datetime, timedelta
from airflow.sdk import DAG
from airflow.providers.standard.operators.bash import BashOperator
from airflow.providers.common.sql.operators.sql import SQLExecuteQueryOperator

# Define default settings shared by all tasks in this DAG.
default_args = {
    'owner': 'Patryk',
    'retries': 5,
    'retry_delay': timedelta(minutes=2)
}

# Define or Instantiate DAG
with DAG(
    dag_id='weather_data_pipeline',
    default_args=default_args,
    description='Orchestrates the weather data pipeline from Staging ' \
                'through Bronze and Silver, including data quality checks.',
    start_date=datetime(2026, 10, 11, 8), # year, month, day, hour
    # schedule='@daily',
    catchup=False,
    template_searchpath=["/app/04_data_quality_checks_sql/automated_airflow_checks"]
) as dag:

    # Define Airflow tasks

    # Load raw source data into the Staging layer
    # Temporarily disabled during the full historical bootstrap
    # to avoid reloading the 15 GB source file.
    #
    # load_staging = BashOperator(
    #     task_id='load_staging',
    #     bash_command='python /app/01_scripts/4a_load_staging.py'
    # )

    # Load new records from Staging into the Bronze layer
    load_bronze = SQLExecuteQueryOperator(
        task_id='load_bronze',
        conn_id="analytics_db",
        sql="""
            CALL load_bronze();
        """
    )

    # Transform and load new records from Bronze into the Silver layer
    load_silver = SQLExecuteQueryOperator(
        task_id='load_silver',
        conn_id="analytics_db",
        sql="""
            CALL load_silver();
        """
    )

    # Execute automated data quality checks for the Bronze, Silver, and Gold layers.
    bronze_dq = SQLExecuteQueryOperator(
        task_id='bronze_dq',
        conn_id="analytics_db",
        sql='01_bronze_dq.sql'
    )
    
    silver_dq = SQLExecuteQueryOperator(
        task_id='silver_dq',
        conn_id="analytics_db",
        sql='02_silver_dq.sql'
    )

    gold_dq = SQLExecuteQueryOperator(
        task_id='gold_dq',
        conn_id="analytics_db",
        sql='03_gold_dq.sql'
    )

# load_staging >> load_bronze >> bronze_dq >> load_silver >> [silver_dq, gold_dq]

# Temporary dependency chain used during the full historical load.
load_bronze >> bronze_dq >> load_silver >> [silver_dq, gold_dq]
