FROM python:3.9-buster@sha256:a0598a6289e468c22fff482bcaa4f26e34c4ff84868d0b15279fe2949208e82c

RUN pip install poetry==1.0.3

COPY launch.sh dev-sync.py poetry.lock pyproject.toml /app/
WORKDIR /app
ENV POETRY_VIRTUALENVS_CREATE false
RUN poetry install --no-dev


ENTRYPOINT ["/bin/sh", "/app/launch.sh"]