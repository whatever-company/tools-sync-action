FROM python:3.10-buster@sha256:9ee976fa2e1979adf84248fb9d7d888d4b4fee32263c6ed1b35863dd0c8ff443

RUN pip install poetry==1.0.3

COPY launch.sh dev-sync.py poetry.lock pyproject.toml /app/
WORKDIR /app
ENV POETRY_VIRTUALENVS_CREATE false
RUN poetry install --no-dev


ENTRYPOINT ["/bin/sh", "/app/launch.sh"]