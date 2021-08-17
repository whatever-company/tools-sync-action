FROM python:3.9-buster@sha256:35551d367436674ada1dd236129e0664611c589e8550de925d994eb8b8ea3dcf

RUN pip install poetry==1.0.3

COPY launch.sh dev-sync.py poetry.lock pyproject.toml /app/
WORKDIR /app
ENV POETRY_VIRTUALENVS_CREATE false
RUN poetry install --no-dev


ENTRYPOINT ["/bin/sh", "/app/launch.sh"]