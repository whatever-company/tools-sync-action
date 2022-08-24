FROM python:3.10-buster@sha256:1546fa1fd7bb0510f0f50ce358843fdcb40b397ae520fd18034d988da0500e47

RUN pip install poetry==1.0.3

COPY launch.sh dev-sync.py poetry.lock pyproject.toml /app/
WORKDIR /app
ENV POETRY_VIRTUALENVS_CREATE false
RUN poetry install --no-dev


ENTRYPOINT ["/bin/sh", "/app/launch.sh"]