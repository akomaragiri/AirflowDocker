# AirflowDocker

## Pre-requisites:
```
Docker
Docker-Compose
Python>=3.7
Virtualenv
```

## Setup
```sh
git clone https://github.com/akomaragiri/AirflowDocker.git
cd AirflowDocker
mkdir input_files
mkdir output_files
virtualenv -p python3.7 venv && source venv/bin/activate
```

## Installation
```sh
python setup.py sdist
docker build --tag airflow_docker:1.0 .
docker-compose -f docker-compose-CeleryExecutor.yml up -d
```

## Execution
```
Copy a sample txt file to input_files directory
Open Airflow UI: http://<server_ip>:8080/admin/
Trigger DAG
Check output_files directory once DAG has finished
```

## Stop Docker Containers
```sh
docker-compose -f docker-compose-CeleryExecutor.yml stop
```

## To Scale Up Airflow Workers
```sh
docker-compose -f docker-compose-CeleryExecutor.yml up -d --scale worker=5
```
