FROM python:3.8-buster@sha256:ea77b0884b4a22d97a461c159e7f65461727d9e86f41388d50613b7a4c99843e

RUN pip install poetry==1.0.3

COPY launch.sh dev-sync.py poetry.lock pyproject.toml /app/
WORKDIR /app
ENV POETRY_VIRTUALENVS_CREATE false
RUN poetry install --no-dev


ENTRYPOINT ["/bin/sh", "/app/launch.sh"]