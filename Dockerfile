FROM python:3.9-buster@sha256:7b0e6843ac36cbcb1726be1251ce9b67b6dd7d086cd325270ba99ab1f2328907

RUN pip install poetry==1.0.3

COPY launch.sh dev-sync.py poetry.lock pyproject.toml /app/
WORKDIR /app
ENV POETRY_VIRTUALENVS_CREATE false
RUN poetry install --no-dev


ENTRYPOINT ["/bin/sh", "/app/launch.sh"]