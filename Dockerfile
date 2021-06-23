FROM python:3.9-buster@sha256:bb4746ceec1f619891a11f984a2a1fbffdad9b716f1d7e1c1b34e96d3958109e

RUN pip install poetry==1.0.3

COPY launch.sh dev-sync.py poetry.lock pyproject.toml /app/
WORKDIR /app
ENV POETRY_VIRTUALENVS_CREATE false
RUN poetry install --no-dev


ENTRYPOINT ["/bin/sh", "/app/launch.sh"]