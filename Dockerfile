FROM python:3.10-buster@sha256:7973f1bb0d578a8540027d7148f761470b4e3ed5d77c4be489a33819765ebaa8

RUN pip install poetry==1.0.3

COPY launch.sh dev-sync.py poetry.lock pyproject.toml /app/
WORKDIR /app
ENV POETRY_VIRTUALENVS_CREATE false
RUN poetry install --no-dev


ENTRYPOINT ["/bin/sh", "/app/launch.sh"]