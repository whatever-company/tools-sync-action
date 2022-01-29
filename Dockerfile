FROM python:3.10-buster@sha256:b5d3c93426ab24edad97292e711b1cc27cacb475b9cc786e91c881571682c167

RUN pip install poetry==1.0.3

COPY launch.sh dev-sync.py poetry.lock pyproject.toml /app/
WORKDIR /app
ENV POETRY_VIRTUALENVS_CREATE false
RUN poetry install --no-dev


ENTRYPOINT ["/bin/sh", "/app/launch.sh"]