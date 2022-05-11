FROM python:3.10-buster@sha256:32516b6e07ff237f4581ef2d2c2cfb1ea05a80e4a02fd06f0d777f5e8f98858d

RUN pip install poetry==1.0.3

COPY launch.sh dev-sync.py poetry.lock pyproject.toml /app/
WORKDIR /app
ENV POETRY_VIRTUALENVS_CREATE false
RUN poetry install --no-dev


ENTRYPOINT ["/bin/sh", "/app/launch.sh"]