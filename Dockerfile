FROM python:3.10-buster@sha256:e91216e9adbb701e7c97a2883adf20b72fc94c313614ccf284f9e2706c99cb58

RUN pip install poetry==1.0.3

COPY launch.sh dev-sync.py poetry.lock pyproject.toml /app/
WORKDIR /app
ENV POETRY_VIRTUALENVS_CREATE false
RUN poetry install --no-dev


ENTRYPOINT ["/bin/sh", "/app/launch.sh"]