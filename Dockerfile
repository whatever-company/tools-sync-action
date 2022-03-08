FROM python:3.10-buster@sha256:b1f25ddc334ed6d44b707e42c0263d17ac4222cedf0a36496d5af8a185dcf072

RUN pip install poetry==1.0.3

COPY launch.sh dev-sync.py poetry.lock pyproject.toml /app/
WORKDIR /app
ENV POETRY_VIRTUALENVS_CREATE false
RUN poetry install --no-dev


ENTRYPOINT ["/bin/sh", "/app/launch.sh"]