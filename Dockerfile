FROM python:3.9-buster@sha256:d9dbd09e20abe942d84fef5b736f5ed7ee638e3204e0c0b14345d3754026156d

RUN pip install poetry==1.0.3

COPY launch.sh dev-sync.py poetry.lock pyproject.toml /app/
WORKDIR /app
ENV POETRY_VIRTUALENVS_CREATE false
RUN poetry install --no-dev


ENTRYPOINT ["/bin/sh", "/app/launch.sh"]