FROM python:3.9-buster@sha256:f204e25a18524dd101bb3a463533db9c123c1bd57c4988f3266c7e235dd1f289

RUN pip install poetry==1.0.3

COPY launch.sh dev-sync.py poetry.lock pyproject.toml /app/
WORKDIR /app
ENV POETRY_VIRTUALENVS_CREATE false
RUN poetry install --no-dev


ENTRYPOINT ["/bin/sh", "/app/launch.sh"]