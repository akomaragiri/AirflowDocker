FROM puckel/docker-airflow

#RUN ["source", "venv/bin/activate"]
#RUN ["python", "setup.py", "sdist"]

USER root
RUN apt-get update; apt-get install vim -y
#COPY airflow.cfg ./airflow.cfg
COPY /dags ./dags

COPY entrypoint.sh /entrypoint.sh
COPY requirements.txt /requirements.txt


COPY src/ /usr/local/airflow/src/


# COPY dist/TestPythonProject-0.0.0.tar.gz /TestPythonProject-0.0.0.tar.gz

# Add directory in which pip installs to PATH
ENV PATH="/usr/local/airflow/.local/bin:${PATH}"
ENV DBGAP_INPUT_FILES=""
ENV DBGAP_OUTPUT_FILES=""
ENV PYTHONPATH="/usr/local/airflow/"
# ENV AIRFLOW__CLI__API_CLIENT=airflow.api.client.json_client

USER airflow

ENTRYPOINT ["/entrypoint.sh"]


# Just for documentation. Expose webserver, worker and flower respectively
EXPOSE 8080 8793 5555
