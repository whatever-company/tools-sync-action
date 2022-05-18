FROM python:3.10-buster@sha256:7f217840d3b01b1381d21dddc7149a58e2180363e7b620f0ca47507948182f0b

RUN pip install poetry==1.0.3

COPY launch.sh dev-sync.py poetry.lock pyproject.toml /app/
WORKDIR /app
ENV POETRY_VIRTUALENVS_CREATE false
RUN poetry install --no-dev


ENTRYPOINT ["/bin/sh", "/app/launch.sh"]