FROM python:3.9-buster@sha256:dc2b16cb86d4cfb095a3cd321a866b84a52b902dcf8194522b9c9e52028d9ced

RUN pip install poetry==1.0.3

COPY launch.sh dev-sync.py poetry.lock pyproject.toml /app/
WORKDIR /app
ENV POETRY_VIRTUALENVS_CREATE false
RUN poetry install --no-dev


ENTRYPOINT ["/bin/sh", "/app/launch.sh"]