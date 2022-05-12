FROM python:3.10-buster@sha256:0b1de80a514440e2ed4a0eba9c41b202bf71ed930cb9b33ed8ccb6e9d2ea1e0e

RUN pip install poetry==1.0.3

COPY launch.sh dev-sync.py poetry.lock pyproject.toml /app/
WORKDIR /app
ENV POETRY_VIRTUALENVS_CREATE false
RUN poetry install --no-dev


ENTRYPOINT ["/bin/sh", "/app/launch.sh"]