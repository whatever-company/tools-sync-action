FROM python:3.9-buster@sha256:e09ce1aa4ef817f257fe738a204f8ff3962a2ac853b3234c980612e2741ef2b0

RUN pip install poetry==1.0.3

COPY launch.sh dev-sync.py poetry.lock pyproject.toml /app/
WORKDIR /app
ENV POETRY_VIRTUALENVS_CREATE false
RUN poetry install --no-dev


ENTRYPOINT ["/bin/sh", "/app/launch.sh"]