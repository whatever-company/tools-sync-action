FROM python:3.9-buster@sha256:4943d9f9f1e7b66693218a93920c852841d66e0314683170942675bb6da5c1f0

RUN pip install poetry==1.0.3

COPY launch.sh dev-sync.py poetry.lock pyproject.toml /app/
WORKDIR /app
ENV POETRY_VIRTUALENVS_CREATE false
RUN poetry install --no-dev


ENTRYPOINT ["/bin/sh", "/app/launch.sh"]