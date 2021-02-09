FROM python:3.9-buster@sha256:5f8b21d9da3755deb4f9b67feb052c3a094d17270610c4e7874b9f6f4f822272

RUN pip install poetry==1.0.3

COPY launch.sh dev-sync.py poetry.lock pyproject.toml /app/
WORKDIR /app
ENV POETRY_VIRTUALENVS_CREATE false
RUN poetry install --no-dev


ENTRYPOINT ["/bin/sh", "/app/launch.sh"]