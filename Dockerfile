FROM python:3.9-buster@sha256:1980975f3aaf7777024ecc4c76aaa02f0d9ee77d10c48f33bc920e8c3b4d8494

RUN pip install poetry==1.0.3

COPY launch.sh dev-sync.py poetry.lock pyproject.toml /app/
WORKDIR /app
ENV POETRY_VIRTUALENVS_CREATE false
RUN poetry install --no-dev


ENTRYPOINT ["/bin/sh", "/app/launch.sh"]