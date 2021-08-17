FROM python:3.9-buster@sha256:9520fd39721ec16090e0a6bd710b9f49b65aa363ee82f20afee256a0e9de92f7

RUN pip install poetry==1.0.3

COPY launch.sh dev-sync.py poetry.lock pyproject.toml /app/
WORKDIR /app
ENV POETRY_VIRTUALENVS_CREATE false
RUN poetry install --no-dev


ENTRYPOINT ["/bin/sh", "/app/launch.sh"]