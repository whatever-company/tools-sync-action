FROM python:3.11-buster@sha256:560475a8f5d1bf567d5e6416be76f24191c1801948524014e18d2fe714279faa

RUN pip install poetry==1.0.3

COPY launch.sh dev-sync.py poetry.lock pyproject.toml /app/
WORKDIR /app
ENV POETRY_VIRTUALENVS_CREATE false
RUN poetry install --no-dev


ENTRYPOINT ["/bin/sh", "/app/launch.sh"]