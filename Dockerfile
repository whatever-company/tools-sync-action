FROM python:3.10-buster@sha256:fb0b2211c81e9a1316f8f005bb2f0b0b3b8d9da6a7e40cf8d58b94a1b2b00bf8

RUN pip install poetry==1.0.3

COPY launch.sh dev-sync.py poetry.lock pyproject.toml /app/
WORKDIR /app
ENV POETRY_VIRTUALENVS_CREATE false
RUN poetry install --no-dev


ENTRYPOINT ["/bin/sh", "/app/launch.sh"]