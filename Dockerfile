FROM python:3.10-buster@sha256:a8383bcdaba7dbf17aa6d09d796a16b5415c46b74476809d8b0232b6ac38e184

RUN pip install poetry==1.0.3

COPY launch.sh dev-sync.py poetry.lock pyproject.toml /app/
WORKDIR /app
ENV POETRY_VIRTUALENVS_CREATE false
RUN poetry install --no-dev


ENTRYPOINT ["/bin/sh", "/app/launch.sh"]