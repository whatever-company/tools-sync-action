FROM python:3.9-buster@sha256:c6f2d7c57e8e46a63d1d82dd4af32be9c9be2658b1e1b198eddd9b498b60a108

RUN pip install poetry==1.0.3

COPY launch.sh dev-sync.py poetry.lock pyproject.toml /app/
WORKDIR /app
ENV POETRY_VIRTUALENVS_CREATE false
RUN poetry install --no-dev


ENTRYPOINT ["/bin/sh", "/app/launch.sh"]