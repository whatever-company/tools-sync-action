FROM python:3.9-buster@sha256:59f4ce1606587995e38fe148b9218375418d0ef273fabf138b8987e9de2e3cde

RUN pip install poetry==1.0.3

COPY launch.sh dev-sync.py poetry.lock pyproject.toml /app/
WORKDIR /app
ENV POETRY_VIRTUALENVS_CREATE false
RUN poetry install --no-dev


ENTRYPOINT ["/bin/sh", "/app/launch.sh"]