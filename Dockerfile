FROM python:3.9-buster@sha256:81fce45cf4769ad172f856f571e4b3e40c42132ad96d23221f993effc1378ff4

RUN pip install poetry==1.0.3

COPY launch.sh dev-sync.py poetry.lock pyproject.toml /app/
WORKDIR /app
ENV POETRY_VIRTUALENVS_CREATE false
RUN poetry install --no-dev


ENTRYPOINT ["/bin/sh", "/app/launch.sh"]