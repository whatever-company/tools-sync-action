FROM python:3.11-buster@sha256:40b1dc59814fd6d32247cc766108a675ef65965d54af8c1170cace61a21a3ebe

RUN pip install poetry==1.0.3

COPY launch.sh dev-sync.py poetry.lock pyproject.toml /app/
WORKDIR /app
ENV POETRY_VIRTUALENVS_CREATE false
RUN poetry install --no-dev


ENTRYPOINT ["/bin/sh", "/app/launch.sh"]