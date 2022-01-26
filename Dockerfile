FROM python:3.10-buster@sha256:ff9e5ad6890a4919182f0a87e9d787b99b7c7328643134e5e10b568f0690c9a3

RUN pip install poetry==1.0.3

COPY launch.sh dev-sync.py poetry.lock pyproject.toml /app/
WORKDIR /app
ENV POETRY_VIRTUALENVS_CREATE false
RUN poetry install --no-dev


ENTRYPOINT ["/bin/sh", "/app/launch.sh"]