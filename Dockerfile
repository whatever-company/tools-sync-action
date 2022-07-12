FROM python:3.10-buster@sha256:85be30c915a082ba1ef8f6fdb537946e44c008ff6862339d7c99315774c4f9c4

RUN pip install poetry==1.0.3

COPY launch.sh dev-sync.py poetry.lock pyproject.toml /app/
WORKDIR /app
ENV POETRY_VIRTUALENVS_CREATE false
RUN poetry install --no-dev


ENTRYPOINT ["/bin/sh", "/app/launch.sh"]