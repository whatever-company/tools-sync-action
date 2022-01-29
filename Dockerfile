FROM python:3.10-buster@sha256:6743539d29d9a64dcee609143a015b7081cfc2b6177fbefb47483c5121af37de

RUN pip install poetry==1.0.3

COPY launch.sh dev-sync.py poetry.lock pyproject.toml /app/
WORKDIR /app
ENV POETRY_VIRTUALENVS_CREATE false
RUN poetry install --no-dev


ENTRYPOINT ["/bin/sh", "/app/launch.sh"]