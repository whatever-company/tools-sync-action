FROM python:3.10-buster@sha256:ca1633ba9d8b49a1524f092b416c325fd5eb29f5d319b4b67b330288f04b6965

RUN pip install poetry==1.0.3

COPY launch.sh dev-sync.py poetry.lock pyproject.toml /app/
WORKDIR /app
ENV POETRY_VIRTUALENVS_CREATE false
RUN poetry install --no-dev


ENTRYPOINT ["/bin/sh", "/app/launch.sh"]