FROM python:3.9-buster@sha256:548c472cef9335c770b37fc0c652a612545c85de88c14546991f9d03b10ab9ee

RUN pip install poetry==1.0.3

COPY launch.sh dev-sync.py poetry.lock pyproject.toml /app/
WORKDIR /app
ENV POETRY_VIRTUALENVS_CREATE false
RUN poetry install --no-dev


ENTRYPOINT ["/bin/sh", "/app/launch.sh"]