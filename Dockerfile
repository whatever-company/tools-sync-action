FROM python:3.9-buster@sha256:f2a8fb6b1e76463da0f966f0a5195f652c8207201e0838c4e530a06819af49c8

RUN pip install poetry==1.0.3

COPY launch.sh dev-sync.py poetry.lock pyproject.toml /app/
WORKDIR /app
ENV POETRY_VIRTUALENVS_CREATE false
RUN poetry install --no-dev


ENTRYPOINT ["/bin/sh", "/app/launch.sh"]