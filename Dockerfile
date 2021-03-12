FROM python:3.9-buster@sha256:d66a49bd2e3fd942969fa10fd4179076d1fddf78c521e272059ca965a0231e9c

RUN pip install poetry==1.0.3

COPY launch.sh dev-sync.py poetry.lock pyproject.toml /app/
WORKDIR /app
ENV POETRY_VIRTUALENVS_CREATE false
RUN poetry install --no-dev


ENTRYPOINT ["/bin/sh", "/app/launch.sh"]