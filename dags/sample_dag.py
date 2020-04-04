from airflow import DAG
from airflow.operators.dummy_operator import DummyOperator
from airflow.operators.python_operator import PythonOperator

from src.test_project.process_files import process_files

from datetime import datetime

with DAG('python_dag', description='Python DAG', schedule_interval=None, start_date=datetime(2018, 11, 1), catchup=False) as dag:
    dummy_task      = DummyOperator(task_id='dummy_task', retries=3)
    python_task     = PythonOperator(task_id='python_task', python_callable=process_files, op_args=[])
    
dummy_task >> python_task