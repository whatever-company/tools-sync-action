FROM python:3.8-buster@sha256:b02c5b8aa0ace8a50cf460e1d3421166dbf61443471744f1aca6d2cffe6cdd70

RUN pip install poetry==1.0.3

COPY launch.sh dev-sync.py poetry.lock pyproject.toml /app/
WORKDIR /app
ENV POETRY_VIRTUALENVS_CREATE false
RUN poetry install --no-dev


ENTRYPOINT ["/bin/sh", "/app/launch.sh"]