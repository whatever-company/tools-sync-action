FROM python:3.10-buster@sha256:acb9ae9c38661ffabe67624b5d822657e6ecd3b1a5d6841188fe8c574ac420db

RUN pip install poetry==1.0.3

COPY launch.sh dev-sync.py poetry.lock pyproject.toml /app/
WORKDIR /app
ENV POETRY_VIRTUALENVS_CREATE false
RUN poetry install --no-dev


ENTRYPOINT ["/bin/sh", "/app/launch.sh"]