FROM python:3.8-buster@sha256:d3bfb7ed79d0eea29b12fe876c4c086797c973529eb293dd778319bf479dd07d

RUN pip install poetry==1.0.3

COPY launch.sh dev-sync.py poetry.lock pyproject.toml /app/
WORKDIR /app
ENV POETRY_VIRTUALENVS_CREATE false
RUN poetry install --no-dev


ENTRYPOINT ["/bin/sh", "/app/launch.sh"]