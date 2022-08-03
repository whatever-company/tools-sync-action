FROM python:3.10-buster@sha256:c8c1b51526d9652d9691dcd2ee44d5bec3e1beb9b9ba2ab6455503f1f6fc5cbc

RUN pip install poetry==1.0.3

COPY launch.sh dev-sync.py poetry.lock pyproject.toml /app/
WORKDIR /app
ENV POETRY_VIRTUALENVS_CREATE false
RUN poetry install --no-dev


ENTRYPOINT ["/bin/sh", "/app/launch.sh"]