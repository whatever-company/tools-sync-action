FROM python:3.8-buster@sha256:2428462b26ae5203f593e192b8ab4cc0c03bca95693e27b6c72ef1a547e8cb4a

RUN pip install poetry==1.0.3

COPY launch.sh dev-sync.py poetry.lock pyproject.toml /app/
WORKDIR /app
ENV POETRY_VIRTUALENVS_CREATE false
RUN poetry install --no-dev


ENTRYPOINT ["/bin/sh", "/app/launch.sh"]