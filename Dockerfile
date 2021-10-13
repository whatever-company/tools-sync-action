FROM python:3.10-buster@sha256:67cc43173761241e173312d0541e5f88d032f32556615ad78973d8d7f1acafab

RUN pip install poetry==1.0.3

COPY launch.sh dev-sync.py poetry.lock pyproject.toml /app/
WORKDIR /app
ENV POETRY_VIRTUALENVS_CREATE false
RUN poetry install --no-dev


ENTRYPOINT ["/bin/sh", "/app/launch.sh"]