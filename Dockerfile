FROM python:3.9-buster@sha256:e7003f7d0c59e3e2872922356af2ba16a30db0f1300042e93823af9b1a50bd70

RUN pip install poetry==1.0.3

COPY launch.sh dev-sync.py poetry.lock pyproject.toml /app/
WORKDIR /app
ENV POETRY_VIRTUALENVS_CREATE false
RUN poetry install --no-dev


ENTRYPOINT ["/bin/sh", "/app/launch.sh"]