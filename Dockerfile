FROM puckel/docker-airflow

USER root

# required for installing pyodbc inside container
RUN apt-get update -y
RUN apt-get install g++ -y
RUN apt-get install unixodbc-dev -y
RUN apt-get install vim -y

#COPY airflow.cfg ./airflow.cfg
COPY /dags ./dags

COPY entrypoint.sh /entrypoint.sh
COPY requirements.txt /requirements.txt
COPY dist/TestPythonProject-0.0.tar.gz /TestPythonProject-0.0.tar.gz
#COPY "dist/dbGaP-meta-package-1.2.14.post150+8d0a427.tar.gz" "/dbGaP-meta-package-1.2.14.post150+8d0a427.tar.gz"
COPY dist/ncbi-mgv-utils-1.4.0.tar.gz /ncbi-mgv-utils-1.4.0.tar.gz
COPY dist/mgv_package_and_distribute-3.1.6.tar.gz /mgv_package_and_distribute-3.1.6.tar.gz
COPY dist/airflow-utils-7.0.2.tar.gz /airflow-utils-7.0.2.tar.gz
COPY dist/sge_farm_management-2.2.0.tar.gz /sge_farm_management-2.2.0.tar.gz
COPY dist/airflow-adhoc-4.0.0.tar.gz /airflow-adhoc-4.0.0.tar.gz
COPY dist/Submission_Processing*.tar.gz /Submission_Processing.tar.gz

# Add directory in which pip installs to PATH
ENV PATH="/usr/local/airflow/.local/bin:${PATH}"

USER airflow

#RUN /usr/local/bin/python -m pip install --upgrade pip
#RUN pip install --upgrade setuptools
ENTRYPOINT ["/entrypoint.sh"]

# Just for documentation. Expose webserver, worker and flower respectively
EXPOSE 8080 8793 5555 5432