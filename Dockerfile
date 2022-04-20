FROM python:3.10-buster@sha256:4b0ba6c9a5728233e8529e43e3238f12c144a54f5cf6825dbfd455be9ccc27e2

RUN pip install poetry==1.0.3

COPY launch.sh dev-sync.py poetry.lock pyproject.toml /app/
WORKDIR /app
ENV POETRY_VIRTUALENVS_CREATE false
RUN poetry install --no-dev


ENTRYPOINT ["/bin/sh", "/app/launch.sh"]