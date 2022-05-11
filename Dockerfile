FROM python:3.10-buster@sha256:d5122d3737dcc1cd9a075b4cf0f17fd84e6d03ab7cfb243c3ec471e300c6e050

RUN pip install poetry==1.0.3

COPY launch.sh dev-sync.py poetry.lock pyproject.toml /app/
WORKDIR /app
ENV POETRY_VIRTUALENVS_CREATE false
RUN poetry install --no-dev


ENTRYPOINT ["/bin/sh", "/app/launch.sh"]