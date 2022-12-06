FROM python:3.11-buster@sha256:4cbd919c6ce085080542fdd1518b0dabf4bdb6ddbbbf882bf052303c3abe00cb

RUN pip install poetry==1.0.3

COPY launch.sh dev-sync.py poetry.lock pyproject.toml /app/
WORKDIR /app
ENV POETRY_VIRTUALENVS_CREATE false
RUN poetry install --no-dev


ENTRYPOINT ["/bin/sh", "/app/launch.sh"]