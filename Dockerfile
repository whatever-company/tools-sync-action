FROM python:3.9-buster@sha256:a2c440efabbd86fe2e56a9e44bad4277e70007c8fc19b10794064f89bb61830c

RUN pip install poetry==1.0.3

COPY launch.sh dev-sync.py poetry.lock pyproject.toml /app/
WORKDIR /app
ENV POETRY_VIRTUALENVS_CREATE false
RUN poetry install --no-dev


ENTRYPOINT ["/bin/sh", "/app/launch.sh"]