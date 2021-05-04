FROM python:3.9-buster@sha256:8af54f7d06a851c3ea485094a46096a546bac63663d7bb50382e1c94499f2d90

RUN pip install poetry==1.0.3

COPY launch.sh dev-sync.py poetry.lock pyproject.toml /app/
WORKDIR /app
ENV POETRY_VIRTUALENVS_CREATE false
RUN poetry install --no-dev


ENTRYPOINT ["/bin/sh", "/app/launch.sh"]