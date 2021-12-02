FROM python:3.10-buster@sha256:e3c8b88ae7515654c43e2e1d3e039cccd358fc55891afcfb0023d19730a0ee2a

RUN pip install poetry==1.0.3

COPY launch.sh dev-sync.py poetry.lock pyproject.toml /app/
WORKDIR /app
ENV POETRY_VIRTUALENVS_CREATE false
RUN poetry install --no-dev


ENTRYPOINT ["/bin/sh", "/app/launch.sh"]