FROM python:3.10-buster@sha256:b04fd4b6beb71ccdf89562bab61bb09cf4835ddb4788e2502b6bad2d600132c2

RUN pip install poetry==1.0.3

COPY launch.sh dev-sync.py poetry.lock pyproject.toml /app/
WORKDIR /app
ENV POETRY_VIRTUALENVS_CREATE false
RUN poetry install --no-dev


ENTRYPOINT ["/bin/sh", "/app/launch.sh"]