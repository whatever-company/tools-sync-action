FROM python:3.11-buster@sha256:43db725cf6c954611ffe4938e330e8d18b48627ad19e4f1ed62196baf5a3ca58

RUN pip install poetry==1.0.3

COPY launch.sh dev-sync.py poetry.lock pyproject.toml /app/
WORKDIR /app
ENV POETRY_VIRTUALENVS_CREATE false
RUN poetry install --no-dev


ENTRYPOINT ["/bin/sh", "/app/launch.sh"]