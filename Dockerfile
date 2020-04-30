FROM python:3.8-buster@sha256:7232b98bea2caf9b975d81caa6450c1d0a88447e5024688331dd499f771e1b93

RUN pip install poetry==1.0.3

COPY launch.sh dev-sync.py poetry.lock pyproject.toml /app/
WORKDIR /app
ENV POETRY_VIRTUALENVS_CREATE false
RUN poetry install --no-dev


ENTRYPOINT ["/bin/sh", "/app/launch.sh"]