FROM python:3.10-buster@sha256:f49553075cfb6b507a7a17603ed1fc22c81a0eec655d7402a291c1e1dbefb237

RUN pip install poetry==1.0.3

COPY launch.sh dev-sync.py poetry.lock pyproject.toml /app/
WORKDIR /app
ENV POETRY_VIRTUALENVS_CREATE false
RUN poetry install --no-dev


ENTRYPOINT ["/bin/sh", "/app/launch.sh"]