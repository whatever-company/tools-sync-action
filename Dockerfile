FROM python:3.8-buster@sha256:ba23c4870854aa0718113e8765e7f46acbf141c6be1e66957ddcf130bd88d59d

RUN pip install poetry==1.0.3

COPY launch.sh dev-sync.py poetry.lock pyproject.toml /app/
WORKDIR /app
ENV POETRY_VIRTUALENVS_CREATE false
RUN poetry install --no-dev


ENTRYPOINT ["/bin/sh", "/app/launch.sh"]