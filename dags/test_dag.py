from airflow import DAG
from datetime import datetime

from airflow.operators.dummy_operator import DummyOperator
from airflow.operators.python_operator import PythonOperator

from src.test_project.process_files import process_files
import json

class SandboxSubmission(DAG):

    def __init__(self):
        '''
        Set up the DAG.
        '''
        self.input_dir = '{{ dag_run.conf.input_dir }}'
        self.output_dir = '{{ dag_run.conf.output_dir }}'
        self.dag_id = "TestDag"

        self.input_output_dict = {
            'input_dir': self.input_dir,
            'output_dir': self.output_dir
        }

        self.default_args = {
            'depends_on_past': False,
            'start_date': datetime(2018, 11, 1),
            'email_on_failure': False,
            'email_on_retry': False,
            'retries': 0
        }

        super(SandboxSubmission, self).__init__(
            dag_id=self.dag_id,
            default_args=self.default_args,
            catchup=False,
            schedule_interval=None
        )

    def CreateDag(self):
        dummy_task = DummyOperator(task_id='dummy_task_1', retries=3, dag=self)
        python_task = PythonOperator(task_id='python_task_1', python_callable=process_files, op_kwargs=self.input_output_dict, dag=self)

        dummy_task >> python_task

        return self


DAG = SandboxSubmission().CreateDag()
