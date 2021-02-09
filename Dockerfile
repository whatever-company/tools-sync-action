FROM python:3.9-buster@sha256:feaab3d04b8f28aa2a7939517fcf023bf5ef332fe190de1cdc783640e2b5db8b

RUN pip install poetry==1.0.3

COPY launch.sh dev-sync.py poetry.lock pyproject.toml /app/
WORKDIR /app
ENV POETRY_VIRTUALENVS_CREATE false
RUN poetry install --no-dev


ENTRYPOINT ["/bin/sh", "/app/launch.sh"]