FROM python:3.9-buster@sha256:ebda34d86d2246f7c649db0275b0efe16449d5b5125ee4aeea4d14134236b07c

RUN pip install poetry==1.0.3

COPY launch.sh dev-sync.py poetry.lock pyproject.toml /app/
WORKDIR /app
ENV POETRY_VIRTUALENVS_CREATE false
RUN poetry install --no-dev


ENTRYPOINT ["/bin/sh", "/app/launch.sh"]