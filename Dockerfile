FROM python:3.10-buster@sha256:aaaed5581408c885e4d7cba96a80ea99704697bf385cd44f935d03ca2a35cf83

RUN pip install poetry==1.0.3

COPY launch.sh dev-sync.py poetry.lock pyproject.toml /app/
WORKDIR /app
ENV POETRY_VIRTUALENVS_CREATE false
RUN poetry install --no-dev


ENTRYPOINT ["/bin/sh", "/app/launch.sh"]