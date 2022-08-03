FROM python:3.10-buster@sha256:e5366297f41986634e13714c8b90c27a8a156a5796c0639a8680fdfd2a0f4801

RUN pip install poetry==1.0.3

COPY launch.sh dev-sync.py poetry.lock pyproject.toml /app/
WORKDIR /app
ENV POETRY_VIRTUALENVS_CREATE false
RUN poetry install --no-dev


ENTRYPOINT ["/bin/sh", "/app/launch.sh"]