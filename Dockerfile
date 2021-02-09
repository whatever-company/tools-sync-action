FROM python:3.9-buster@sha256:d6cc929494abde879a1633cd09c372457da3f295cfd21aa6ac6328e389edb099

RUN pip install poetry==1.0.3

COPY launch.sh dev-sync.py poetry.lock pyproject.toml /app/
WORKDIR /app
ENV POETRY_VIRTUALENVS_CREATE false
RUN poetry install --no-dev


ENTRYPOINT ["/bin/sh", "/app/launch.sh"]