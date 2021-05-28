FROM python:3.9-buster@sha256:6129e9019606e8a0c1ddfc5905f447440890441310c88fb3224f5fb1956ddea2

RUN pip install poetry==1.0.3

COPY launch.sh dev-sync.py poetry.lock pyproject.toml /app/
WORKDIR /app
ENV POETRY_VIRTUALENVS_CREATE false
RUN poetry install --no-dev


ENTRYPOINT ["/bin/sh", "/app/launch.sh"]