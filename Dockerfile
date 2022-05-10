FROM python:3.10-buster@sha256:8d61794764e974f6b4308b2fca9f681213d652c4018b301ec85f2d9cf6f9c2b3

RUN pip install poetry==1.0.3

COPY launch.sh dev-sync.py poetry.lock pyproject.toml /app/
WORKDIR /app
ENV POETRY_VIRTUALENVS_CREATE false
RUN poetry install --no-dev


ENTRYPOINT ["/bin/sh", "/app/launch.sh"]