FROM python:3.9-buster@sha256:9bd295fe99da7404c5d98360e69db8d53533e9a5a8c1e1a1c1a6c3f1b16691dc

RUN pip install poetry==1.0.3

COPY launch.sh dev-sync.py poetry.lock pyproject.toml /app/
WORKDIR /app
ENV POETRY_VIRTUALENVS_CREATE false
RUN poetry install --no-dev


ENTRYPOINT ["/bin/sh", "/app/launch.sh"]