FROM python:3.11-buster@sha256:38e3a626c51e81b94f07ef8591f0a03fdd19c76dedb22c5b9f109f013b425159

RUN pip install poetry==1.0.3

COPY launch.sh dev-sync.py poetry.lock pyproject.toml /app/
WORKDIR /app
ENV POETRY_VIRTUALENVS_CREATE false
RUN poetry install --no-dev


ENTRYPOINT ["/bin/sh", "/app/launch.sh"]