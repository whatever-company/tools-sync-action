FROM python:3.9-buster@sha256:097bd0cda01b32d79ca4db7ab0ee8dbe45d75758da86d016abdad43ea21adca0

RUN pip install poetry==1.0.3

COPY launch.sh dev-sync.py poetry.lock pyproject.toml /app/
WORKDIR /app
ENV POETRY_VIRTUALENVS_CREATE false
RUN poetry install --no-dev


ENTRYPOINT ["/bin/sh", "/app/launch.sh"]