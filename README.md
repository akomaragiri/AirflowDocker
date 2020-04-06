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
```

## Installation
```sh
Activate Python Virtual Env:

** For Unix Based Systems:
virtualenv -p python3.7 venv && source venv/bin/activate 

** For Windows:
virtualenv -p python3.7 venv && venv/scripts/activate
```

```sh
python setup.py sdist
docker build --tag airflow_docker:1.0 .
docker-compose -f docker-compose-CeleryExecutor.yml up -d
```

## Execution
```
Open Airflow UI: http://<server_ip>:8080/admin/
Toggle switch to enable/start the DAG
```

#####Happy Path:
```
Copy a sample text (.TXT) file to input_files directory
Trigger DAG
Check output_files directory once DAG has finished
```

#####Un-happy Path:
```
Copy a sample non TXT file to input_files directory
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
