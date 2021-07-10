FROM python:3.9-buster@sha256:fa9d4e4078816cf6ec8eb662ea65c3d9c87a17732713d79b14caedc088900780

RUN pip install poetry==1.0.3

COPY launch.sh dev-sync.py poetry.lock pyproject.toml /app/
WORKDIR /app
ENV POETRY_VIRTUALENVS_CREATE false
RUN poetry install --no-dev


ENTRYPOINT ["/bin/sh", "/app/launch.sh"]