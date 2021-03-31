FROM python:3.9-buster@sha256:837664a3f831fd074345500ab075f2e69418022b2f33a928ae3d74fc06565f35

RUN pip install poetry==1.0.3

COPY launch.sh dev-sync.py poetry.lock pyproject.toml /app/
WORKDIR /app
ENV POETRY_VIRTUALENVS_CREATE false
RUN poetry install --no-dev


ENTRYPOINT ["/bin/sh", "/app/launch.sh"]