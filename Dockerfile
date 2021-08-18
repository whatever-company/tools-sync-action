FROM python:3.9-buster@sha256:f1cfaacc24b7c8e344aa0169201f4f001b6776f7d771573f48acad6f05d8fcd2

RUN pip install poetry==1.0.3

COPY launch.sh dev-sync.py poetry.lock pyproject.toml /app/
WORKDIR /app
ENV POETRY_VIRTUALENVS_CREATE false
RUN poetry install --no-dev


ENTRYPOINT ["/bin/sh", "/app/launch.sh"]