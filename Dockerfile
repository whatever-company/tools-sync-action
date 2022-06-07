FROM python:3.10-buster@sha256:f161e6331e1085fd97f62780e128511734f27c0bfac43b93bcae21b9a71815c4

RUN pip install poetry==1.0.3

COPY launch.sh dev-sync.py poetry.lock pyproject.toml /app/
WORKDIR /app
ENV POETRY_VIRTUALENVS_CREATE false
RUN poetry install --no-dev


ENTRYPOINT ["/bin/sh", "/app/launch.sh"]