FROM python:3.11-buster@sha256:7f03bcdc5df51a51e74b96d38df2eb03e92aa94a872c9e4bfedf25b224e44519

RUN pip install poetry==1.0.3

COPY launch.sh dev-sync.py poetry.lock pyproject.toml /app/
WORKDIR /app
ENV POETRY_VIRTUALENVS_CREATE false
RUN poetry install --no-dev


ENTRYPOINT ["/bin/sh", "/app/launch.sh"]