FROM python:3.9-buster@sha256:c1d8471444dd7203de0a23f2134f8b50d760eb2a2f4cf96e8e17e8025ababa21

RUN pip install poetry==1.0.3

COPY launch.sh dev-sync.py poetry.lock pyproject.toml /app/
WORKDIR /app
ENV POETRY_VIRTUALENVS_CREATE false
RUN poetry install --no-dev


ENTRYPOINT ["/bin/sh", "/app/launch.sh"]