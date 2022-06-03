FROM python:3.10-buster@sha256:45a640b98a6c7b83b9c4d8f7557d88f0e54783024a9d13bb1eade83724d1b3c2

RUN pip install poetry==1.0.3

COPY launch.sh dev-sync.py poetry.lock pyproject.toml /app/
WORKDIR /app
ENV POETRY_VIRTUALENVS_CREATE false
RUN poetry install --no-dev


ENTRYPOINT ["/bin/sh", "/app/launch.sh"]