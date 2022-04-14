FROM python:3.10-buster@sha256:4fb2c51dfa020be1c37ab03fee1ce74cd6e7644af6a506f87262d99196bfc233

RUN pip install poetry==1.0.3

COPY launch.sh dev-sync.py poetry.lock pyproject.toml /app/
WORKDIR /app
ENV POETRY_VIRTUALENVS_CREATE false
RUN poetry install --no-dev


ENTRYPOINT ["/bin/sh", "/app/launch.sh"]