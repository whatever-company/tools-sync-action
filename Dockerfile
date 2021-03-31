FROM python:3.9-buster@sha256:56f1b4dbdebb3b6ec31126e256c0852d18e79909ed1df8b594e562ab31f9e562

RUN pip install poetry==1.0.3

COPY launch.sh dev-sync.py poetry.lock pyproject.toml /app/
WORKDIR /app
ENV POETRY_VIRTUALENVS_CREATE false
RUN poetry install --no-dev


ENTRYPOINT ["/bin/sh", "/app/launch.sh"]