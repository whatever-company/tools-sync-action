FROM python:3.10-buster@sha256:743b398da38e4cc7fbf687bc71cfacba57a5a3df59c887aa2a21a32cddaa5f26

RUN pip install poetry==1.0.3

COPY launch.sh dev-sync.py poetry.lock pyproject.toml /app/
WORKDIR /app
ENV POETRY_VIRTUALENVS_CREATE false
RUN poetry install --no-dev


ENTRYPOINT ["/bin/sh", "/app/launch.sh"]