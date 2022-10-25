FROM python:3.10-buster@sha256:7379cc1e84c256ffea1d01a811bc176c24b9fc3941af1243254fa3d9d4f5ec0b

RUN pip install poetry==1.0.3

COPY launch.sh dev-sync.py poetry.lock pyproject.toml /app/
WORKDIR /app
ENV POETRY_VIRTUALENVS_CREATE false
RUN poetry install --no-dev


ENTRYPOINT ["/bin/sh", "/app/launch.sh"]