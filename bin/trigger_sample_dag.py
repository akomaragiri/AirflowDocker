#!/usr/bin/env python

import argparse
import json
import os
import pprint
import requests
import sys
import subprocess
import datetime

kDagId = 'TestDag'


parser = argparse.ArgumentParser(
    description='Entrypoint for users to trigger a DAG')

group = parser.add_mutually_exclusive_group()

parser.add_argument('-r', '--input_dir',
                    type=str,
                    help='Input directory')
parser.add_argument('-o', '--output_dir',
                    type=str,
                    help='Output directory')

args = parser.parse_args()

payload = {
    'input_dir': args.input_dir,
    'output_dir': args.output_dir
}

orig_stderr = sys.stderr
sys.stderr = open(os.devnull, 'w')

cur_date = datetime.datetime.today()
dt_str = '{:%m/%d/%y %H:%M %S}'.format(cur_date)

cmd = ['airflow', 'trigger_dag', kDagId, '-c', json.dumps(payload), '-r', dt_str]
subprocess.check_call(cmd)

sys.stderr = orig_stderr

print("\nSuccessfully triggered {} DAG.\n".format(kDagId))
