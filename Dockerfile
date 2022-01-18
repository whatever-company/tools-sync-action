FROM python:3.10-buster@sha256:eb64e82a1bd65cac03cfe37343c8a85e5277e5003c022fa6a6a211ec07b185a5

RUN pip install poetry==1.0.3

COPY launch.sh dev-sync.py poetry.lock pyproject.toml /app/
WORKDIR /app
ENV POETRY_VIRTUALENVS_CREATE false
RUN poetry install --no-dev


ENTRYPOINT ["/bin/sh", "/app/launch.sh"]