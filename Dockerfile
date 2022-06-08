FROM python:3.10-buster@sha256:e9a0687161022c5857fd71f958b0bd43aebe5beb4739210ff36f6d510f332778

RUN pip install poetry==1.0.3

COPY launch.sh dev-sync.py poetry.lock pyproject.toml /app/
WORKDIR /app
ENV POETRY_VIRTUALENVS_CREATE false
RUN poetry install --no-dev


ENTRYPOINT ["/bin/sh", "/app/launch.sh"]