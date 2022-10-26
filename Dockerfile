FROM python:3.11-buster@sha256:dc1ccecfbace0b9f47d0598f21dd9bc81c542c974719922ed5b2e30f927d70c7

RUN pip install poetry==1.0.3

COPY launch.sh dev-sync.py poetry.lock pyproject.toml /app/
WORKDIR /app
ENV POETRY_VIRTUALENVS_CREATE false
RUN poetry install --no-dev


ENTRYPOINT ["/bin/sh", "/app/launch.sh"]