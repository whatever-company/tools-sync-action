FROM python:3.9-buster@sha256:3e6edebb06f8050e53fa3a0916b24ed1a5d6392c0a297c28e0560cb51aeb98e1

RUN pip install poetry==1.0.3

COPY launch.sh dev-sync.py poetry.lock pyproject.toml /app/
WORKDIR /app
ENV POETRY_VIRTUALENVS_CREATE false
RUN poetry install --no-dev


ENTRYPOINT ["/bin/sh", "/app/launch.sh"]