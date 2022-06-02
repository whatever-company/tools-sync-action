FROM python:3.10-buster@sha256:8bd3009c56f334fbaa056dd18ebfeefbf42561efd33a36a59d8c4db805546b1a

RUN pip install poetry==1.0.3

COPY launch.sh dev-sync.py poetry.lock pyproject.toml /app/
WORKDIR /app
ENV POETRY_VIRTUALENVS_CREATE false
RUN poetry install --no-dev


ENTRYPOINT ["/bin/sh", "/app/launch.sh"]