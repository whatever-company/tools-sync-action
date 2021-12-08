FROM python:3.10-buster@sha256:c7a3709df815d8faffd48ab7174971b65792aef8f97c5bf797c3f7ce787fb5a8

RUN pip install poetry==1.0.3

COPY launch.sh dev-sync.py poetry.lock pyproject.toml /app/
WORKDIR /app
ENV POETRY_VIRTUALENVS_CREATE false
RUN poetry install --no-dev


ENTRYPOINT ["/bin/sh", "/app/launch.sh"]