FROM python:3.10-buster@sha256:96ff282aaea74be51cb9a882ee78738cbc9006421a30e6ef47518533c83c29e3

RUN pip install poetry==1.0.3

COPY launch.sh dev-sync.py poetry.lock pyproject.toml /app/
WORKDIR /app
ENV POETRY_VIRTUALENVS_CREATE false
RUN poetry install --no-dev


ENTRYPOINT ["/bin/sh", "/app/launch.sh"]