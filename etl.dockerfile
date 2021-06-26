FROM python:3.8-slim

# DECLARE ENV VARIABLES

ENV DAGSTER_VERSION=0.11.11

# Main Dependencies for container with pipeline code. Do not repeat these in the setup.py `install_requires` list.

RUN pip install \
    dagster==${DAGSTER_VERSION} \
    dagster-postgres==${DAGSTER_VERSION} \
    dagster-docker==${DAGSTER_VERSION}

# Set $DAGSTER_HOME and copy dagster instance there

ENV DAGSTER_HOME=/opt/dagster/dagster_home

RUN mkdir -p $DAGSTER_HOME

COPY dagster.yaml $DAGSTER_HOME

# Add repository code

WORKDIR /opt/dagster/etl

# Copy the etl repo 

COPY src/etl .

# RUN install pip requirements

RUN pip install -r requirements-etl.txt

# Run dagster gRPC server on port 4000

EXPOSE 4000

# CMD allows this to be overridden from run launchers or executors that want
# to run other commands against your repository

CMD ["dagster", "api", "grpc", "-h", "0.0.0.0", "-p", "4000", "-f", "./etl/repository.py"]