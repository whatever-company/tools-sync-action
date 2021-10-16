FROM python:3.10-buster@sha256:c846509a3f7e3f50f427ec7c8692ebd4b0cf074b11d4587f832c0a00f5ac860d

RUN pip install poetry==1.0.3

COPY launch.sh dev-sync.py poetry.lock pyproject.toml /app/
WORKDIR /app
ENV POETRY_VIRTUALENVS_CREATE false
RUN poetry install --no-dev


ENTRYPOINT ["/bin/sh", "/app/launch.sh"]