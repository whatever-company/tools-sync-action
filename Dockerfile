FROM python:3.9-buster@sha256:8d833f9b69c3412b51c0169e89e1d8bf9d8e9d1b560bc8a2a017571de723d7ef

RUN pip install poetry==1.0.3

COPY launch.sh dev-sync.py poetry.lock pyproject.toml /app/
WORKDIR /app
ENV POETRY_VIRTUALENVS_CREATE false
RUN poetry install --no-dev


ENTRYPOINT ["/bin/sh", "/app/launch.sh"]