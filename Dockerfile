FROM python:3.10-buster@sha256:08867f223c232fd0edfc0aea888c48df8a01efd574b7554e52ac8b12bc606da8

RUN pip install poetry==1.0.3

COPY launch.sh dev-sync.py poetry.lock pyproject.toml /app/
WORKDIR /app
ENV POETRY_VIRTUALENVS_CREATE false
RUN poetry install --no-dev


ENTRYPOINT ["/bin/sh", "/app/launch.sh"]