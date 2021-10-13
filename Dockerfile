FROM python:3.10-buster@sha256:9a90af66ef6fa889e2af1f6a90f134586eaa6f2c6c47ed2912fc342ede56d4a1

RUN pip install poetry==1.0.3

COPY launch.sh dev-sync.py poetry.lock pyproject.toml /app/
WORKDIR /app
ENV POETRY_VIRTUALENVS_CREATE false
RUN poetry install --no-dev


ENTRYPOINT ["/bin/sh", "/app/launch.sh"]