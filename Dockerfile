FROM python:3.9-buster@sha256:01c1aef03f91edece3043dde868e1a49e9674e53562238ed4e7fdd9bf415bd38

RUN pip install poetry==1.0.3

COPY launch.sh dev-sync.py poetry.lock pyproject.toml /app/
WORKDIR /app
ENV POETRY_VIRTUALENVS_CREATE false
RUN poetry install --no-dev


ENTRYPOINT ["/bin/sh", "/app/launch.sh"]