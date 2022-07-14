FROM python:3.10-buster@sha256:6f4cc882ebd935382149e2026fd5104a4b0c0c291f6fcf95fe11c5574f3f6fc1

RUN pip install poetry==1.0.3

COPY launch.sh dev-sync.py poetry.lock pyproject.toml /app/
WORKDIR /app
ENV POETRY_VIRTUALENVS_CREATE false
RUN poetry install --no-dev


ENTRYPOINT ["/bin/sh", "/app/launch.sh"]