FROM python:3.9-buster@sha256:48701bdf36ce19afafbcf5b6f70f6d1e4244cdc9af5ff94d0bcd8361546f63c9

RUN pip install poetry==1.0.3

COPY launch.sh dev-sync.py poetry.lock pyproject.toml /app/
WORKDIR /app
ENV POETRY_VIRTUALENVS_CREATE false
RUN poetry install --no-dev


ENTRYPOINT ["/bin/sh", "/app/launch.sh"]