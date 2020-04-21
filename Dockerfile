FROM python:3.8-buster@sha256:6f61333c945e54f36b28d51c296e70ee0c4016839aec44f408aa505427a9208e

RUN pip install poetry==1.0.3

COPY launch.sh dev-sync.py poetry.lock pyproject.toml /app/
WORKDIR /app
ENV POETRY_VIRTUALENVS_CREATE false
RUN poetry install --no-dev


ENTRYPOINT ["/bin/sh", "/app/launch.sh"]