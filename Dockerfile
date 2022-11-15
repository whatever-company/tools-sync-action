FROM python:3.11-buster@sha256:0e7635f347c34c95ed6e2e8cd5c4ecdc2a52035cc834fcdb21931e0b826b620a

RUN pip install poetry==1.0.3

COPY launch.sh dev-sync.py poetry.lock pyproject.toml /app/
WORKDIR /app
ENV POETRY_VIRTUALENVS_CREATE false
RUN poetry install --no-dev


ENTRYPOINT ["/bin/sh", "/app/launch.sh"]