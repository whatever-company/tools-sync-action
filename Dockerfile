FROM python:3.11-buster@sha256:d1b72f4b114130d2ec5eb81a9d789c34312eef7eb79398cd683c82b0590872b1

RUN pip install poetry==1.0.3

COPY launch.sh dev-sync.py poetry.lock pyproject.toml /app/
WORKDIR /app
ENV POETRY_VIRTUALENVS_CREATE false
RUN poetry install --no-dev


ENTRYPOINT ["/bin/sh", "/app/launch.sh"]