#!/usr/bin/env python

import argparse
import json
import os
import pprint
import requests
import sys
import subprocess
import datetime

kDagId = 'SandboxSubmission'


parser = argparse.ArgumentParser(
    description='Entrypoint for user to run workflow.')

group = parser.add_mutually_exclusive_group()

group.add_argument('--host_port',
                   help='If testing out an AdHoc instance (not one of the available domains) '
                        'specify here the host/port string provided by the developer.  Like: '
                        '--host_port iebdev23:8083')
parser.add_argument('-r', '--study_root',
                    type=str,
                    required=True,
                    help='The full input path to the study')
parser.add_argument('-o', '--output_root',
                    type=str,
                    required=True,
                    help='The path to write outputs')
parser.add_argument('-m', '--manifest_file_path',
                    type=str,
                    required=True,
                    help='The full path to manifest file'),
parser.add_argument('-s', '--study_name',
                    type=str,
                    required=True,
                    help='The name of the study, like NICHD/Foo_v1')

args = parser.parse_args()

payload = {
    'base_run_id': "NXYZ/user_Study1",
    'study_name': args.study_name,
    'study_root': args.study_root,
    'output_root': args.output_root,
    'external_user': True,
    'manifest_file_path': args.manifest_file_path
}

orig_stderr = sys.stderr
sys.stderr = open(os.devnull, 'w')

cur_date = datetime.datetime.today()
dt_str = '{:%m/%d/%y %H:%M %S}'.format(cur_date)

cmd = ['airflow', 'trigger_dag', kDagId, '-c', json.dumps(payload), '-r', dt_str]
subprocess.check_call(cmd)

sys.stderr = orig_stderr

print("\nSuccessfully triggered {} DAG.\n".format(kDagId))
