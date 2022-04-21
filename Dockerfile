FROM python:3.10-buster@sha256:4e08ef37a33a9a61c2a49ec960e6c5e1a6b1f55d150858d42369b4cb0b20c920

RUN pip install poetry==1.0.3

COPY launch.sh dev-sync.py poetry.lock pyproject.toml /app/
WORKDIR /app
ENV POETRY_VIRTUALENVS_CREATE false
RUN poetry install --no-dev


ENTRYPOINT ["/bin/sh", "/app/launch.sh"]