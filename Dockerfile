FROM python:3.9-buster@sha256:7371c8acbacdc476574c7dd08d32a50c484c1865b2d3018ae27ef8bf43f2f41b

RUN pip install poetry==1.0.3

COPY launch.sh dev-sync.py poetry.lock pyproject.toml /app/
WORKDIR /app
ENV POETRY_VIRTUALENVS_CREATE false
RUN poetry install --no-dev


ENTRYPOINT ["/bin/sh", "/app/launch.sh"]