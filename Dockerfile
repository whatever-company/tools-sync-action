FROM python:3.8-buster@sha256:87c9159bf6c3168f5ce7070c978201220fc61a77d603496cf3daa3c19a36f4fe

RUN pip install poetry==1.0.3

COPY launch.sh dev-sync.py poetry.lock pyproject.toml /app/
WORKDIR /app
ENV POETRY_VIRTUALENVS_CREATE false
RUN poetry install --no-dev


ENTRYPOINT ["/bin/sh", "/app/launch.sh"]