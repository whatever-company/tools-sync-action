FROM python:3.9-buster@sha256:05f84c20f9993795ca57d6abda5b4dfc4d9ab3e532d10714973be6289b96546a

RUN pip install poetry==1.0.3

COPY launch.sh dev-sync.py poetry.lock pyproject.toml /app/
WORKDIR /app
ENV POETRY_VIRTUALENVS_CREATE false
RUN poetry install --no-dev


ENTRYPOINT ["/bin/sh", "/app/launch.sh"]