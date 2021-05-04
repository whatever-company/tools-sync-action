FROM python:3.9-buster@sha256:87c90ac8f0d80fad56c65ecfaf30a9e5454e5496b28f6526652179ccab0b70dd

RUN pip install poetry==1.0.3

COPY launch.sh dev-sync.py poetry.lock pyproject.toml /app/
WORKDIR /app
ENV POETRY_VIRTUALENVS_CREATE false
RUN poetry install --no-dev


ENTRYPOINT ["/bin/sh", "/app/launch.sh"]