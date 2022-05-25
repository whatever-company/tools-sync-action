FROM python:3.10-buster@sha256:13f1d321faa0c4ce19f7621caaae4f73ddaae26eadab3afaf6f495df8e91f133

RUN pip install poetry==1.0.3

COPY launch.sh dev-sync.py poetry.lock pyproject.toml /app/
WORKDIR /app
ENV POETRY_VIRTUALENVS_CREATE false
RUN poetry install --no-dev


ENTRYPOINT ["/bin/sh", "/app/launch.sh"]