FROM puckel/docker-airflow

USER root

#COPY airflow.cfg ./airflow.cfg
COPY /dags ./dags

COPY entrypoint.sh /entrypoint.sh
COPY requirements.txt /requirements.txt
COPY dist/TestPythonProject-0.0.tar.gz /TestPythonProject-0.0.tar.gz

# Add directory in which pip installs to PATH
ENV PATH="/usr/local/airflow/.local/bin:${PATH}"

USER airflow

ENTRYPOINT ["/entrypoint.sh"]

# Just for documentation. Expose webserver, worker and flower respectively
EXPOSE 8080 8793 5555 5432