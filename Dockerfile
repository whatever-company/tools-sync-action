FROM python:3.10-buster@sha256:deadd1b78165e7fe956f0dd797361112a57bb38ee7e565689ab69d9883ff37a9

RUN pip install poetry==1.0.3

COPY launch.sh dev-sync.py poetry.lock pyproject.toml /app/
WORKDIR /app
ENV POETRY_VIRTUALENVS_CREATE false
RUN poetry install --no-dev


ENTRYPOINT ["/bin/sh", "/app/launch.sh"]