FROM python:3.10-buster@sha256:fdf1e9c7c2c5287c636d0fb99c374b0dddb71c27b6609e155035adf03a557bc4

RUN pip install poetry==1.0.3

COPY launch.sh dev-sync.py poetry.lock pyproject.toml /app/
WORKDIR /app
ENV POETRY_VIRTUALENVS_CREATE false
RUN poetry install --no-dev


ENTRYPOINT ["/bin/sh", "/app/launch.sh"]