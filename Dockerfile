FROM python:3.11-buster@sha256:269c332bf17412ced9758afcb52fc83f233ded20ae6a38f40843f6d4a2cbd49f

RUN pip install poetry==1.0.3

COPY launch.sh dev-sync.py poetry.lock pyproject.toml /app/
WORKDIR /app
ENV POETRY_VIRTUALENVS_CREATE false
RUN poetry install --no-dev


ENTRYPOINT ["/bin/sh", "/app/launch.sh"]