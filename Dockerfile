FROM python:3.11-buster@sha256:fbb59ebe72f5d2860325c11ba56426470c30be4cb88197f04d7597de70524ae0

RUN pip install poetry==1.0.3

COPY launch.sh dev-sync.py poetry.lock pyproject.toml /app/
WORKDIR /app
ENV POETRY_VIRTUALENVS_CREATE false
RUN poetry install --no-dev


ENTRYPOINT ["/bin/sh", "/app/launch.sh"]