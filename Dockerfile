FROM python:3.9-buster@sha256:9d593b09e181463cde2efea68db53aa544d3f9ac8f28d3060a7ea8c09749fd6b

RUN pip install poetry==1.0.3

COPY launch.sh dev-sync.py poetry.lock pyproject.toml /app/
WORKDIR /app
ENV POETRY_VIRTUALENVS_CREATE false
RUN poetry install --no-dev


ENTRYPOINT ["/bin/sh", "/app/launch.sh"]