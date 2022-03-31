FROM python:3.10-buster@sha256:c5f7ac4120c297f55c5ed1f4cde42ecb5badf0c3547531370d03f6c65a69b742

RUN pip install poetry==1.0.3

COPY launch.sh dev-sync.py poetry.lock pyproject.toml /app/
WORKDIR /app
ENV POETRY_VIRTUALENVS_CREATE false
RUN poetry install --no-dev


ENTRYPOINT ["/bin/sh", "/app/launch.sh"]