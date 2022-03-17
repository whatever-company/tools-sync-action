FROM python:3.10-buster@sha256:5851028fa263821ad2878ba91497cc4678c72934aeab648086c18b64c7c640ee

RUN pip install poetry==1.0.3

COPY launch.sh dev-sync.py poetry.lock pyproject.toml /app/
WORKDIR /app
ENV POETRY_VIRTUALENVS_CREATE false
RUN poetry install --no-dev


ENTRYPOINT ["/bin/sh", "/app/launch.sh"]