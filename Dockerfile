FROM python:3.8-buster@sha256:d24b098d2b144adc02ed5c9917a17485b55a30f7ca55d8015b6df018b9337cde

RUN pip install poetry==1.0.3

COPY launch.sh dev-sync.py poetry.lock pyproject.toml /app/
WORKDIR /app
ENV POETRY_VIRTUALENVS_CREATE false
RUN poetry install --no-dev


ENTRYPOINT ["/bin/sh", "/app/launch.sh"]