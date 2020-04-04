from airflow import DAG
from airflow.operators.dummy_operator import DummyOperator
from airflow.operators.python_operator import PythonOperator

from src.test_project.process_files import my_func

from time import sleep
from datetime import datetime

import os

#files_in_dir = []
#location = '/usr/local/airflow/input_files'

#for r, d, f in os.walk(location):
#    for item in f:
#        if '.txt' in item:
#            print(item)
#            print(type(item))
#            files_in_dir.append(item)


with DAG('python_dag', description='Python DAG', schedule_interval=None, start_date=datetime(2018, 11, 1), catchup=False) as dag:
    dummy_task      = DummyOperator(task_id='dummy_task', retries=3)
    python_task     = PythonOperator(task_id='python_task', python_callable=my_func, op_args=[])
    
dummy_task >> python_task

#def main():
#    print("Hello World!")


#if __name__ == "__main__":
#    main()
