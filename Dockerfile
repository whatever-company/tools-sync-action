FROM python:3.10-buster@sha256:a4eccd4771fac3cd8e7dad474440671855d2fbc8046b5ed9d5f8f72ad97ca36a

RUN pip install poetry==1.0.3

COPY launch.sh dev-sync.py poetry.lock pyproject.toml /app/
WORKDIR /app
ENV POETRY_VIRTUALENVS_CREATE false
RUN poetry install --no-dev


ENTRYPOINT ["/bin/sh", "/app/launch.sh"]