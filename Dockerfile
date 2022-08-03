FROM python:3.10-buster@sha256:062c39d8b42f6b93af7897960f7ca998ca5ef6a279b66d84656f3b907f08d897

RUN pip install poetry==1.0.3

COPY launch.sh dev-sync.py poetry.lock pyproject.toml /app/
WORKDIR /app
ENV POETRY_VIRTUALENVS_CREATE false
RUN poetry install --no-dev


ENTRYPOINT ["/bin/sh", "/app/launch.sh"]