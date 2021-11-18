FROM python:3.10-buster@sha256:7d23396bb6ab029b94780004dfa5292df5263954f65bdbd0c0308d206a51d65d

RUN pip install poetry==1.0.3

COPY launch.sh dev-sync.py poetry.lock pyproject.toml /app/
WORKDIR /app
ENV POETRY_VIRTUALENVS_CREATE false
RUN poetry install --no-dev


ENTRYPOINT ["/bin/sh", "/app/launch.sh"]