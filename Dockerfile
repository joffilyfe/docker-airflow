FROM python:3.7-alpine3.10

ARG AIRFLOW_HOME=/usr/local/airflow
ENV AIRFLOW_GPL_UNIDECODE yes

COPY requirements.txt requirements.txt

RUN apk add --no-cache --virtual .build-deps \
        make gcc g++ musl-dev linux-headers  \
    && apk add bash git openjdk8 postgresql-dev gcc python3-dev musl-dev

RUN pip install --no-cache-dir --upgrade pip \
    && pip install numpy==1.17.0 \
    && pip install -r requirements.txt \
    && apk --purge del .build-deps

RUN addgroup -S airflow \
    && adduser -S airflow -G airflow -h ${AIRFLOW_HOME} \
    && chown -R airflow:airflow ${AIRFLOW_HOME}

COPY --chown=airflow:airflow ./entrypoint.sh /entrypoint.sh

USER airflow
WORKDIR ${AIRFLOW_HOME}

ENV JAVA_HOME=/usr/lib/jvm/java-1.8-openjdk
ENV PATH="$JAVA_HOME/bin:${AIRFLOW_HOME}:${PATH}"

EXPOSE 8080

ENTRYPOINT ["/usr/local/bin/dumb-init", "--", "/bin/sh", "/entrypoint.sh"]
CMD ["--help"]