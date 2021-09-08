FROM python:3.9-buster@sha256:a5277bb3625c7a45e80d1e8193dcce4b491ebca0d563247eeafdac9cc415279d

RUN pip install poetry==1.0.3

COPY launch.sh dev-sync.py poetry.lock pyproject.toml /app/
WORKDIR /app
ENV POETRY_VIRTUALENVS_CREATE false
RUN poetry install --no-dev


ENTRYPOINT ["/bin/sh", "/app/launch.sh"]