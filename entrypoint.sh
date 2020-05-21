#!/usr/bin/env bash

: "${REDIS_HOST:="redis"}"
: "${REDIS_PORT:="6379"}"
: "${REDIS_PASSWORD:=""}"

: "${POSTGRES_HOST:="postgres"}"
: "${POSTGRES_PORT:="5432"}"
: "${POSTGRES_USER:="airflow"}"
: "${POSTGRES_PASSWORD:="airflow"}"
: "${POSTGRES_DB:="airflow"}"

# Defaults and back-compat
: "${AIRFLOW_HOME:="/usr/local/airflow"}"
: "${AIRFLOW__CORE__FERNET_KEY:=${FERNET_KEY:=$(python -c "from cryptography.fernet import Fernet; FERNET_KEY = Fernet.generate_key().decode(); print(FERNET_KEY)")}}"
: "${AIRFLOW__CORE__EXECUTOR:=${EXECUTOR:-Celery}Executor}"

AIRFLOW__CORE__SQL_ALCHEMY_CONN="postgresql+psycopg2://$POSTGRES_USER:$POSTGRES_PASSWORD@$POSTGRES_HOST:$POSTGRES_PORT/$POSTGRES_DB"
AIRFLOW__CELERY__RESULT_BACKEND="db+postgresql://$POSTGRES_USER:$POSTGRES_PASSWORD@$POSTGRES_HOST:$POSTGRES_PORT/$POSTGRES_DB"


# Load DAGs examples (default: Yes)
if [[ -z "$AIRFLOW__CORE__LOAD_EXAMPLES" && "${LOAD_EX:=n}" == n ]]
then
	AIRFLOW__CORE__LOAD_EXAMPLES=False
fi

if [[ -n "$REDIS_PASSWORD" ]]; then
	REDIS_PREFIX=:${REDIS_PASSWORD}@
else
	REDIS_PREFIX=
fi

AIRFLOW__CELERY__BROKER_URL="redis://$REDIS_PREFIX$REDIS_HOST:$REDIS_PORT/1"

export \
	AIRFLOW_HOME \
	AIRFLOW__CELERY__BROKER_URL \
	AIRFLOW__CELERY__RESULT_BACKEND \
	AIRFLOW__CORE__EXECUTOR \
	AIRFLOW__CORE__FERNET_KEY \
	AIRFLOW__CORE__LOAD_EXAMPLES \
	AIRFLOW__CORE__SQL_ALCHEMY_CONN

case "$1" in
       	webserver)
       	if [[ -e "/requirements.txt" ]]; then
			pip install --user --upgrade -r /requirements.txt
			pip install --user /TestPythonProject-0.0.tar.gz
#			pip3 install --user /dbGaP-meta-package-1.2.14.post150+8d0a427.tar.gz
			pip install --user /ncbi-mgv-utils-1.4.0.tar.gz
			pip install --user /mgv_package_and_distribute-3.1.6.tar.gz
			pip install --user /airflow-utils-7.0.2.tar.gz
			pip install --user /sge_farm_management-2.2.0.tar.gz
			pip install --user /airflow-adhoc-4.0.0.tar.gz
			pip install --user /Submission_Processing.tar.gz
		fi
		cp -R /usr/local/airflow/.local/dags/ /usr/local/airflow/dags
		cp -R /usr/local/airflow/.local/plugins/ /usr/local/airflow/plugins
		airflow initdb
		exec airflow webserver
		;;
	scheduler)
	    if [[ -e "/requirements.txt" ]]; then
			pip install --user --upgrade -r /requirements.txt
			pip install --user /TestPythonProject-0.0.tar.gz
#			pip3 install --user /dbGaP-meta-package-1.2.14.post150+8d0a427.tar.gz
			pip install --user /ncbi-mgv-utils-1.4.0.tar.gz
			pip install --user /mgv_package_and_distribute-3.1.6.tar.gz
			pip install --user /airflow-utils-7.0.2.tar.gz
			pip install --user /sge_farm_management-2.2.0.tar.gz
			pip install --user /airflow-adhoc-4.0.0.tar.gz
			pip install --user /Submission_Processing.tar.gz
		fi
		cp -R /usr/local/airflow/.local/dags/ /usr/local/airflow/dags
		cp -R /usr/local/airflow/.local/plugins/ /usr/local/airflow/plugins
		exec airflow scheduler
		;;
	flower|version)
	    exec airflow "$@"
		;;
    worker)
        if [[ -e "/requirements.txt" ]]; then
			pip install --user --upgrade -r /requirements.txt
			pip install --user /TestPythonProject-0.0.tar.gz
#			pip3 install --user /dbGaP-meta-package-1.2.14.post150+8d0a427.tar.gz
			pip install --user /ncbi-mgv-utils-1.4.0.tar.gz
			pip install --user /mgv_package_and_distribute-3.1.6.tar.gz
			pip install --user /airflow-utils-7.0.2.tar.gz
			pip install --user /sge_farm_management-2.2.0.tar.gz
			pip install --user /airflow-adhoc-4.0.0.tar.gz
			pip install --user /Submission_Processing.tar.gz
		fi
		cp -R /usr/local/airflow/.local/dags/ /usr/local/airflow/dags
		cp -R /usr/local/airflow/.local/plugins/ /usr/local/airflow/plugins
		exec airflow "$@"
		;;
	*)
		# The command is something like bash, not an airflow subcommand. Just run it in the right environment.
		exec "$@"
		;;
esac
