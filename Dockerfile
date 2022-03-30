FROM python:3.10-buster@sha256:1f29aa8a1c61cccddf85b38614256043fa2bb396626558ac85c341613e2add75

RUN pip install poetry==1.0.3

COPY launch.sh dev-sync.py poetry.lock pyproject.toml /app/
WORKDIR /app
ENV POETRY_VIRTUALENVS_CREATE false
RUN poetry install --no-dev


ENTRYPOINT ["/bin/sh", "/app/launch.sh"]