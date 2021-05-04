FROM python:3.9-buster@sha256:6ae3c383d386634fbc317ad3383cc5c5fe6731e4cc97b3df5de535bb9bc4d136

RUN pip install poetry==1.0.3

COPY launch.sh dev-sync.py poetry.lock pyproject.toml /app/
WORKDIR /app
ENV POETRY_VIRTUALENVS_CREATE false
RUN poetry install --no-dev


ENTRYPOINT ["/bin/sh", "/app/launch.sh"]