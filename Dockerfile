FROM python:3.8-buster@sha256:55bfc00ee7ac02d2a866252f1c92a00bb9bd47e42872e804a0b00a7601133a04

RUN pip install poetry==1.0.3

COPY launch.sh dev-sync.py poetry.lock pyproject.toml /app/
WORKDIR /app
ENV POETRY_VIRTUALENVS_CREATE false
RUN poetry install --no-dev


ENTRYPOINT ["/bin/sh", "/app/launch.sh"]