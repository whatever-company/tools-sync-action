FROM python:3.10-buster@sha256:8d0d32bf38ef42bc944120b9065f4047cdee66d0afb23c76dd36d5b9b900c482

RUN pip install poetry==1.0.3

COPY launch.sh dev-sync.py poetry.lock pyproject.toml /app/
WORKDIR /app
ENV POETRY_VIRTUALENVS_CREATE false
RUN poetry install --no-dev


ENTRYPOINT ["/bin/sh", "/app/launch.sh"]