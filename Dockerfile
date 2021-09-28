FROM python:3.9-buster@sha256:1fa6ae5533721edbe46f8bbb0029f0c4b1dc2b5df46cc15d4b659719a81b9292

RUN pip install poetry==1.0.3

COPY launch.sh dev-sync.py poetry.lock pyproject.toml /app/
WORKDIR /app
ENV POETRY_VIRTUALENVS_CREATE false
RUN poetry install --no-dev


ENTRYPOINT ["/bin/sh", "/app/launch.sh"]