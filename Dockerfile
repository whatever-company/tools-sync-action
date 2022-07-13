FROM python:3.10-buster@sha256:0c312a84099351c57f24fc2dbb4bc5fb51b5c5677a2f2b185a4d23c3e24f63bd

RUN pip install poetry==1.0.3

COPY launch.sh dev-sync.py poetry.lock pyproject.toml /app/
WORKDIR /app
ENV POETRY_VIRTUALENVS_CREATE false
RUN poetry install --no-dev


ENTRYPOINT ["/bin/sh", "/app/launch.sh"]