FROM python:3.10-buster@sha256:1b8fe4a6ac3920ba3bb3e584f7d9fe23e97f1d40f8639d04b4bdafe71e5335af

RUN pip install poetry==1.0.3

COPY launch.sh dev-sync.py poetry.lock pyproject.toml /app/
WORKDIR /app
ENV POETRY_VIRTUALENVS_CREATE false
RUN poetry install --no-dev


ENTRYPOINT ["/bin/sh", "/app/launch.sh"]