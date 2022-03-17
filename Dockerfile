FROM python:3.10-buster@sha256:2104954b86a936e2a859a0f6bf14a2c78215c44d582b27f6eb135ea22afeb0a4

RUN pip install poetry==1.0.3

COPY launch.sh dev-sync.py poetry.lock pyproject.toml /app/
WORKDIR /app
ENV POETRY_VIRTUALENVS_CREATE false
RUN poetry install --no-dev


ENTRYPOINT ["/bin/sh", "/app/launch.sh"]