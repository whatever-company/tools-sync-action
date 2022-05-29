FROM python:3.10-buster@sha256:49100fed3ac4864cd8d599e98e7557f31f50cba567cc5f7cf439969e4044c53d

RUN pip install poetry==1.0.3

COPY launch.sh dev-sync.py poetry.lock pyproject.toml /app/
WORKDIR /app
ENV POETRY_VIRTUALENVS_CREATE false
RUN poetry install --no-dev


ENTRYPOINT ["/bin/sh", "/app/launch.sh"]