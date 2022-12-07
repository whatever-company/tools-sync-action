FROM python:3.11-buster@sha256:996fc48abd80ea43914e7a7bb14f4537ba0b062b2b97ed23530f3d11599b0581

RUN pip install poetry==1.0.3

COPY launch.sh dev-sync.py poetry.lock pyproject.toml /app/
WORKDIR /app
ENV POETRY_VIRTUALENVS_CREATE false
RUN poetry install --no-dev


ENTRYPOINT ["/bin/sh", "/app/launch.sh"]