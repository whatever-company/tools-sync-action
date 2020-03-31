FROM python:3.8-buster@sha256:ad5cbdc16628fdba27dd75d7591c157f7382f399109dad808aa6b19e21e06e7f

RUN pip install poetry==1.0.3

COPY launch.sh dev-sync.py poetry.lock pyproject.toml /app/
WORKDIR /app
ENV POETRY_VIRTUALENVS_CREATE false
RUN poetry install --no-dev


ENTRYPOINT ["/bin/sh", "/app/launch.sh"]