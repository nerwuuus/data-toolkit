# Import libraries
from datetime import datetime, timedelta
from airflow.sdk import DAG
from airflow.providers.standard.operators.bash import BashOperator

# Define default settings shared by all tasks in this DAG.
default_args = {
    'owner': 'Patryk',
    'retries': 5,
    'retry_delay': timedelta(minutes=2)
}

# Define or Instantiate DAG
dag = DAG(
    dag_id='weather_data_pipeline',
    default_args=default_args,
    description='Orchestrates the weather data pipeline from Staging ' \
                'through Bronze and Silver, including data quality checks.',
    start_date=datetime(2026, 10, 11, 8), # year, month, day, hour
    schedule='@daily',
    catchup=False
)

# Define or Instantiate Tasks
load_staging = BashOperator(
    task_id='load_staging',
    bash_command='python /app/01_scripts/4a_load_staging.py'
)

# Define task dependencies
print_welcome_task


