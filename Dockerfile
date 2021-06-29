FROM python:3.9-buster@sha256:23f0d5dc468db09ffeffc560c449eea0facc786651b210385d094bd2f88bb752

RUN pip install poetry==1.0.3

COPY launch.sh dev-sync.py poetry.lock pyproject.toml /app/
WORKDIR /app
ENV POETRY_VIRTUALENVS_CREATE false
RUN poetry install --no-dev


ENTRYPOINT ["/bin/sh", "/app/launch.sh"]