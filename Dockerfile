FROM python:3.10-buster@sha256:e90e5c9ffe9f9f88ac9a0f98480fbf0df330b54ab4c7e03daa9d3a48e24d96f4

RUN pip install poetry==1.0.3

COPY launch.sh dev-sync.py poetry.lock pyproject.toml /app/
WORKDIR /app
ENV POETRY_VIRTUALENVS_CREATE false
RUN poetry install --no-dev


ENTRYPOINT ["/bin/sh", "/app/launch.sh"]