FROM python:3.9-buster@sha256:61493874c09d8e26a7e0127d65c89dfa78d1d521b3c0de281d4fc634a6ab6a1d

RUN pip install poetry==1.0.3

COPY launch.sh dev-sync.py poetry.lock pyproject.toml /app/
WORKDIR /app
ENV POETRY_VIRTUALENVS_CREATE false
RUN poetry install --no-dev


ENTRYPOINT ["/bin/sh", "/app/launch.sh"]