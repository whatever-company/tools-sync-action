FROM python:3.9-buster@sha256:d4c50342d181abc47bcad850d47595c51dd2ceba7372b37858e57a8bba6bd09f

RUN pip install poetry==1.0.3

COPY launch.sh dev-sync.py poetry.lock pyproject.toml /app/
WORKDIR /app
ENV POETRY_VIRTUALENVS_CREATE false
RUN poetry install --no-dev


ENTRYPOINT ["/bin/sh", "/app/launch.sh"]