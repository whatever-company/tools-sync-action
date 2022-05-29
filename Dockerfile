FROM python:3.10-buster@sha256:ce28a6b47cf1d2c08434100ead18d673fb995433b415a9f7226abf26f7bb8475

RUN pip install poetry==1.0.3

COPY launch.sh dev-sync.py poetry.lock pyproject.toml /app/
WORKDIR /app
ENV POETRY_VIRTUALENVS_CREATE false
RUN poetry install --no-dev


ENTRYPOINT ["/bin/sh", "/app/launch.sh"]