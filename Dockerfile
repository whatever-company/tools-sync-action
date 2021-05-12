FROM python:3.9-buster@sha256:db57242b1b35cc02e8ffb1582de7e3158733f85e49f530c0db3934ba9409450a

RUN pip install poetry==1.0.3

COPY launch.sh dev-sync.py poetry.lock pyproject.toml /app/
WORKDIR /app
ENV POETRY_VIRTUALENVS_CREATE false
RUN poetry install --no-dev


ENTRYPOINT ["/bin/sh", "/app/launch.sh"]