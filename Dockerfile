FROM python:3.9-buster@sha256:054d0b56238aab69df0ee6dd2693b941540fd660701bbd90159cdffbdbd7006b

RUN pip install poetry==1.0.3

COPY launch.sh dev-sync.py poetry.lock pyproject.toml /app/
WORKDIR /app
ENV POETRY_VIRTUALENVS_CREATE false
RUN poetry install --no-dev


ENTRYPOINT ["/bin/sh", "/app/launch.sh"]