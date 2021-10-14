FROM python:3.10-buster@sha256:b4e0b56e12da6c296ae3ea9e7a661d147dd766c400bcbc76934cbed777247578

RUN pip install poetry==1.0.3

COPY launch.sh dev-sync.py poetry.lock pyproject.toml /app/
WORKDIR /app
ENV POETRY_VIRTUALENVS_CREATE false
RUN poetry install --no-dev


ENTRYPOINT ["/bin/sh", "/app/launch.sh"]