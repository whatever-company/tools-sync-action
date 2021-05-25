FROM python:3.9-buster@sha256:19a156047284347dd8ebaaba5bee4eed49a12cb1b078f4ed3d6b437616a7b0a9

RUN pip install poetry==1.0.3

COPY launch.sh dev-sync.py poetry.lock pyproject.toml /app/
WORKDIR /app
ENV POETRY_VIRTUALENVS_CREATE false
RUN poetry install --no-dev


ENTRYPOINT ["/bin/sh", "/app/launch.sh"]