FROM python:3.10-buster@sha256:8402698e2b8f551722b64515ee32c63625dd4721b91aa5a74a0fd2911d1f79f0

RUN pip install poetry==1.0.3

COPY launch.sh dev-sync.py poetry.lock pyproject.toml /app/
WORKDIR /app
ENV POETRY_VIRTUALENVS_CREATE false
RUN poetry install --no-dev


ENTRYPOINT ["/bin/sh", "/app/launch.sh"]