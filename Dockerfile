FROM python:3.10-buster@sha256:b3f80ba3e5419f4abc96738cc6ff413cdda68e8fca150cf600ef768c6bc25d71

RUN pip install poetry==1.0.3

COPY launch.sh dev-sync.py poetry.lock pyproject.toml /app/
WORKDIR /app
ENV POETRY_VIRTUALENVS_CREATE false
RUN poetry install --no-dev


ENTRYPOINT ["/bin/sh", "/app/launch.sh"]