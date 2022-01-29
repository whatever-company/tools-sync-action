FROM python:3.10-buster@sha256:59941bb1e39b739be711d302225ee229aee7f7e859edc877d7f4d3e8a78faa9a

RUN pip install poetry==1.0.3

COPY launch.sh dev-sync.py poetry.lock pyproject.toml /app/
WORKDIR /app
ENV POETRY_VIRTUALENVS_CREATE false
RUN poetry install --no-dev


ENTRYPOINT ["/bin/sh", "/app/launch.sh"]