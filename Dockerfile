FROM python:3.9-buster@sha256:621f1fc718af11d8bb633670ae38ccd25747a35063cd575df66755a3e8dbd723

RUN pip install poetry==1.0.3

COPY launch.sh dev-sync.py poetry.lock pyproject.toml /app/
WORKDIR /app
ENV POETRY_VIRTUALENVS_CREATE false
RUN poetry install --no-dev


ENTRYPOINT ["/bin/sh", "/app/launch.sh"]