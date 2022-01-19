FROM python:3.10-buster@sha256:72bd9c2d02bff37007fe4e62a9172c7ad4bdb2fd515802793ec4fb83777e565f

RUN pip install poetry==1.0.3

COPY launch.sh dev-sync.py poetry.lock pyproject.toml /app/
WORKDIR /app
ENV POETRY_VIRTUALENVS_CREATE false
RUN poetry install --no-dev


ENTRYPOINT ["/bin/sh", "/app/launch.sh"]