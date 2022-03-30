FROM python:3.10-buster@sha256:bfad5cb5975598ea986456703d51165491edeb8803e7104bb2f7d384918cbee1

RUN pip install poetry==1.0.3

COPY launch.sh dev-sync.py poetry.lock pyproject.toml /app/
WORKDIR /app
ENV POETRY_VIRTUALENVS_CREATE false
RUN poetry install --no-dev


ENTRYPOINT ["/bin/sh", "/app/launch.sh"]