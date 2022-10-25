FROM python:3.11-buster@sha256:bbf5aec66d87da5418131d2ef115157d872a0b09f6b8afe9359ab6b159c37eba

RUN pip install poetry==1.0.3

COPY launch.sh dev-sync.py poetry.lock pyproject.toml /app/
WORKDIR /app
ENV POETRY_VIRTUALENVS_CREATE false
RUN poetry install --no-dev


ENTRYPOINT ["/bin/sh", "/app/launch.sh"]