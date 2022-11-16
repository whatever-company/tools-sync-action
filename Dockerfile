FROM python:3.11-buster@sha256:b6baf17766d69c7b11a2c1d4ce2121401a91e93a2e2e8f96fd43451a6eea72b6

RUN pip install poetry==1.0.3

COPY launch.sh dev-sync.py poetry.lock pyproject.toml /app/
WORKDIR /app
ENV POETRY_VIRTUALENVS_CREATE false
RUN poetry install --no-dev


ENTRYPOINT ["/bin/sh", "/app/launch.sh"]