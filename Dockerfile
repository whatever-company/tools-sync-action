FROM python:3.10-buster@sha256:43062c0bc3a61207929ec02180b339f526628b9c9f388fe4cb66bb79f541ab0a

RUN pip install poetry==1.0.3

COPY launch.sh dev-sync.py poetry.lock pyproject.toml /app/
WORKDIR /app
ENV POETRY_VIRTUALENVS_CREATE false
RUN poetry install --no-dev


ENTRYPOINT ["/bin/sh", "/app/launch.sh"]