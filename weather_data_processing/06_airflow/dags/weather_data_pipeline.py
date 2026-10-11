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
    schedule='@daily',
    catchup=False
) as dag:

    # Define or Instantiate Tasks

    load_staging = BashOperator(
        task_id='load_staging',
        bash_command='python /app/01_scripts/4a_load_staging.py'
    )

    load_bronze = SQLExecuteQueryOperator(
        task_id='load_bronze',
        bash_command=''
    )

                sql_operator_name = SQLExecuteQueryOperator(
                    task_id="sql_operator_name",
                    conn_id="postgres",
                        sql="""
                            CREATE TABLE IF NOT EXISTS table_name (
                                field_one TEXT NOT NULL,
                                field_two TEXT NOT NULL,
                                    :
                                field_n TEXT NOT NULL
                            );
                        """,
                    dag=dag_name,
                )



# Define task dependencies
load_staging >> load_bronze


