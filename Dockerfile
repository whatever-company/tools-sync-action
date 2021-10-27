FROM python:3.10-buster@sha256:27edc49670bafe3277ea3afe36d653f3472f6cde8bf0c9553b5e2f5c063a430a

RUN pip install poetry==1.0.3

COPY launch.sh dev-sync.py poetry.lock pyproject.toml /app/
WORKDIR /app
ENV POETRY_VIRTUALENVS_CREATE false
RUN poetry install --no-dev


ENTRYPOINT ["/bin/sh", "/app/launch.sh"]