FROM python:3.10-buster@sha256:28b3aedf3a25ff41014bcab886dd94ce638c8daf8a9e4be6834a29157c35445c

RUN pip install poetry==1.0.3

COPY launch.sh dev-sync.py poetry.lock pyproject.toml /app/
WORKDIR /app
ENV POETRY_VIRTUALENVS_CREATE false
RUN poetry install --no-dev


ENTRYPOINT ["/bin/sh", "/app/launch.sh"]