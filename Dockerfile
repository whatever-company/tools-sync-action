FROM python:3.10-buster@sha256:865b009d5862447349316114d7ab5f668d004bbb13a8779fe8af35ab508a43fa

RUN pip install poetry==1.0.3

COPY launch.sh dev-sync.py poetry.lock pyproject.toml /app/
WORKDIR /app
ENV POETRY_VIRTUALENVS_CREATE false
RUN poetry install --no-dev


ENTRYPOINT ["/bin/sh", "/app/launch.sh"]