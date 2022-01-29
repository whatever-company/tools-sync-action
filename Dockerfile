FROM python:3.10-buster@sha256:7707c9a8a1664e1612520a37e1e90dd21d105fd8a40381bb5cd9d57dba4777c6

RUN pip install poetry==1.0.3

COPY launch.sh dev-sync.py poetry.lock pyproject.toml /app/
WORKDIR /app
ENV POETRY_VIRTUALENVS_CREATE false
RUN poetry install --no-dev


ENTRYPOINT ["/bin/sh", "/app/launch.sh"]